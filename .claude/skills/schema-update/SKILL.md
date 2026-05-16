---
name: schema-update
description: |
  Prisma スキーマへの変更を DB から Dart まで全レイヤーに反映する。
  schema.prisma → typeDefs.ts → Resolver → Dart モデル → DataSource クエリ →
  DB マイグレーション → build_runner の全 8 ステップをガイドして実施する。
  「フィールドを追加したい」「スキーマを変更したい」「モデルに〜を追加して」
  「DB の構造を変えたい」「新しいカラムを追加して」などのリクエストで使用する。
argument-hint: "変更内容の説明 (例: TravelPlanにratingCountフィールドを追加)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# schema-update — 全レイヤースキーマ変更

変更内容: `$ARGUMENTS`

Prisma スキーマの変更を全レイヤーに反映します。
各レイヤーの詳細な変更ルール: `references/layer-guide.md` を参照。

## 実行前の確認

### 1. 現状把握

変更に関わるファイルを読み込む：
```
Read: travel_booking_backend/prisma/schema.prisma
Read: travel_booking_backend/src/graphql/typeDefs.ts
```

対象モデルと変更内容を確認してから各ステップに進む。

### 2. Docker 起動確認（Step 6 の事前準備）

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && docker-compose ps | grep mysql
```

`healthy` でない場合は `backend-up` スキルを先に実行するよう案内する。

---

## Step 1: Prisma スキーマ更新

`travel_booking_backend/prisma/schema.prisma` の対象モデルにフィールドを追加・変更する。

ルール（詳細: `references/layer-guide.md#step1`）:
- nullable: `fieldName Type?`
- non-null + デフォルト値: `fieldName Type @default(value)`
- non-null（既存データなし）: `fieldName Type` のみ

## Step 2: GraphQL スキーマ更新

`travel_booking_backend/src/graphql/typeDefs.ts` の対応 Type を更新する。

ルール:
- Prisma の `Type?` → GraphQL の `Type`（`!` なし）
- Prisma の `Type` → GraphQL の `Type!`（`!` あり）

## Step 3: Resolver 更新

`travel_booking_backend/src/graphql/resolvers/` の対応 Resolver を更新する。

ルール:
- 計算フィールド（`availableSpots` 等）は Resolver に処理を追加
- リレーションフィールドは `include: { relation: true }` を Prisma クエリに追加

## Step 4: Dart モデル更新

対応する `travel_booking_mobile/lib/data/models/xxx.dart` を更新する。

更新箇所（詳細: `references/layer-guide.md#step4`）:
1. フィールド宣言
2. コンストラクタ引数
3. `fromJson` のパース処理
4. `toJson` の変換処理
5. `copyWith` のパラメータ

## Step 5: DataSource クエリ更新

`travel_booking_mobile/lib/data/datasources/remote/travel_plan_remote_datasource.dart` の
該当クエリ文字列に新フィールドを追加する。

## Step 6: DB マイグレーション実行

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && npm run db:migrate
```

マイグレーション名の例: `add_review_count_to_travel_plans`

## Step 7: コード再生成

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run build_runner
```

## Step 8: 動作確認

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run analyze
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run test
```

---

## 完了報告

変更したファイル一覧と変更内容を日本語でまとめて報告する。
