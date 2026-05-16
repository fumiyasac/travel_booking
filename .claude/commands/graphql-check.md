バックエンドの GraphQL スキーマとモバイルアプリのクエリ/ミューテーションの整合性をチェックしてください。

チェック手順:

1. **バックエンドスキーマを読み込む**
   - `travel_booking_backend/src/graphql/typeDefs.ts` のすべての Type、Query、Mutation を抽出する

2. **モバイル側クエリを読み込む**
   - `travel_booking_mobile/lib/data/datasources/remote/travel_plan_remote_datasource.dart` 内の全クエリ/ミューテーション文字列を抽出する
   - `travel_booking_mobile/assets/graphql/queries.graphql`
   - `travel_booking_mobile/assets/graphql/mutations.graphql`

3. **整合性チェック項目**
   - モバイルが要求しているフィールドがバックエンドスキーマに存在するか
   - Query/Mutation 名がバックエンドの resolver に存在するか
   - 変数の型（`$id: ID!`、`$input: CreateBookingInput!` 等）がスキーマと一致するか
   - バックエンドに定義済みだがモバイルで未使用のフィールドがあるか

4. **結果報告**
   - 問題箇所を日本語で一覧表示する（ファイル名と行番号を含む）
   - 修正が必要な箇所があれば優先度（高/中/低）をつけて提示する
   - 不整合がなければ「整合性OK」と報告する
