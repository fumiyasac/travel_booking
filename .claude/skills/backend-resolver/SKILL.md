---
name: backend-resolver
description: |
  TypeScript の GraphQL Resolver と typeDefs エントリを同時生成する。
  schema-update（DB〜Dart 全8ステップ）の「バックエンド TypeScript だけ」軽量版。
  DB マイグレーションも Flutter 側も変更しない。
  以下の発言で自動起動すること：
  - 「Resolver を追加して」
  - 「バックエンドに新しいクエリを追加して」
  - 「GraphQL の Mutation を追加したい」
  - 「typeDefs にエンドポイントを追加して」
  - 「バックエンドだけ変更したい」
argument-hint: "<EntityName> [--query|--mutation|--both]"
allowed-tools:
  - Read
  - Edit
  - Bash
disable-model-invocation: false
---

# backend-resolver — GraphQL Resolver & typeDefs 生成

対象エンティティ: `$ARGUMENTS`

## 前処理（必須）

実行前に必ず Read する：
- `travel_booking_backend/src/graphql/typeDefs.ts`
- `travel_booking_backend/src/graphql/resolvers/planResolver.ts`
- `travel_booking_backend/src/graphql/resolvers/bookingResolver.ts`
- `travel_booking_backend/prisma/schema.prisma`

## 引数

- `$0` = エンティティ名（PascalCase。例: UserReview、TravelTag）
- `--query`    : Query のみ生成（省略時のデフォルト）
- `--mutation` : Mutation のみ生成
- `--both`     : Query と Mutation を両方生成

## Step 1: エンティティの存在確認

`schema.prisma` に `$0` に対応するモデルが存在するか確認する。
存在しない場合は「先に `/schema-update` でモデルを追加してください」と案内して終了。

## Step 2: typeDefs.ts を更新

`references/resolver-template.md` の「typeDefs テンプレート」を Read してから：

- `--query` / `--both`: `type Query` ブロックに追加。
  ページネーション対応クエリは `totalCount / hasNextPage` パターンを踏襲する。
  一覧 Query の Result type（`XxxListResult`）も type ブロックに追加する。
- `--mutation` / `--both`: `type Mutation` ブロックに追加。
  `CreateXxxInput` / `XxxPayload`（success, message, data）パターンを踏襲する。
- 既存 type との重複チェックを行い、重複なら警告して中断する。

## Step 3: Resolver ファイルを生成または更新

`references/resolver-template.md` の「TypeScript Resolver テンプレート」を Read してから：

- **新規エンティティ**: `src/graphql/resolvers/<entityName>Resolver.ts` を新規作成し、
  `src/graphql/resolvers/index.ts` に import と spread を追記する。
- **既存エンティティへの追加**: 該当 Resolver を Read して末尾に追記する。

実装規約（既存コードから把握して踏襲すること）：
- Prisma クライアントは `{ prisma }: Context` で受け取る（`import { Context } from '../../index'`）
- エラーは `GraphQLError` で返す（`extensions: { code: 'NOT_FOUND' }` 付き）
- Mutation は `prisma.$transaction` でラップする
- ページネーション Query は `skip/take + _count` パターンを使う
- 日付フィールドは `.toISOString()` で文字列変換する（`formatXxx()` ヘルパー関数を作る）

## Step 4: TypeScript ビルド確認

```bash
docker compose exec backend npx tsc --noEmit
```

Docker が起動していない場合は「先に `/backend-up` を実行してください」と案内する。

## Step 5: 動作確認

新しく追加した Query / Mutation を curl で実行してレスポンスを表示する。

Query の場合:
```bash
curl -s -X POST http://localhost:4000/graphql \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ xxxList { items { id } totalCount } }"}' | jq .
```

Mutation の場合:
```bash
curl -s -X POST http://localhost:4000/graphql \
  -H 'Content-Type: application/json' \
  -d '{"query":"mutation { createXxx(input: { ... }) { success message } }"}' | jq .
```

## 完了後の案内

以下を必ず表示する：

```
✅ backend-resolver 完了

次のステップ:
- /graphql-check  → Flutter 側との整合性確認を推奨します
- /schema-update  → DB スキーマ変更も必要な場合はこちらを使ってください

使い分け早見表:
  バックエンド TS のみ変更 → /backend-resolver
  DB〜Flutter まで全変更  → /schema-update
```
