# ADR-004: エラーハンドリングに sealed class を採用した理由

## ステータス

承認済み

## 日付

2026-10-04

## 背景

プロジェクト初期、全 ViewModel の State でエラーを `String? error` として管理していた。この設計ではエラーが発生した際に「ネットワークが切れたのか」「GraphQL のレスポンスエラーなのか」「入力バリデーション違反なのか」を画面側で判別できず、以下の問題が生じていた。

- **リトライの出し分けができない**：ネットワークエラーならリトライで解決する可能性があるが、バリデーションエラーでリトライしても意味がない。しかし `String?` では両者を区別できないため、リトライボタンを一律で出すか一律で出さないかの二択になっていた
- **エラーメッセージが汎用的**：全エラーが文字列なので「エラーが発生しました」程度の汎用メッセージしか表示できず、ユーザーに具体的な対処方法（通信環境の確認・入力内容の修正等）を伝えられなかった
- **問題の切り分けが困難**：デバッグ時にも「どの種別のエラーが起きたか」をログや State から読み取れず、エラー原因の特定に時間がかかっていた
- **ViewModel が当初 5 つに増加**：PlanList / PlanDetail / Booking / Favorite / BookingHistory の 5 つの ViewModel すべてが同じ `String? error` の負債を抱えており、画面追加のたびに負債が拡大する構造だった

この設計上の負債を解消し、エラーの種別を型で表現できるようにする必要があった。

## 検討した選択肢

### 1. sealed class AppError（採用）

Dart 3.0 で導入された sealed class を使い、エラーを型階層で表現する。`switch` 式で網羅性チェック（exhaustiveness checking）が効くため、新しいエラー種別を追加したときに対応漏れがコンパイルエラーとして検出される。

### 2. Result 型（Result<T, E> パターン）

成功と失敗を1つの型で表現する。Rust の `Result` や Kotlin の `Result` に相当する。Dart には標準ライブラリに Result 型がないため、自前で定義するか `dartz` / `fpdart` パッケージの `Either` を使う必要がある。

### 3. dartz / fpdart の Either 型

関数型プログラミングライブラリの `Either<L, R>` で Left にエラー、Right に成功値を持たせるパターン。型安全だが、`fold` / `map` / `flatMap` などの関数型 API に習熟が必要で、Riverpod の `AsyncNotifier` パターンとの統合にも追加の設計が求められる。

### 4. enum + メッセージ

`enum ErrorType { network, graphql, validation, unknown }` と `String message` の組み合わせ。シンプルだが、エラー種別ごとに異なる付加情報（GraphQLError のエラーコード、ValidationError のフィールド名等）を型安全に持たせることができない。

### 5. String? error のまま維持

変更コストがゼロだが、上記の問題がすべて残り続ける。ViewModel が増えるたびに負債が拡大する。

## 決定

**sealed class AppError を採用する。** エラーを `NetworkError` / `GraphQLError` / `ValidationError` / `UnknownError` の 4 サブクラスに分類し、全 ViewModel の State の `error` フィールドを `String?` から `AppError?` に置き換える。

## 理由

### エラーの種別を型で表現する

sealed class の最大の利点は、エラーの種別が「型」として存在することである。`switch` 式で各サブクラスに分岐でき、Dart の網羅性チェックにより全種別を処理しているかがコンパイル時に保証される。

```dart
// String? の場合: 種別の判別が不可能
if (state.error != null) {
  // ネットワークエラー？バリデーションエラー？わからない
  return AppErrorWidget(message: state.error!);
}

// sealed class の場合: 型で分岐できる
switch (state.error) {
  case NetworkError():     // リトライボタンを表示
  case GraphQLError():     // エラーコード付きメッセージを表示
  case ValidationError():  // フィールド名付きメッセージを表示
  case UnknownError():     // 汎用メッセージを表示
  case null:               // エラーなし
}
```

### 4 種のエラー分類の根拠

エラーの分類は「ユーザーに何を伝え、どう対処してもらうか」を基準に設計した。

| サブクラス | 発生源 | ユーザーへの対処案内 | リトライ |
|---|---|---|---|
| `NetworkError` | 通信断・タイムアウト（`SocketException` / `HttpException`） | 「通信環境を確認してください」 | ✅ 有効 |
| `GraphQLError` | バックエンドの処理エラー（GraphQL `errors` フィールド） | エラーメッセージを表示 | ❌ 通常無効 |
| `ValidationError` | ViewModel 内のビジネスロジックチェック | 「○○を確認してください」 | ❌ 無効 |
| `UnknownError` | 予期しない例外 | 「予期しないエラーが発生しました」 | ⚠️ 場合による |

この分類により、`AppErrorWidget` が `error` の型だけを見てリトライボタンの出し分け・アイコンの切り替え・メッセージの具体化を型安全に行えるようになった。

### 各サブクラスが固有の付加情報を持てる

enum + メッセージ方式と異なり、sealed class ではサブクラスごとに異なるフィールドを持てる。実際の実装は以下の通りである。

```dart
// lib/core/error/app_error.dart

sealed class AppError {
  const AppError(this.message);
  final String message;
}

class NetworkError extends AppError {
  const NetworkError([super.message = '通信エラーが発生しました']);
}

class GraphQLError extends AppError {
  const GraphQLError(super.message, {this.code});
  final String? code;  // 将来的に extensions.code を格納する予定（現在は常に null）
}

class ValidationError extends AppError {
  const ValidationError(super.message, {this.field});
  final String? field;  // 将来的にフィールド名を格納する予定（現在は未使用）
}

class UnknownError extends AppError {
  const UnknownError([super.message = '予期しないエラーが発生しました']);
}
```

`GraphQLError.code` および `ValidationError.field` は将来の拡張を見越したフィールドである。現時点での実装状況は以下の通り。

**`GraphQLError.code` について**：バックエンドの Apollo Server は GraphQL エラーを `extensions.code`（`VALIDATION_ERROR` / `NOT_FOUND` / `CONFLICT` 等）付きで返すが、現在の `GraphQLHttpClient` は `errors[].message` のみを抽出し `extensions` は読み取らないため、`code` は常に `null` である。認証導入（ADR-011）のタイミングで `UNAUTHENTICATED` / `FORBIDDEN` の区別が必要になった際に、HTTP クライアントの実装と合わせて対応する予定である。

**`ValidationError.field` について**：現在 `ValidationError` は `BookingViewModel` の空き枠チェック（ViewModel 内ビジネスロジック）でのみ使用されており、`field` パラメータは設定されていない。サーバーサイドの Zod バリデーションエラーはバックエンドから `GraphQLError` として届くが、`extensions.code` の未解析と同様の理由でフィールド名は取得できていない。

### エラー分類の実装フロー

現在のエラー分類は Repository 層の catch ブロックで行われている。

```dart
// TravelPlanRepositoryImpl.getPlans() の例
try {
  return await _remoteDataSource.getTravelPlans(...);
} on SocketException {
  throw const NetworkError();              // 通信断
} on HttpException catch (e) {
  throw NetworkError(e.message...);        // HTTP レベルエラー
} on AppError {
  rethrow;                                 // 既に分類済みの AppError はそのまま再スロー
} catch (e) {
  throw GraphQLError(e.toString()...);     // GraphQL エラーを含むその他
}
```

`GraphQLHttpClient.query()` は GraphQL レスポンスの `errors` フィールドを検出すると `Exception` をスローする。これを Repository の catch ブロックで `GraphQLError` に変換するため、エラー分類ロジックは `TravelPlanRepositoryImpl` に集約されている。

### AsyncStateBuilder との統合

sealed class 導入と同時に作成した `AsyncStateBuilder<T>` ウィジェットが、loading / error / data の 3 状態分岐を共通化している。全 Screen の build() に繰り返されていたボイラープレート（`if (isLoading) ... if (error != null) ...`）が 1 箇所に集約され、エラー表示の一貫性が `AsyncStateBuilder` + `AppErrorWidget` の組み合わせで自動的に保たれている。

リトライボタンの出し分けも `AsyncStateBuilder` 内で完結しており、`onRetry` コールバックは `error is NetworkError` の場合のみ `AppErrorWidget` に渡される。

```dart
// AsyncStateBuilder.build() の抜粋
if (error != null && data == null) {
  return AppErrorWidget(
    error: error!,
    onRetry: error is NetworkError ? onRetry : null,  // NetworkError 以外はリトライ非表示
  );
}
```

### Result 型 / Either 型を選ばなかった理由

Result 型や Either 型は「関数の戻り値」としてエラーを表現するアプローチで、Repository のメソッドが `Future<Result<List<TravelPlan>, AppError>>` のような型を返す設計になる。型安全性は高いが、以下の理由で見送った。

- Riverpod の `AsyncNotifier` は `build()` で `Future<T>` を返し、エラーは `AsyncValue.error` として自動的にハンドリングされる設計になっている。ここに Result 型を重ねると、「AsyncValue のエラー」と「Result のエラー」の二重管理になる
- `dartz` / `fpdart` の `Either` は `fold` / `map` / `flatMap` パターンに習熟が必要で、Riverpod の `copyWith` による State 更新パターンとの統合に追加の設計コストがかかる
- 現在の構成（Repository が例外を throw → ViewModel の catch で AppError に分類 → State に設定）がシンプルで、チームメンバーや AI（Claude Code スキル）にとっても理解しやすい

### state-audit スキルとの連携

sealed class の導入により、`/state-audit` スキルのチェック精度が向上した。`String? error` の時代は「エラーフィールドが null でリセットされているか」程度のチェックしかできなかったが、sealed class になったことで「NetworkError に対してリトライハンドラーが設定されているか」「ValidationError を受け取る画面でフィールド名が表示されているか」といったエラー種別ごとのチェックが可能になっている。

### 将来の拡張性

sealed class は新しいサブクラスを追加するだけで拡張できる。認証機能の導入（ADR-011）に伴い `AuthenticationError` を追加する場合、sealed class に 1 つサブクラスを追加すれば、Dart の網羅性チェックにより全 `switch` 文に対応漏れがコンパイルエラーとして表示される。enum + メッセージ方式や String? では、この「追加時の安全網」が得られない。

## 結果

### 得られたもの

- **リトライボタンの型安全な出し分け**：`AsyncStateBuilder` が `error is NetworkError` を評価して `onRetry` コールバックの有無を切り替える。バリデーションエラーや GraphQL エラーでは自動的にリトライボタンが非表示になる
- **エラーメッセージの具体化**：エラー種別ごとに異なるタイトルとアイコンを `AppErrorWidget` が表示（NetworkError: `wifi_off` / GraphQLError: `error_outline` / ValidationError: `warning_amber_rounded` / UnknownError: `help_outline`）
- **全 Screen のエラー表示の一貫性**：`AsyncStateBuilder` + `AppErrorWidget` により、どの画面でも同じルールでエラーが表示される
- **将来のバックエンド連携基盤**：`GraphQLError.code` / `ValidationError.field` フィールドを設けることで、将来の `extensions.code` パース実装時に API 変更を最小限に抑えられる
- **state-audit / bug-trace スキルの精度向上**：エラー種別が型で表現されているため、スキルがエラーハンドリングの正しさをより正確にチェックできる
- **Widget テストの型安全な検証**：`app_error_widget_test.dart` で各エラー型ごとの UI 表示（アイコン・リトライボタン有無）をテストできている

### トレードオフ

- **全 ViewModel + 全 Screen への変更が必要だった**：`String?` → `AppError?` の変更は 6 ViewModel（PlanList / PlanDetail / Booking / Favorite / BookingHistory / RecentlyViewed）+ 対応する全 Screen + 全テストに波及した。`/test-fix` スキルで一括修復したが、変更量は小さくなかった
- **Repository 層でのエラー分類ロジックの分散**：`SocketException` → `NetworkError`、GraphQL の `errors` フィールド → `GraphQLError` といった分類を `TravelPlanRepositoryImpl` の各メソッドの catch ブロックで行っており、共通ヘルパーに集約する余地がある
- **`GraphQLError.code` が現状常に `null`**：`GraphQLHttpClient` が `extensions` を解析しないため、バックエンドのエラーコード（`VALIDATION_ERROR` / `NOT_FOUND` 等）を活かせていない。認証導入のタイミングで `extensions.code` のパースを実装する予定である
- **サブクラス追加時の全 switch 文への影響**：これはメリット（網羅性チェック）でもあるが、5 つ目・6 つ目のサブクラスを追加すると全 Screen の switch 文に `case` を追加する必要がある。`AppErrorWidget` に集約しているため影響は限定的だが、将来的にエラー種別が増えすぎないよう分類基準を維持する必要がある

## 認証導入時の拡張方針

ADR-011 の認証・認可機能導入に伴い、以下の拡張を予定している。

- `GraphQLHttpClient` を修正して `errors[].extensions.code` を解析し、`GraphQLError` の `code` フィールドに格納する
- `GraphQLError.code` に `UNAUTHENTICATED`（未認証）と `FORBIDDEN`（権限不足）が追加される
- 新しい sealed class サブクラス（`AuthenticationError` 等）を追加するか、既存の `GraphQLError.code` で区別するかは、認証実装時に判断する
- 判断基準：「ユーザーへの対処案内が異なるか」。未認証はログイン画面へのリダイレクトが対処であり、GraphQLError の汎用メッセージとは異なる対処になるため、独立したサブクラスにする可能性が高い

## 参考

- [Dart — Sealed class](https://dart.dev/language/class-modifiers#sealed)
- [Dart — Exhaustiveness checking](https://dart.dev/language/branches#exhaustiveness-checking)
- 本プロジェクトの [ADR-007: MVVM + Repository パターンの採用](./007-mvvm-repository-pattern.md) — ViewModel の State 設計
- 本プロジェクトの [ADR-003: API 通信に GraphQL を採用した理由](./003-graphql-api-design.md) — Zod / Prisma エラーコードとの連携
- 本プロジェクトの [ADR-011: 認証・認可の設計方針](./011-authentication-authorization.md) — 認証エラーの拡張方針
