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
