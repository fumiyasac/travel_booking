# バグエラーパターン辞書

## 1. Riverpod / コード生成系

| エラーメッセージ | 原因 | 修正手順 |
|---|---|---|
| `The getter 'xxxProvider' isn't defined for the class` | `.g.dart` の再生成が必要 | `melos run build_runner` を実行 |
| `ProviderNotFoundException: No provider found for XxxxProvider` | `ProviderScope` でラップされていない、または `overrides` で Provider が指定されていない | `ProviderScope` のラップを確認、テストなら `ProviderContainer(overrides: [...])` を確認 |
| `_$XxxxViewModel is not a mixin` | `part 'xxx.g.dart'` の記述が `_$XxxxViewModel` の参照より後にある | ファイル上部に `part` 宣言を移動 |
| `The class 'XxxxViewModel' doesn't implement '_$XxxxViewModel'` | `extends` の記述ミス（`extends _$XxxxViewModel` が必要） | クラス定義を修正 |

**共通対処:**
```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run build_runner
```

---

## 2. GraphQL 通信系

| エラーメッセージ | 原因 | 修正手順 |
|---|---|---|
| `Exception: GraphQL request failed: 400` | クエリ文字列のシンタックスエラーまたはスキーマ不整合 | `graphql-check` スキルを実行 |
| `Exception: GraphQL request failed: 500` | バックエンド Resolver のエラー | `docker-compose logs backend` でログ確認 |
| `Exception: フィールド名 Cannot query field` | typeDefs に存在しないフィールドを要求 | `typeDefs.ts` にフィールドを追加 |
| `SocketException: Connection refused` | Docker が起動していないまたは IP アドレス違い | `backend-up` スキルを実行、または `fix-endpoint` スキルで IP を確認 |
| `SocketException: Failed host lookup` | DNS 解決失敗（実機でのホスト名解決エラー） | `fix-endpoint` で IP アドレスに変更 |
| `HandshakeException: Connection terminated` | ATS エラー（iOS で `http://` をブロック） | `ios/Runner/Info.plist` に `NSAllowsArbitraryLoads` を追加 |

---

## 3. JSON パース系

| エラーメッセージ | 原因 | 修正手順 |
|---|---|---|
| `Null check operator used on a null value` | `fromJson` で `as String`（non-null キャスト）しているが値が `null` | `as String?` に変更し nullable 処理を追加 |
| `type 'Null' is not a subtype of type 'String'` | 同上（型エラーとして表出） | `as String?` に変更 |
| `type 'int' is not a subtype of type 'double'` | GraphQL の `Int` 型を Dart で `double` にキャストしようとしている | `(json['price'] as num).toDouble()` パターンに変更 |
| `FormatException: Invalid date format` | `DateTime.parse()` に不正な文字列が渡された | `DateTime.tryParse()` に変更し null チェックを追加 |

**fromJson の安全なパターン:**
```dart
// NG: クラッシュする
title: json['title'] as String,

// OK: null 安全
title: json['title'] as String? ?? '',
// または
title: json['title'] as String,  // APIが必ず返す保証がある場合のみ

// 数値
price: (json['price'] as num).toDouble(),

// 日時
createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),

// リスト
tags: (json['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ?? [],
```

---

## 4. Navigation 系（go_router）

| エラーメッセージ | 原因 | 修正手順 |
|---|---|---|
| `GoException: No routes for location: /xxx` | `app_router.dart` にルートパスが未定義 | `GoRoute(path: '/xxx', ...)` を追加 |
| `GoException: Error in route matching` | `extra` パラメータの型ミスマッチ | `state.extra as Map<String, dynamic>` の型キャストを確認 |
| `Context is not a Router context` | `context.go()` を Widget ツリー外から呼び出している | `mounted` チェックを追加、またはルート変数に保持 |

**app_router.dart の確認:**
```
Read: travel_booking_mobile/lib/core/router/app_router.dart
```

---

## 5. State 管理系

| 症状 | 原因 | 修正手順 |
|---|---|---|
| ローディングが終わらない | `catch` ブロックで `isLoading: false` の `copyWith` が抜けている | エラーパスの `copyWith` に `isLoading: false` を追加 |
| エラーが消えない | `clearError: true` を渡していない | `state = state.copyWith(clearError: true)` を呼ぶ |
| 状態が更新されない | `copyWith` の引数名ミスタイプ | `copyWith` のパラメータ名を確認 |
| 画面が再描画されない | `ref.watch` の代わりに `ref.read` を使っている | `build()` 内では `ref.watch` を使う |
| メモリリーク疑い | `StreamSubscription` が `cancel()` されていない | `ref.onDispose(() => _subscription?.cancel())` を追加 |

---

## 6. preview-setup 関連（Widgetbook）

| エラーメッセージ | 原因 | 修正手順 |
|---|---|---|
| `No WidgetbookApp found` / `Could not find an annotation of type App` | `lib/preview/main.dart` に `@widgetbook.App()` が未設定、または `widgetbook_generator` が `dev_dependencies` にない | `lib/preview/main.dart` の `@widgetbook.App()` アノテーションを確認 → `pubspec.yaml` の `dev_dependencies` に `widgetbook_generator: ^3.x` があるか確認 → `melos run build_runner` を再実行。解消しない場合は `/preview-setup --init` を実行 |
| `The argument type 'XXX' can't be assigned to the parameter type 'Override'` | `mock_providers.dart` の override 定義が Riverpod 3.x の `ProviderScope.overrides` 構文と不一致 | 対象 Provider の型定義を Read で確認 → `.overrides([xxxProvider.overrideWith((ref) => ...)])` 形式に修正。`overrideWithValue` は廃止されているため `overrideWith` に統一 |
| `GoException: no routes for location: /xxx`（Preview 内） | Preview 用 GoRouter に遷移先ルートが未定義（本番の `app_router.dart` を流用しているためリダイレクト先が見つからない） | Preview ファイル内で `_previewRouter`（空の `GoRoute(path: '/', ...)` のみ）を定義し `MaterialApp.router(routerConfig: _previewRouter, ...)` で使用。`/preview-setup <Screen名>` を再実行すると正しい構成で上書きできる |
| `The named parameter 'xxx' isn't defined`（`mock_data.dart`） | `TravelPlan` / `Booking` モデルにフィールドが追加されたが `mock_data.dart` の定数が更新されていない | `lib/data/models/` の最新コンストラクタを Read → `mock_data.dart` の `_makePlan()` ヘルパーおよび各定数に不足フィールドを追記 → `melos run build_runner` を実行 |

**共通対処:**
```bash
# Widgetbook コード再生成
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run build_runner
# Preview 環境の静的解析
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run analyze
```

---

## 7. backend-resolver 関連（TypeScript / GraphQL）

| エラーメッセージ | 原因 | 修正手順 |
|---|---|---|
| `Type 'XXX' is not assignable to type 'Resolver'` / `Property 'xxx' does not exist on type 'PrismaClient'` | `typeDefs.ts` と Resolver の引数型が不一致、または `schema.prisma` に存在しないモデルを参照している | `typeDefs.ts` の型定義を Read → Resolver の引数型・戻り値型と照合 → `schema.prisma` のモデル名・フィールド名を確認。`/backend-resolver` を再実行すると正しいテンプレートが生成される |
| `Transaction API error: Transaction already closed` / `PrismaClientKnownRequestError: P2002` | `$transaction` 内で `await` が抜けているか、`@@unique` 制約違反 | `$transaction` 内の全処理に `await` が付いているか確認 → unique 制約違反の場合は `schema.prisma` の `@@unique` を Read → 投入データの重複を排除 |
| `Type 'XXX' was defined more than once` | `/backend-resolver` で追加した type が既存 `typeDefs.ts` の定義と名前衝突 | `typeDefs.ts` 全体を Read → `grep -n "type XXX"` で重複箇所を特定 → リネームまたは定義を統合 |
| `Cannot connect to the Docker daemon` / `Error response from daemon: Container xxx is not running` | `docker compose up -d` が未実行でバックエンドが起動していない | `/backend-up` を実行して Docker サービスを起動 |

**共通対処:**
```bash
# TypeScript ビルドチェック（エラーがないか確認）
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && npx tsc --noEmit
# バックエンドログ確認
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && docker compose logs backend --tail=50
```
