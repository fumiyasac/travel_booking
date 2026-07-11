# Travel Booking Project

## プロジェクト概要

Flutter モバイルアプリ（`travel_booking_mobile`）と Node.js/GraphQL バックエンド（`travel_booking_backend`）からなる Melos モノレポ構成の旅行予約システム。

## アーキテクチャ

### モバイル (travel_booking_mobile) — Dart 63%

**パターン**: MVVM + Repository

```
lib/
├── core/
│   ├── config/graphql_config.dart     # GraphQLHttpClient 設定 (Platform.isAndroid で 10.0.2.2 / localhost 自動切替)
│   ├── database/app_database.dart     # SharedPreferences ラッパー
│   ├── router/app_router.dart         # go_router ルート定義
│   └── theme/app_theme.dart           # アプリテーマ
├── data/
│   ├── models/                        # データモデル (freezed 非使用、手書き fromJson/toJson)
│   ├── datasources/
│   │   ├── remote/travel_plan_remote_datasource.dart  # GraphQL クエリ/ミューテーション
│   │   └── local/favorite_local_datasource.dart       # SharedPreferences
│   └── repositories/
│       ├── travel_plan_repository.dart      # インターフェース
│       ├── travel_plan_repository_impl.dart # 実装
│       ├── favorite_repository.dart         # インターフェース
│       └── favorite_repository_impl.dart   # 実装
├── presentation/
│   ├── viewmodels/   # @riverpod AsyncNotifier — .g.dart は自動生成
│   ├── screens/      # home / plan_detail / booking / favorites
│   └── widgets/      # 共通ウィジェット (rating_stars, loading_indicator, app_error_widget)
└── preview/          # Widgetbook Preview 環境（開発用）
    ├── main.dart                   # Widgetbook エントリポイント (@widgetbook.App)
    ├── mock_data.dart              # モックプランデータ（3件）
    ├── mock_providers.dart         # FakeInMemoryFavoritesStorage + previewProviderOverrides
    ├── main.directories.g.dart    # build_runner 自動生成 ← 手動編集禁止
    └── components/                 # @widgetbook.UseCase 定義
```

**状態管理**: Riverpod 3.x（`riverpod_generator` によるコード生成必須）  
**ナビゲーション**: go_router 14.x  
**GraphQL 通信**: http パッケージで手書きクエリ（クエリは datasource 内に定数として定義）

### バックエンド (travel_booking_backend) — TypeScript 37%

```
src/
├── index.ts                          # Apollo Server エントリポイント (port 4000)
└── graphql/
    ├── typeDefs.ts                   # GraphQL スキーマ定義
    └── resolvers/
        ├── planResolver.ts           # TravelPlan クエリ
        └── bookingResolver.ts        # Booking ミューテーション
prisma/
├── schema.prisma                     # MySQL スキーマ (TravelPlan, Booking 等)
└── seed.ts                           # 初期データ
```

**GraphQL エンドポイント**: `http://localhost:4000/graphql`  
**ORM**: Prisma 5.x + MySQL 8.0  
**コンテナ**: Docker Compose（MySQL + バックエンドサービス）

## よく使うコマンド

### 初回セットアップ

```bash
# melos をグローバルインストール（初回のみ・PATH への追加も必要）
dart pub global activate melos
export PATH="$PATH":"$HOME/.pub-cache/bin"

# モノレポ依存関係インストール（travel_booking/ ルートで実行）
dart pub get
dart run melos bootstrap

# バックエンド Docker 起動
cd travel_booking_backend && docker compose up -d

# DB マイグレーション & シードデータ投入
cd travel_booking_backend && npm run db:migrate && npm run db:seed
```

### モバイル開発

> すべて `travel_booking/`（リポジトリルート）で実行

```bash
dart run melos run build_runner          # Riverpod .g.dart 生成（モデル変更後は必須）
dart run melos run "build_runner:watch"  # ウォッチモード（開発中は常時起動推奨）
dart run melos run test                  # 全ユニットテスト実行
dart run melos run analyze               # 静的解析
dart run melos run format                # コードフォーマット
dart run melos run clean                 # ビルドキャッシュ削除
dart run melos run get                   # 依存関係更新
dart run melos run preview               # Widgetbook Preview をデフォルトデバイスで起動
dart run melos run "preview:web"         # Widgetbook Preview を Chrome で起動
```

### バックエンド操作

```bash
cd travel_booking_backend
npm run dev           # 開発サーバー起動（nodemon + ts-node）
npm run db:migrate    # マイグレーション実行
npm run db:seed       # シードデータ投入
npm run db:studio     # Prisma Studio 起動
npm run db:reset      # DB 完全リセット（開発環境のみ）
```

## 開発規約

### Riverpod コード生成
- ViewModel は `@riverpod` アノテーションを使用した `AsyncNotifier` パターン
- `*.g.dart` ファイルは自動生成 → **手動編集禁止**
- モデルや ViewModel を変更した後は必ず `dart run melos run build_runner` を実行

### Repository パターン
- 必ずインターフェース（抽象クラス）と実装クラスをペアで作成
- DataSource → Repository → ViewModel の依存方向を維持
- Riverpod Provider で DI（依存性注入）

### GraphQL クエリ
- クエリ/ミューテーションは `TravelPlanRemoteDataSource` 内に文字列定数として定義
- フィールド追加時は **バックエンド typeDefs → Prisma スキーマ → モバイル DataSource** の順に更新
- assets フォルダ (`assets/graphql/`) の `.graphql` ファイルも同期して更新

### ファイル命名
- Dart: `snake_case.dart`
- TypeScript: `camelCase.ts`
- GraphQL 型名: `PascalCase`

## テスト戦略

### ViewModel テスト（既存パターン）
テストは `test/viewmodels/` 以下に配置。4つの ViewModel テストが存在する。

```
test/viewmodels/
├── plan_list_viewmodel_test.dart         # PlanListViewModel
├── plan_list_viewmodel_test.mocks.dart   # 自動生成モック
├── plan_detail_viewmodel_test.dart
├── plan_detail_viewmodel_test.mocks.dart
├── booking_viewmodel_test.dart
├── booking_viewmodel_test.mocks.dart
├── favorite_viewmodel_test.dart
└── favorite_viewmodel_test.mocks.dart
```

**テストの書き方（plan_list_viewmodel_test.dart を参照）:**
1. `@GenerateMocks([TravelPlanRepository])` アノテーションを付ける
2. `dart run melos run build_runner` でモッククラス（`.mocks.dart`）を生成
3. `ProviderContainer(overrides: [repositoryProvider.overrideWithValue(mock)])` で DI
4. `setUp` / `tearDown` で `container.dispose()` を忘れずに
5. テストデータは日本語の現実的な値で作成（例: `'東京エクスプローラー5日間'`）

### カバーすべきテストケース
- 初期状態の確認
- 成功時（データ取得 → state 変化）
- 失敗時（エラーセット → `isLoading: false`）
- エッジケース（空リスト、null 値、ページネーション境界値）

## 既知の注意点

### GraphQL エンドポイントの設定
`core/config/graphql_config.dart` の `_baseUrl` はプラットフォームに応じて自動で切り替わる。
- iOS シミュレーター: `http://localhost:4000/graphql`（デフォルト）
- Android エミュレーター: `http://10.0.2.2:4000/graphql`（`Platform.isAndroid` で自動切替）
- 実機: `GraphQLHttpClient(baseUrl: 'http://<ホストPCのIP>:4000/graphql')` と明示指定するか、`--dart-define=GRAPHQL_URL=...` を使う

### .g.dart の再生成忘れ
`@riverpod` アノテーション付きクラスを変更後に `build_runner` 未実行だと古い生成コードが残る。
**症状**: `The getter 'xxxProvider' isn't defined for the class`  
**解消**: `dart run melos run build_runner`

### iOS での HTTP 通信
`GraphQLHttpClient` は `dart:io HttpClient` を直接使用（`http` パッケージの `IOClient` は iOS で Keep-Alive 問題があるため回避）。
`http://` エンドポイントを使う場合は `ios/Runner/Info.plist` に `NSAllowsArbitraryLoads: true` が必要。

### 予約フォームのバリデーション
`BookingViewModel._validate()` の validation エラーは `validationErrors` Map で管理。
メソッドを追加する際は `_removeError(key)` を `updateXxx()` でも呼ぶこと。

### Prisma スキーマ変更の影響範囲
フィールドを1つ追加するだけで以下の全レイヤーに変更が必要:
`schema.prisma` → `typeDefs.ts` → Resolver → Dart モデル → DataSource クエリ文字列 → DB マイグレーション → `build_runner`

## カスタムスキル一覧

スキルは `.claude/skills/` に定義。詳細な活用ガイドは `skill_guidance.md` を参照。

| スキル名 | 起動方法 | 概要 | 自動起動 |
|---|---|---|:---:|
| `flutter-gen` | `/flutter-gen` または自然文 | Riverpod `.g.dart` コード生成 | ✓ |
| `backend-up` | `/backend-up` のみ | Docker バックエンド起動 | — |
| `db-reset` | `/db-reset` のみ | 開発用 DB 初期化（破壊的操作） | — |
| `fix-endpoint` | `/fix-endpoint [IP]` のみ | GraphQL 接続先変更 | — |
| `graphql-check` | `/graphql-check` または自然文 | GraphQL 整合性チェック（独立実行） | ✓ |
| `add-feature` | `/add-feature <機能名>` | MVVM+Repository 雛形ファイル生成 | — |
| `add-route` | `/add-route <path> <Screen> [--tab]` または自然文 | GoRoute 追加・ボトムナビ更新 | ✓ |
| `schema-update` | `/schema-update <変更内容>` または自然文 | 全レイヤースキーマ変更（8ステップ） | ✓ |
| `bug-trace` | `/bug-trace <エラー>` または自然文 | バグ原因特定と修正 | ✓ |
| `add-viewmodel-test` | `/add-viewmodel-test <名前>` または自然文 | ViewModel テスト追加 | ✓ |
| `add-mock-data` | `/add-mock-data <条件>` または自然文 | 条件付きテストデータ DB 投入 | ✓ |
| `state-audit` | `/state-audit <名前>` または自然文 | 状態管理監査（独立実行） | ✓ |
| `perf-audit` | `/perf-audit <名前>` または自然文 | パフォーマンス静的監査（独立実行） | ✓ |
| `widget-gen` | `/widget-gen <名前>` または自然文 | 共通ウィジェット雛形生成 | ✓ |
