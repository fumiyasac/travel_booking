スキーマ変更内容: $ARGUMENTS

上記の変更をこのプロジェクトの全レイヤーに反映してください。
以下のステップを順番に実施し、各ステップ完了後に次へ進んでください。

---

## Step 1: Prisma スキーマ更新
`travel_booking_backend/prisma/schema.prisma` の該当モデルを変更する。
- nullable フィールドは `?` をつける（例: `rating Float?`）
- デフォルト値が必要なフィールドは `@default(...)` を追加する

## Step 2: GraphQL スキーマ更新
`travel_booking_backend/src/graphql/typeDefs.ts` の対応する `type` を更新する。
- nullable フィールドは `!` を外す（例: `rating: Float` で nullable）
- 新しい Input 型が必要な場合は `input XxxxxInput` を追加する

## Step 3: Resolver 更新
`travel_booking_backend/src/graphql/resolvers/` の該当 Resolver を更新する。
- 新フィールドを返却する処理を追加する（Prisma のリレーションフィールドの場合は `include` 指定も必要）

## Step 4: Dart モデル更新
`travel_booking_mobile/lib/data/models/` の対応するモデルクラスを更新する。
以下をすべて更新すること:
- フィールド宣言（nullable の場合は `final Type? fieldName;`）
- コンストラクタ引数（nullable は `this.fieldName,`、必須は `required this.fieldName,`）
- `fromJson`: nullable は `json['key'] as Type?`、非 null は `json['key'] as Type`
- `toJson`: `'key': fieldName`
- `copyWith`: パラメータと返り値に追加

## Step 5: DataSource の GraphQL クエリ更新
`travel_booking_mobile/lib/data/datasources/remote/travel_plan_remote_datasource.dart` 内の
該当クエリ文字列（`static const _getXxxxQuery`）に新フィールドを追加する。

## Step 6: DB マイグレーション実行
Docker が起動していることを確認してから実行する:
```bash
cd travel_booking_backend && npm run db:migrate
```
マイグレーション名は変更内容を表す英語スネークケースで入力する（例: `add_rating_to_reviews`）。

## Step 7: コード再生成
```bash
melos run build_runner
```

## Step 8: 動作確認
- `melos run analyze` で静的解析を通す
- 変更に関連するテストを `melos run test` で確認する
- バックエンドが起動中であれば GraphQL クエリを手動実行して動作確認する

完了後、変更したファイルの一覧と変更内容を日本語でまとめて報告する。
