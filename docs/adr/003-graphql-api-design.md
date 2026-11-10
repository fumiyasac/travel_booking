# ADR-003: API 通信に GraphQL を採用した理由

## ステータス

承認済み

## 日付

2026-10-04

## 背景

旅行プランの閲覧・検索・予約を提供する Flutter アプリのバックエンド API を設計するにあたり、通信方式の選定が必要だった。

このアプリでは以下のようなデータ取得パターンがある。

- **プラン一覧**：フィルタ（カテゴリ・地域・難易度・価格帯・キーワード）+ ソート + ページネーションの組み合わせ
- **プラン詳細**：1 つのプランに対して、基本情報・画像一覧・ハイライト・旅程（日ごとのアクティビティをネスト）・含まれるもの/含まれないもの・レビュー・地図情報（座標・集合場所）を一度に取得する必要がある
- **予約操作**：作成・キャンセルのミューテーションと、空き枠カウントの更新をアトミックに実行する必要がある
- **予約履歴**：メールアドレスで絞り込んだ予約一覧に、紐づくプラン情報も含めて取得する

また、バックエンドは Node.js + Prisma + MySQL の構成で構築することを先に決定しており、ORM の選定が API 設計にも影響を与えた。

## 検討した選択肢

### 1. GraphQL（Apollo Server）（採用）

1 つのエンドポイント（`POST /graphql`）で、クライアントが必要なフィールドだけを指定して取得する。スキーマ（SDL）で型を宣言的に定義し、Resolver がデータ取得ロジックを担当する。Prisma との連携が自然で、`include` オプションによるリレーションの Eager Load と相性が良い。

### 2. REST API

リソースごとにエンドポイントを分ける従来型の設計。`GET /api/plans`、`GET /api/plans/:id`、`POST /api/bookings` のように URL でリソースを表現する。Express + Prisma で実装する場合は、ルーティングとコントローラーを手書きで定義する。

### 3. tRPC

TypeScript の型をサーバーとクライアントで共有する RPC フレームワーク。型安全性が高いが、クライアントが TypeScript であることが前提となる。Flutter（Dart）との組み合わせでは型共有の恩恵を受けられない。

### 4. gRPC

Protocol Buffers でスキーマを定義し、バイナリ通信で高速なデータ転送を行う。マイクロサービス間通信には適しているが、Flutter アプリとの直接通信にはプロキシ層が必要になる場合があり、このプロジェクトの規模ではオーバースペック。

## 決定

**GraphQL（Apollo Server 5）を採用する。** クライアント側は `graphql_flutter` パッケージは使用せず、`dart:io` の `HttpClient` で GraphQL リクエストを直接送信する構成とする。

入力バリデーションには Zod を採用し、`graphql/validations/` ディレクトリに `schemas.ts`・`validate.ts`・`prismaErrorMapper.ts` の 3 ファイルからなる検証レイヤーを設ける。予約操作（作成・キャンセル）は `prisma.$transaction` でアトミックに実行する。

## 理由

### 過去の業務経験と Prisma との親和性

以前の業務で GraphQL を使用した経験があり、スキーマ定義からリゾルバ実装までの開発フローに習熟していた。加えて、バックエンドの ORM に Prisma を採用することを先行して決定しており、Prisma の `include` によるリレーション一括取得と GraphQL の「クライアントが必要なフィールドを指定する」設計思想が自然に噛み合った。

実際に `planResolver.ts` の `PLAN_INCLUDE` 定数は、images・highlights・itinerary（activities をネスト）・includedItems・excludedItems・reviews の 6 つのリレーションを Eager Load しており、Prisma と GraphQL の組み合わせがデータ取得の設計をシンプルにしている。

```ts
const PLAN_INCLUDE = {
  images: { orderBy: { displayOrder: 'asc' as const } },
  highlights: true,
  itinerary: {
    orderBy: { dayNumber: 'asc' as const },
    include: { activities: true },
  },
  includedItems: true,
  excludedItems: true,
  reviews: { orderBy: { createdAt: 'desc' as const } },
};
```

### 必要なデータだけを取得できるメリット

プラン詳細画面（`PlanDetailScreen`）は 1 つの画面で表示に必要なデータが多い。基本情報に加えて、画像一覧・ハイライト・旅程（日ごとのアクティビティをネスト）・含まれるもの/含まれないもの・レビュー・地図座標・集合場所をすべて 1 回のリクエストで取得している。

REST API であれば、これを実現するには以下のいずれかが必要になる。

- `/api/plans/:id` に全リレーションを含めた巨大なレスポンスを返す（over-fetching）
- `/api/plans/:id/images`、`/api/plans/:id/reviews` 等を個別に呼ぶ（複数リクエスト）
- `?include=images,reviews,itinerary` のようなクエリパラメータで制御する（独自仕様）

GraphQL であればクライアント側のクエリ文字列で必要なフィールドを宣言するだけで済み、REST API の上記 3 パターンのいずれかを選ぶ設計判断自体が不要になる。

### 1 エンドポイントでの統一的なデータ取得

`POST /graphql` の 1 エンドポイントに Query / Mutation を集約する設計により、モバイル側の `GraphQLHttpClient` が 1 クラスで全通信を担当できている。REST API であればエンドポイントごとに URL・HTTP メソッド・レスポンス形式が異なるが、GraphQL ではすべて同じ形式（`query` / `variables` の JSON）で統一される。

モバイル側の `TravelPlanRemoteDataSource` は 5 つの GraphQL 操作文字列定数（`GetTravelPlans`・`GetTravelPlan`・`CreateBooking`・`CancelBooking`・`GetBookings`）を Dart の文字列定数として保持しており、変数は `variables` フィールドに Map として渡している。

この統一性は、Claude Code カスタムスキル（`/schema-update`・`/backend-resolver`・`/graphql-check`）がバックエンドとモバイルの整合性をチェックする際にも有利に働いている。GraphQL スキーマ（`typeDefs.ts`）が「信頼できる情報源」として機能し、型定義を起点に整合性を確認できるためである。

### ページネーションのシンプルさ

プラン一覧のページネーションは `TravelPlansResult` というラッパー型で `plans` / `totalCount` / `hasNextPage` / `currentPage` / `totalPages` をまとめて返す設計にしている。REST API の場合、ページネーション情報を `Link` ヘッダに含めるか、レスポンスボディに含めるか、`X-Total-Count` カスタムヘッダを使うかといった設計判断が必要になるが、GraphQL ではレスポンスの型定義に含めるだけで済む。

モバイル側では `PlanFilter` モデルの `toGraphQLVariables()` メソッドが Dart オブジェクトを GraphQL 変数（`PlanFilterInput` の 9 フィールド：keyword / category / region / minPrice / maxPrice / maxDuration / difficulty / sortBy / sortOrder）にそのまま変換しており、REST API の場合に必要になるクエリ文字列の組み立てより直感的にフィルタを扱えている。

### Zod バリデーション層による入力検証の集約

`graphql/validations/` に以下の 3 ファイルからなる検証レイヤーを設けることで、Resolver のコアロジックとバリデーション処理を分離している。

| ファイル | 役割 |
|---|---|
| `schemas.ts` | `planFilterSchema`・`createBookingSchema`・`paginationSchema` の 3 つの Zod スキーマを定義 |
| `validate.ts` | Zod スキーマを受け取り、バリデーション失敗時に `GraphQLError`（`extensions.code: 'VALIDATION_ERROR'`）をスローするユーティリティ |
| `prismaErrorMapper.ts` | Prisma エラーコード（P2002: 重複・P2025: Not Found）を `GraphQLError` と extension code にマッピング |

`planFilterSchema` は `category` と `difficulty` を `z.enum` で制約し、`minPrice <= maxPrice` を `.refine` でクロスフィールドバリデーションしている。`paginationSchema` は `pageSize` のデフォルト値を 20、上限を 50 に制限している。

### 予約操作のアトミック実行

`createBooking` と `cancelBooking` の両ミューテーションは `prisma.$transaction` を使用し、予約レコードの作成・更新と `TravelPlan.currentBookings` のインクリメント・デクリメントを 1 つのトランザクションにまとめている。これにより、予約作成後にサーバーがクラッシュしても `currentBookings` が不整合な状態に留まらないことが保証されている。

```ts
const result = await prisma.$transaction(async (tx) => {
  // 1. プラン取得・空き枠チェック
  // 2. 予約レコード作成
  // 3. currentBookings インクリメント
  return booking;
});
```

### GraphQL + 認証の組み合わせへの挑戦

個人的な技術的関心として、GraphQL と認証（JWT）を組み合わせた実装を試したいという動機もあった。Apollo Server の Context にユーザー情報を注入し、Resolver レベルで認可を制御する設計は、REST API のミドルウェア認証とは異なるアプローチであり、この機会に実践しておきたいと考えた。

現時点では認証は未実装（`customerEmail` がハードコード）だが、Apollo Server の Context 機構（`context: async () => ({ prisma })`）は既に稼働しており、ここに `currentUser` を追加する形で認証を導入する設計が見えている。

### graphql_flutter を使わなかった理由

Flutter 側のクライアントには `graphql_flutter` パッケージではなく、`dart:io` の `HttpClient` を直接使用している。理由は以下の通り。

- `graphql_flutter` はキャッシュ層や `Query` / `Mutation` ウィジェットなど独自の仕組みを持っており、Riverpod の状態管理と責務が重複する
- `HttpClient` で直接送信する構成であれば、GraphQL は「JSON を POST するだけ」という単純な通信として扱え、`GraphQLHttpClient` 1 クラスに通信ロジックを集約できる
- テスト時に `GraphQLClientInterface`（`abstract interface class`）に差し替えるだけで mock 化でき、`graphql_flutter` 固有の `GraphQLClient` や `Link` チェーンの設定が不要

## 結果

### 得られたもの

- **プラン詳細画面の効率的なデータ取得**：1 クエリで 6 つのリレーション（images / highlights / itinerary[+activities] / includedItems / excludedItems / reviews）を必要なフィールドだけ取得できている
- **フィルタ + ページネーションの宣言的な設計**：`PlanFilterInput` の 9 フィールドを GraphQL 変数で渡すだけの統一的なインターフェース。`PlanFilter.toGraphQLVariables()` がフロントエンドとバックエンドの橋渡しをしている
- **スキーマが信頼できる情報源になる**：`typeDefs.ts` が Mobile ↔ Backend の契約書として機能し、`/graphql-check` スキルで整合性を検証できている
- **Zod + GraphQL エラーの統合**：`schemas.ts` と `prismaErrorMapper.ts` により、入力バリデーションエラーと DB エラーの両方が `extensions.code` を持つ `GraphQLError` に統一されている。モバイル側では `GraphQLError` サブクラスに分類して表示できる
- **トランザクションによる整合性保証**：予約作成・キャンセル時の `currentBookings` 更新が `prisma.$transaction` でアトミックに実行される
- **認証導入への拡張性**：Context 機構が認証情報の注入口として設計済み

### トレードオフ

- **N+1 問題のリスク**：Resolver 内で `PLAN_INCLUDE` を使った Eager Load で対処しているが、リレーションが増えると DataLoader の導入が必要になる可能性がある
- **HTTP 200 でエラーが返る設計**：GraphQL は通信成功時に常に HTTP 200 を返し、エラーは `errors` フィールドに含まれる。モバイル側でレスポンスの `errors` フィールドを解析して `sealed class AppError`（`NetworkError` / `GraphQLError` / `ValidationError`）に分類する処理が必要になった。REST API であれば HTTP ステータスコードで分岐できるため、エラーハンドリングはよりシンプルになる
- **学習コスト**：SDL でのスキーマ定義、Resolver の実装パターン、Zod スキーマと GraphQL 型の 1:1 対応管理など、REST API に比べて初期の学習コストが高い。ただし、過去の業務経験でこのコストは既に回収済みだった
- **スキーマ変更時のレイヤー横断的な影響**：フィールドを 1 つ追加するだけで、Prisma スキーマ → `typeDefs.ts` → Resolver → `schemas.ts`（Zod） → Dart モデル → DataSource のクエリ文字列 → テストの 7 レイヤーに変更が必要になる。この複雑さは `/schema-update` スキルで自動化して対処している

## 参考

- [Apollo Server 5 ドキュメント](https://www.apollographql.com/docs/apollo-server/)
- [Prisma + GraphQL の統合ガイド](https://www.prisma.io/graphql)
- [GraphQL 公式 — Pagination](https://graphql.org/learn/pagination/)
- 本プロジェクトの [architecture_guidance.md](../../architecture_guidance.md) — §3 Backend アーキテクチャ、§4 Mobile ↔ Backend 通信設計
