# ADR-011: 認証・認可の設計方針

## ステータス

提案中

## 日付

2026-11-11

## 背景

現在のアプリでは認証機構が存在せず、予約履歴の取得に使用する `customerEmail` が `BookingHistoryScreen` に `const _kCustomerEmail = 'test@example.com'` としてハードコードされている。「誰の予約か」を区別できない状態にある。なお、予約作成フォーム（`BookingViewModel`）の `customerEmail` はフォーム入力フィールドとして空文字で初期化されており、ユーザーが入力する設計になっているが、ログインユーザーのプロフィールから自動入力する仕組みがない。

認証を導入することで以下が実現できる。

- 予約が「自分の予約」になり、予約履歴が実用的になる
- 予約ウィザードの旅行者情報（名前・メールアドレス）がプロフィールから自動入力される
- 将来的にユーザーごとのレコメンドやレビュー投稿の基盤になる

一方、以下の既存機能は認証なしで引き続き動作させる。

- プラン一覧の閲覧・検索・フィルタ（未ログインでも利用可能）
- お気に入り（端末ローカルの SharedPreferences に保存。アカウント紐づけは行わない）
- 最近見たプラン（端末ローカルのまま）

### 現行の技術構成

認証設計に影響する現行の構成は以下の通り。

**バックエンド：**
- Apollo Server 5（Express ミドルウェア構成 — `@as-integrations/express4`）
- Context: `{ prisma: PrismaClient }` で全 Resolver に PrismaClient を注入済み
- ミドルウェア: healthCheck（Express）/ graphqlRateLimiter（Express）/ requestLogger（Apollo Plugin）が稼働中
- Zod バリデーション: Resolver の入力検証が `validate()` ヘルパーで型宣言的に実装済み

**モバイル：**
- `GraphQLHttpClient`（`dart:io HttpClient` ベース、`GraphQLClientInterface` でインターフェース化済み）が全通信を担当
- GoRouter 18.x で `StatefulShellRoute.indexedStack` によるボトムナビ 3 タブ構成
- `flutter_secure_storage` は未導入（SharedPreferences のみ）

## 検討した選択肢

### 認証方式

#### 1. JWT（JSON Web Token）認証（採用）

サーバーがログイン時に JWT を発行し、モバイル側がリクエストの `Authorization` ヘッダに付与する。サーバーは各リクエストでトークンを検証し、デコードしたユーザー情報を Apollo Context に乗せる。ステートレスでスケーラブル。

#### 2. セッション認証

サーバー側にセッション情報を保持し、Cookie でセッション ID を管理する。モバイルアプリでは Cookie の管理が煩雑で、`dart:io HttpClient` との相性も良くない。

#### 3. Firebase Authentication

Google の認証基盤を使い、ID トークンをバックエンドで検証する。認証フロー自体は簡単だが、Firebase への依存が増え、自前バックエンド（Apollo Server + Prisma）との統合に追加の設計が必要。

### トークン保存場所（モバイル側）

#### 1. flutter_secure_storage（採用）

iOS は Keychain、Android は EncryptedSharedPreferences を使う暗号化ストレージ。JWT のような秘密情報の保存に適している。

#### 2. SharedPreferences

現在お気に入りや閲覧履歴で使用しているが、暗号化されないため JWT の保存には不適切。

### Resolver の認可チェック方式

#### 1. ヘルパー関数方式（採用）

`requireAuth(context)` ヘルパーを作り、認証が必要な Resolver の先頭で呼ぶ。認証されていなければ GraphQL エラーを throw する。既存の Resolver に 1 行追加するだけで済み、最もシンプル。

#### 2. GraphQL ディレクティブ方式

`@auth` ディレクティブをスキーマに定義し、ディレクティブトランスフォーマーで認可を処理する。型安全だがセットアップが重く、このプロジェクトの規模ではオーバースペック。

#### 3. Apollo Server プラグイン方式

`requestDidStart` プラグインで全リクエストに認可チェックを入れる。全 Query/Mutation に一律で適用されるため、未ログインでも閲覧可能な `travelPlans` / `travelPlan` クエリとの使い分けが難しい。

## 決定

### 認証方式

**JWT 認証を採用する。** Authorization ヘッダからトークンを検証し、Apollo Server の Context にユーザー情報を乗せる。

### 全体設計

```
認証フロー:
  1. ユーザーが email + password でログイン（Mutation: login）
  2. サーバーが JWT を発行して返す
  3. モバイルが flutter_secure_storage にトークンを保存
  4. 以降のリクエストで Authorization: Bearer <token> を付与
  5. サーバーが Express ミドルウェアでトークンを検証
  6. デコードした currentUser を Context に注入
  7. Resolver が context.currentUser を参照
```

### 認可ルール

| オペレーション | 認証 | 認可ルール |
|---|---|---|
| `travelPlans` (一覧) | 不要 | 誰でも閲覧可能 |
| `travelPlan` (詳細) | 不要 | 誰でも閲覧可能 |
| `createBooking` | **必要** | ログインユーザーのみ |
| `cancelBooking` | **必要** | 自分の予約のみキャンセル可 |
| `bookings` (履歴) | **必要** | 自分の予約のみ取得可 |
| `login` | 不要 | — |
| `register` | 不要 | — |

## 理由

### JWT + Express ミドルウェアが現行構成に最も馴染む

現在の Apollo Server は Express ミドルウェア構成（`@as-integrations/express4`）で稼働しており、healthCheck と graphqlRateLimiter が既に Express レイヤーで動作している。JWT の検証もこの Express レイヤーに薄いミドルウェアを 1 つ追加するだけで実現でき、既存のミドルウェアチェーン（graphqlRateLimiter → auth → expressMiddleware）に自然に組み込める。

Context の拡張も最小限で、現在の `{ prisma }` に `currentUser` を追加するだけ。

```typescript
// 変更前
context: async (): Promise<Context> => ({ prisma })

// 変更後
context: async ({ req }): Promise<Context> => ({
  prisma,
  currentUser: req.user ?? null,  // Express auth ミドルウェアで注入済み
})
```

### ヘルパー関数方式が既存 Resolver を壊さない

`requireAuth(context)` を Resolver の先頭に 1 行追加するだけで認可チェックが入る。既存の Resolver ロジック（Prisma クエリ・Zod バリデーション・`prisma.$transaction`）には一切手を入れない。

```typescript
// bookingResolver.ts の createBooking
const user = requireAuth(context);  // ← この1行を追加するだけ
const validated = validate(createBookingSchema, input);
// ... 既存のロジックはそのまま
```

閲覧系クエリ（`travelPlans` / `travelPlan`）には `requireAuth` を入れないことで、未ログインでもプラン一覧・詳細を見られる設計を維持する。

### モバイル側の変更が GraphQLHttpClient の 1 箇所に集約される

現在の `GraphQLHttpClient`（`GraphQLClientInterface` 実装）は全 GraphQL 通信を担当しているため、ここに `Authorization` ヘッダを追加するだけで全リクエストにトークンが付与される。各 DataSource・Repository・ViewModel には変更が不要。

```dart
// GraphQLHttpClient に追加
final token = await _secureStorage.read(key: 'auth_token');
if (token != null) {
  request.headers.set('Authorization', 'Bearer $token');
}
```

### お気に入りを端末ローカルのままにする理由

お気に入りはアカウント紐づけせず、引き続き SharedPreferences（`FavoritesStorage`）で管理する。理由は以下の通り。

- 未ログインでもお気に入り追加ができ、ログインへの誘導にならない
- 既存の `StreamController.broadcast()` パターンが安定動作しており、変更リスクがない
- アカウント紐づけは将来の拡張として残し、現時点では YAGNI の判断

### 予約履歴の _kCustomerEmail をログインユーザーに置き換える

`BookingHistoryScreen` の `const _kCustomerEmail = 'test@example.com'` を `authState.currentUser.email` に置き換えることで、予約履歴が「自分の予約」になる。バックエンドの `bookings` Resolver でも `context.currentUser.email` を使い、他人の予約が取得できないようにする。

### GoRouter の redirect で認証ガードを実現する

GoRouter の `redirect` コールバックで、認証が必要なルート（`/plan/:id/booking`・`/booking-history`）にアクセスした際にログイン状態を確認する。未ログインの場合はログイン画面にリダイレクトし、ログイン後に元のルートに戻す。

閲覧系ルート（`/`・`/plan/:id`・`/favorites`・`/recently-viewed`）にはガードを入れず、未ログインでも自由にアクセスできるようにする。

## バックエンドの変更内容

### Prisma スキーマに User モデルを追加

```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  password  String   // bcrypt ハッシュ
  name      String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  bookings  Booking[]
}
```

Booking モデルに `userId` 外部キーを追加し、`customerEmail` は残しつつ `User` リレーションも持たせる（段階的移行のため）。

### 新規ファイル

| ファイル | 役割 |
|---|---|
| `src/middleware/auth.ts` | JWT 検証 Express ミドルウェア（jsonwebtoken パッケージ） |
| `src/graphql/resolvers/authResolver.ts` | `login` / `register` Mutation |
| `src/graphql/validations/authSchemas.ts` | ログイン・登録の Zod バリデーション |
| `src/utils/auth.ts` | `requireAuth()` / `generateToken()` / `hashPassword()` ヘルパー |

### 追加パッケージ

| パッケージ | 用途 |
|---|---|
| `jsonwebtoken` | JWT の生成・検証 |
| `bcryptjs` | パスワードハッシュ |

## モバイルの変更内容

### 新規ファイル

| ファイル | 役割 |
|---|---|
| `lib/core/auth/auth_service.dart` | トークン管理（flutter_secure_storage） |
| `lib/core/auth/auth_state.dart` | 認証状態の Provider（ログイン済み / 未ログイン） |
| `lib/data/datasources/remote/auth_remote_data_source.dart` | login / register の GraphQL 通信 |
| `lib/data/repositories/auth_repository.dart` | 認証 Repository（interface + impl） |
| `lib/presentation/viewmodels/auth_viewmodel.dart` | ログイン / 登録の状態管理 |
| `lib/presentation/screens/auth/login_screen.dart` | ログイン画面 |
| `lib/presentation/screens/auth/register_screen.dart` | 登録画面 |

### 追加パッケージ

| パッケージ | 用途 |
|---|---|
| `flutter_secure_storage` | JWT の暗号化保存（iOS: Keychain / Android: EncryptedSharedPreferences） |

### 既存ファイルの変更

| ファイル | 変更内容 |
|---|---|
| `GraphQLHttpClient` | `flutter_secure_storage` からトークンを読み出して `Authorization` ヘッダを自動付与 |
| `app_router.dart` | `redirect` で `/plan/:id/booking` / `/booking-history` に認証ガードを追加 |
| `BookingHistoryScreen` | `const _kCustomerEmail = 'test@example.com'` を `authState.currentUser.email` に置き換え |
| `BookingViewModel` | 予約ウィザードの旅行者情報（名前・メールアドレス）をプロフィールから自動入力 |

## 結果

### 得られるもの

- 予約が「自分の予約」になり、予約履歴・予約ウィザードが実用的になる
- 未ログインでも閲覧・お気に入り・検索は自由に使える
- `requireAuth()` ヘルパー 1 行で認可チェックが入り、既存 Resolver への影響が最小
- JWT + Context のパターンを実践でき、GraphQL + 認証の知見が得られる

### トレードオフ

- **リフレッシュトークン未実装**：初回実装ではアクセストークンのみとし、リフレッシュトークンは将来の拡張とする。トークン期限切れ時は再ログインが必要
- **ソーシャルログイン未対応**：email + password のみ。Google / Apple ログインは将来の拡張
- **お気に入りがアカウント非紐づけ**：端末を変えるとお気に入りが引き継がれない。ただし認証導入後に段階的に移行可能
- **User テーブル追加で DB マイグレーションが必要**：既存の Booking データとの整合性を段階的に確保する必要がある

## 実装順序の推奨

```
Phase 1（バックエンド）:
  1. Prisma に User モデル追加 + マイグレーション
  2. src/middleware/auth.ts + authResolver（login / register）
  3. requireAuth() ヘルパー + 既存 Resolver への適用
  4. Jest テスト追加

Phase 2（モバイル）:
  5. flutter_secure_storage + AuthService
  6. GraphQLHttpClient に Authorization ヘッダ追加
  7. ログイン/登録画面 + AuthViewModel
  8. GoRouter redirect で認証ガード
  9. BookingHistoryScreen の _kCustomerEmail 置き換え
     BookingViewModel への自動入力追加

Phase 3（仕上げ）:
  10. /doc-sync でドキュメント同期
  11. ADR-011 のステータスを「承認済み」に変更
```

## 参考

- [Apollo Server — Context and contextValue](https://www.apollographql.com/docs/apollo-server/data/context/)
- [jsonwebtoken npm パッケージ](https://www.npmjs.com/package/jsonwebtoken)
- [flutter_secure_storage パッケージ](https://pub.dev/packages/flutter_secure_storage)
- [GoRouter — Redirection](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- 本プロジェクトの [ADR-003: API 通信に GraphQL を採用した理由](./003-graphql-api-design.md)
- 本プロジェクトの [ADR-007: MVVM + Repository パターンの採用](./007-mvvm-repository-pattern.md)
