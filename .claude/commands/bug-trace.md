エラー内容: $ARGUMENTS

上記のエラーを分析し、このプロジェクトのコードでバグが発生している箇所を特定して修正してください。

## 調査手順

### 1. エラー種別の判定
以下のパターンで分類する:

**Riverpod / コード生成系**
- `The getter 'xxxProvider' isn't defined` → `melos run build_runner` で `.g.dart` を再生成（手順を案内して実行）
- `ProviderNotFoundException` → `ProviderScope` のラップ漏れまたは `overrides` 設定ミス

**GraphQL 通信系**
- `Exception: GraphQL request failed: 4xx/5xx` → `travel_booking_backend/src/graphql/` の resolver を確認
- `Exception: フィールド名 is not defined` → `typeDefs.ts` と DataSource のクエリ文字列の不一致
- `Connection refused` / `SocketException` → Docker が起動しているか確認、`graphql_config.dart` の `_baseUrl` を確認

**JSON パース系**
- `Null check operator used on a null value` → `TravelPlan.fromJson` や他モデルの `as String` キャストを確認（nullable は `as String?` に変更）
- `type 'Null' is not a subtype of type 'xxx'` → `fromJson` の型キャスト漏れ

**Navigation 系**
- `GoException: No routes for location` → `core/router/app_router.dart` のルートパス定義と `context.go(path)` の一致を確認

**State 管理系**
- 状態が更新されない → `copyWith` の引数指定漏れ、または `clearError: true` の使い忘れ
- 無限ローディング → `isLoading: false` セットが success/error 両方のパスで実行されているか確認

### 2. コードの特定と確認
エラーのスタックトレースからファイルパスと行番号を抽出して該当コードを読み込む。

### 3. 修正の実施
- 原因を日本語で説明する（ファイルパス:行番号 を明示）
- 修正を実施する
- 同様のバグが他の箇所にも潜んでいないか検索する

### 4. 修正後の確認
- `melos run analyze` で静的解析を通す
- 関連するテストがある場合は `melos run test` で確認する
