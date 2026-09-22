---
name: backend-resolver
description: |
  TypeScript の GraphQL Resolver と typeDefs エントリを同時生成する。
  schema-update（DB〜Dart 全8ステップ）の「バックエンド TypeScript だけ」軽量版。
  DB マイグレーションも Flutter 側も変更しない。
  --middleware オプションで Apollo Server プラグイン / Express ミドルウェアの
  雛形生成にも対応する。
  以下の発言で自動起動すること：
  - 「Resolver を追加して」
  - 「バックエンドに新しいクエリを追加して」
  - 「GraphQL の Mutation を追加したい」
  - 「typeDefs にエンドポイントを追加して」
  - 「バックエンドだけ変更したい」
  - 「ミドルウェアを追加したい」
  - 「ヘルスチェックを追加して」
  - 「リクエストのログを取りたい」
  - 「レート制限を追加したい」
argument-hint: "<EntityName> [--query|--mutation|--both] | --middleware <名前>"
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

## 完了後の案内（Resolver モード）

以下を必ず表示する：

```
✅ backend-resolver 完了

次のステップ:
- /graphql-check  → Flutter 側との整合性確認を推奨します
- /schema-update  → DB スキーマ変更も必要な場合はこちらを使ってください

使い分け早見表:
  GraphQL Resolver 追加       → /backend-resolver <Entity>
  ミドルウェア追加             → /backend-resolver --middleware <名前>
  DB〜Flutter まで全変更      → /schema-update
```

---

## ミドルウェア追加モード（--middleware）

> **Resolver モードとの排他**: `--middleware` と `--query` / `--mutation` / `--both` は同時指定不可。

### 引数

- `--middleware <名前>`: ミドルウェア名（例: `healthCheck`, `rateLimit`, `requestLogger`）

### Middleware Step 1: サーバー構成を Read する

`src/index.ts` を Read して以下を把握する：
- Apollo Server の起動方式（`startStandaloneServer` / `expressMiddleware`）
- 既存プラグインの有無（`plugins:` 配列）
- 依存パッケージ（`package.json` も Read する）

> **重要**: 現在のサーバーが `startStandaloneServer`（Express なし）を使っている場合、
> Express ミドルウェア（`app.use` / `app.get`）を追加するには `expressMiddleware` への
> 移行が必要になる。Middleware Step 2 でユーザーに確認を取ること。

### Middleware Step 2: ミドルウェアの種類を判定してユーザーに確認する

`references/middleware-template.md` を Read してから、名前でミドルウェア種別を判定する：

| 名前のパターン | 種別 | 必要な変更 |
|---|---|---|
| `healthCheck` / `cors` / `static` | Express ミドルウェア | `startStandaloneServer` → `expressMiddleware` への移行が必要 |
| `rateLimit` | Express ミドルウェア | 同上 + `express-rate-limit` のインストール |
| `requestLogger` / `cache` / `auth` | Apollo Server プラグイン | 現状の構成のまま追加可能 |

Express への移行が必要な場合は以下を表示してからユーザーに確認を取る：

```
現在のサーバーは startStandaloneServer（Express なし）で起動しています。
<名前> は Express ミドルウェアとして実装するため、expressMiddleware への移行が必要です。

変更内容:
  src/index.ts を startStandaloneServer → expressMiddleware + Express に書き換えます
  npm install express @types/express が必要です

続行してよいですか？
```

Apollo プラグインの場合は確認なしで Step 3 へ進む。

### Middleware Step 3: ミドルウェアファイルを生成する

配置先: `src/middleware/<名前>.ts`

`references/middleware-template.md` の対応テンプレートを使って生成する。
ファイル内の `// ここを <MiddlewareName> に置換` コメントを実際の名前に置き換えること。

### Middleware Step 4: サーバーに登録する

**Apollo プラグインの場合**: `src/index.ts` の `ApolloServer` コンストラクタに追記する：

```typescript
const server = new ApolloServer<Context>({
  typeDefs,
  resolvers,
  plugins: [
    requestLoggerPlugin,  // ← 追加（import も追記する）
  ],
  formatError: /* 既存のまま */,
});
```

**Express ミドルウェアの場合（移行後）**: `src/index.ts` の `app.use()` / `app.get()` に追記する：

```typescript
app.use(rateLimitMiddleware);    // 全ルートに適用
app.get('/health', healthCheck); // 特定パスに適用
```

### Middleware Step 5: 必要なパッケージをインストールする

```bash
cd travel_booking_backend
# Express 移行が必要な場合
npm install express @types/express

# express-rate-limit が必要な場合
npm install express-rate-limit @types/express-rate-limit

# pino（構造化ログ）が必要な場合
npm install pino @types/pino
```

Docker コンテナにも反映する（コンテナが起動中の場合）：
```bash
docker compose exec backend npm install <パッケージ名>
```

### Middleware Step 6: 型チェックと動作確認

```bash
# 型エラーなし確認
docker compose exec backend npx tsc --noEmit

# ヘルスチェックエンドポイントの確認（Express 移行後）
curl -s http://localhost:4000/health | jq .

# Apollo プラグインの確認（ログ出力をリクエスト後に確認）
curl -s -X POST http://localhost:4000/graphql \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ travelPlans { plans { id } totalCount } }"}' > /dev/null
docker compose logs backend --tail=20
```

Docker が起動していない場合は「先に `/backend-up` を実行してください」と案内する。

### 完了後の案内（ミドルウェアモード）

```
✅ --middleware 完了

追加したミドルウェア: <名前>
生成ファイル: src/middleware/<名前>.ts

使い分け早見表:
  GraphQL Resolver 追加       → /backend-resolver <Entity>
  ミドルウェア追加             → /backend-resolver --middleware <名前>
  DB〜Flutter まで全変更      → /schema-update
```
