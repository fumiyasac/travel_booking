# Travel Booking App

旅行プランの閲覧・予約サービスのサンプルアプリです。  
Flutterモバイルアプリ + Node.jsバックエンドで構成されるモノレポ構成です。

---

## プロジェクト構成

```
travel_booking/
├── pubspec.yaml                  # ルートワークスペース（melos インストール用）
├── melos.yaml                    # モノレポパッケージ管理
├── travel_booking_backend/       # バックエンドサービス
└── travel_booking_mobile/        # Flutterモバイルアプリ
```

---

## バックエンド (`travel_booking_backend/`)

### 技術スタック

| 技術 | バージョン | 用途 |
|------|-----------|------|
| Node.js | 20+ | ランタイム |
| TypeScript | 5.x | 言語 |
| Apollo Server | 4.x | GraphQL サーバー |
| Prisma | 5.x | ORM |
| MySQL | 8.0 | データベース |
| Docker / Docker Compose | - | コンテナ管理 |

### ディレクトリ構成

```
travel_booking_backend/
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── package.json
├── tsconfig.json
├── prisma/
│   ├── schema.prisma           # データベーススキーマ
│   └── seed.ts                 # サンプルデータ投入スクリプト
└── src/
    ├── index.ts                # サーバーエントリーポイント
    └── graphql/
        ├── typeDefs.ts         # GraphQL スキーマ定義 (SDL)
        └── resolvers/
            ├── index.ts
            ├── planResolver.ts   # プラン取得・検索
            └── bookingResolver.ts # 予約作成・キャンセル
```

### データベーススキーマ

```
TravelPlan          旅行プラン（メインエンティティ）
├── TravelPlanImage     プラン写真
├── TravelPlanHighlight ハイライト（見どころ）
├── ItineraryDay        日程（何日目か）
│   └── ItineraryActivity   各日のアクティビティ
├── IncludedItem        料金に含まれるもの
├── ExcludedItem        料金に含まれないもの
├── Review              クチコミ
└── Booking             予約情報
```

### GraphQL API

#### クエリ

```graphql
# プラン一覧取得（フィルタ・ページネーション対応）
query GetTravelPlans($filter: PlanFilterInput, $page: Int, $pageSize: Int) {
  travelPlans(filter: $filter, page: $page, pageSize: $pageSize) {
    plans { id title price rating ... }
    totalCount hasNextPage currentPage totalPages
  }
}

# プラン詳細取得（全情報含む）
query GetTravelPlan($id: ID!) {
  travelPlan(id: $id) {
    id title description latitude longitude
    itinerary { dayNumber title activities { name startTime } }
    reviews { reviewerName rating comment }
  }
}
```

#### ミューテーション

```graphql
# 予約作成
mutation CreateBooking($input: CreateBookingInput!) {
  createBooking(input: $input) {
    success message
    booking { id status totalPrice }
  }
}

# 予約キャンセル
mutation CancelBooking($id: ID!) {
  cancelBooking(id: $id) { success message }
}
```

#### フィルタオプション

| フィールド | 値 |
|-----------|-----|
| `category` | `city` / `cultural` / `nature` / `adventure` / `leisure` |
| `region` | `アジア` / `ヨーロッパ` / `アメリカ大陸` / `オセアニア` / `アフリカ` |
| `difficulty` | `easy` / `moderate` / `hard` |
| `sortBy` | `rating` / `price` / `duration` / `createdAt` |
| `minPrice` / `maxPrice` | 価格帯（円） |
| `maxDuration` | 最大日数 |

### サンプルデータ（シード）

| # | プラン名 | 目的地 | カテゴリ | 料金/人 |
|---|---------|--------|---------|--------|
| 1 | 東京エクスプローラー5日間 | 東京・日本 | 都市観光 | ¥150,000 |
| 2 | 京都伝統文化探訪4日間 | 京都・日本 | 文化体験 | ¥120,000 |
| 3 | 北海道大自然アドベンチャー7日間 | 北海道・日本 | 自然 | ¥200,000 |
| 4 | パリ・ロマンス＆カルチャー6日間 | パリ・フランス | リゾート | ¥280,000 |
| 5 | スイスアルプス トレッキング8日間 | インターラーケン・スイス | アドベンチャー | ¥350,000 |
| 6 | バリ島スピリチュアルリトリート5日間 | ウブド・インドネシア | リゾート | ¥100,000 |
| 7 | ニューヨーク・シティ・エクスペリエンス4日間 | ニューヨーク・USA | 都市観光 | ¥180,000 |
| 8 | オーストラリア グレートバリアリーフ6日間 | ケアンズ・オーストラリア | アドベンチャー | ¥320,000 |
| 9 | モロッコ砂漠とメディナ7日間 | マラケシュ・モロッコ | アドベンチャー | ¥160,000 |
| 10 | サントリーニ島 エーゲ海5日間 | サントリーニ・ギリシャ | リゾート | ¥250,000 |

各プランには以下が含まれます：
- プラン写真（複数枚）
- ハイライト（見どころ）
- 詳細な日程（各日のアクティビティ・宿泊先・食事）
- 料金含有・含有外リスト
- クチコミ（複数件）

### セットアップ・起動手順

```bash
cd travel_booking_backend

# 1. 環境変数設定
cp .env.example .env

# 2. Docker でサービス起動（MySQL + バックエンド）
docker compose up -d

# 3. データベースマイグレーション
#    （Docker 起動直後は MySQL の準備が整うまで数秒待ってから実行）
docker compose exec backend npm run db:migrate
# 「Enter a name for the new migration:」と聞かれたら任意の名前を入力
# 例: init_schema

# 4. サンプルデータ投入
docker compose exec backend npm run db:seed

# GraphQL エンドポイント: http://localhost:4000/graphql
```

#### ローカル開発（Docker なし）

```bash
cd travel_booking_backend
npm install
npm run db:generate    # Prisma クライアント生成
npm run db:migrate     # マイグレーション実行（ローカル MySQL が必要）
npm run db:seed        # サンプルデータ投入
npm run dev            # 開発サーバー起動（ホットリロード）
```

#### その他のコマンド（Docker 環境では `docker compose exec backend` を先頭に付ける）

```bash
npm run db:studio      # Prisma Studio（GUI でDB確認）
npm run db:push        # スキーマ変更を即反映（プロトタイプ時）
npm run db:reset       # DB リセット（全データ削除 → マイグレーション再適用）
npm run build          # TypeScript ビルド
npm run start          # 本番サーバー起動
```

---

## モバイルアプリ (`travel_booking_mobile/`)

### 技術スタック

| 技術 | バージョン | 用途 |
|------|-----------|------|
| Flutter | 3.x | UIフレームワーク |
| Riverpod | 3.x | 状態管理 |
| riverpod_annotation / riverpod_generator | 3.x | コード生成（@riverpod） |
| SharedPreferences | 2.x | お気に入りのローカル保存 |
| http | 1.x | GraphQL HTTP クライアント |
| go_router | 14.x | ナビゲーション |
| shimmer | 3.x | ローディングアニメーション |
| intl | 0.19 | 日付フォーマット |
| gap | 3.x | スペーシングユーティリティ |
| flutter_rating_bar | 4.x | 星評価表示 |
| melos | 6.x | モノレポパッケージ管理 |

> **注意:** `Freezed` は使用しません。全モデルクラスは `copyWith` / `fromJson` / `toJson` を手動実装しています。  
> GraphQL 通信は `http` パッケージを使った軽量クライアントで実装しており、`graphql_flutter` は使用しません。

### アーキテクチャ

**MVVM + Repository パターン**

```
lib/
├── core/                         # アプリ基盤
│   ├── config/
│   │   └── graphql_config.dart   # GraphQLHttpClient（http パッケージ使用）
│   ├── database/
│   │   └── app_database.dart     # FavoritesStorage（SharedPreferences）
│   ├── router/
│   │   └── app_router.dart       # GoRouter 設定
│   └── theme/
│       └── app_theme.dart        # カラー・テーマ定義
│
├── data/                         # データ層
│   ├── models/                   # ドメインモデル（Freezed 不使用）
│   │   ├── travel_plan.dart      # メインモデル（算出プロパティ含む）
│   │   ├── travel_plan_image.dart
│   │   ├── itinerary_day.dart
│   │   ├── itinerary_activity.dart
│   │   ├── review.dart
│   │   ├── booking.dart
│   │   ├── favorite_plan.dart    # お気に入り保存モデル
│   │   └── plan_filter.dart      # 検索フィルタ
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── travel_plan_remote_datasource.dart  # GraphQL HTTP 通信
│   │   └── local/
│   │       └── favorite_local_datasource.dart       # SharedPreferences + Stream
│   └── repositories/
│       ├── travel_plan_repository.dart              # abstract
│       ├── travel_plan_repository_impl.dart
│       ├── favorite_repository.dart                 # abstract
│       └── favorite_repository_impl.dart
│
└── presentation/                 # プレゼンテーション層
    ├── viewmodels/               # ViewModel（Riverpod @riverpod）
    │   ├── plan_list_viewmodel.dart    # プロバイダー定義も含む
    │   ├── plan_detail_viewmodel.dart
    │   ├── booking_viewmodel.dart
    │   └── favorite_viewmodel.dart
    ├── screens/                  # 画面
    │   ├── home/                 # プラン一覧・検索・フィルタ
    │   ├── plan_detail/          # プラン詳細・座標表示
    │   ├── booking/              # 予約フォーム・確認
    │   └── favorites/            # お気に入り一覧
    └── widgets/                  # 共通ウィジェット
```

### 画面構成

#### 1. ホーム画面（プラン一覧）
- プランカード一覧（無限スクロール）
- 検索バー（タイトル・目的地・タグで検索）
- フィルタ（カテゴリ・地域・難易度・日数・並び替え）
- プルリフレッシュ
- シマーローディング
- お気に入りボタン（ハートアイコン）

#### 2. プラン詳細画面
- 写真ギャラリー（PageView）
- プラン概要・料金・空き状況
- ハイライト（見どころ）
- 日程（アコーディオン形式）
- 含有・非含有リスト
- 集合場所・座標表示（緯度・経度）
- クチコミ一覧
- キャンセルポリシー
- 予約ボタン（スティッキーフッター）

#### 3. 予約画面
- プランサマリーカード
- お客様情報フォーム（名前・メール・電話番号）
- 参加人数セレクター（+/-ボタン）
- 旅行日選択（日付ピッカー）
- 特別なご要望（テキストエリア）
- 料金内訳（リアルタイム計算）
- バリデーション・エラーメッセージ

#### 4. 予約完了画面
- 成功アニメーション
- 予約詳細（予約ID・プラン名・旅行日・参加人数・合計金額）
- ホームへ戻るボタン

#### 5. お気に入り画面
- グリッドビュー（2カラム）
- ハートアイコンでお気に入り解除
- 全削除機能
- StreamController でリアルタイム反映
- 空状態の表示

### ViewModel 詳細

#### PlanListViewModel
```dart
class PlanListState {
  final List<TravelPlan> plans;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PlanFilter filter;
  final int currentPage;
  final bool hasNextPage;
  final int totalCount;
}
```
主要メソッド: `loadPlans()`, `loadMore()`, `updateFilter()`, `updateKeyword()`, `resetFilter()`

#### PlanDetailViewModel
```dart
class PlanDetailState {
  final TravelPlan? plan;
  final bool isLoading;
  final String? error;
  final bool isFavorite;
  final bool isFavoriteLoading;
}
```
主要メソッド: `loadPlanById(id)`, `toggleFavorite()`

#### BookingViewModel
```dart
class BookingFormState {
  final String customerName, customerEmail, customerPhone;
  final int numberOfPeople;
  final DateTime? travelDate;
  final String specialRequests;
  final bool isSubmitting;
  final String? error;
  final Booking? completedBooking;
  final Map<String, String> validationErrors;
}
```
主要メソッド: `updateCustomerName()`, `updateTravelDate()`, `submitBooking()`, `reset()`

#### FavoriteViewModel
```dart
class FavoriteState {
  final List<FavoritePlan> favorites;
  final bool isLoading;
  final String? error;
}
```
主要メソッド: `removeFavorite(planId)`, `clearAll()` ／ StreamController でリアルタイム更新

### Riverpod プロバイダー構成

```
graphQLHttpClientProvider       GraphQLHttpClient（http パッケージ）
    ↓
travelPlanRemoteDataSourceProvider  リモートデータソース
    ↓
travelPlanRepositoryProvider        リポジトリ
    ↓
planListViewModelProvider           ViewModel（@riverpod）
planDetailViewModelProvider(id)
bookingViewModelProvider

favoritesStorageProvider        FavoritesStorage（SharedPreferences）
    ↓
favoriteLocalDataSourceProvider ローカルデータソース（StreamController）
    ↓
favoriteRepositoryProvider      リポジトリ
    ↓
favoriteViewModelProvider       ViewModel（@riverpod）
```

### ルーティング構成（GoRouter）

```
/                           ホーム（プラン一覧）
  /plan/:id                 プラン詳細
    /plan/:id/booking       予約フォーム
/favorites                  お気に入り
  /favorites/plan/:id       お気に入りからのプラン詳細
/booking/confirmation/:id   予約完了
```

ボトムナビゲーションバー（StatefulShellRoute）:
- `プラン` タブ → ホーム以下
- `お気に入り` タブ → お気に入り以下

### セットアップ・起動手順

#### 1. 依存パッケージのインストール

```bash
# リポジトリルート（melos.yaml がある場所）で実行
cd travel_booking

# ルートの pubspec.yaml から melos をローカルインストール
dart pub get

# 全パッケージの依存解決（melos bootstrap）
dart run melos bootstrap
```

または直接インストールする場合:

```bash
cd travel_booking_mobile
flutter pub get
```

#### 2. コード生成（Riverpod + Mockito）

Riverpod の `@riverpod` アノテーションと Mockito のモッククラスを生成します。

```bash
# travel_booking_mobile/ で実行
cd travel_booking_mobile
dart run build_runner build --delete-conflicting-outputs
```

または melos 経由（リポジトリルートで実行）:

```bash
cd travel_booking
dart run melos run build_runner
```

生成されるファイル:
- `lib/presentation/viewmodels/plan_list_viewmodel.g.dart`
- `lib/presentation/viewmodels/plan_detail_viewmodel.g.dart`
- `lib/presentation/viewmodels/booking_viewmodel.g.dart`
- `lib/presentation/viewmodels/favorite_viewmodel.g.dart`
- `test/viewmodels/*.mocks.dart`

> **ポイント:** `graphql_flutter` や `google_maps_flutter` などの  
> native build hooks を持つパッケージは使用していないため、  
> `build_runner` が `dart compile` で正常に動作します。

#### 3. バックエンドURLの設定

`lib/core/config/graphql_config.dart` の `baseUrl` を環境に合わせて変更してください:

```dart
// ローカル開発（iOS シミュレーター）
GraphQLHttpClient(baseUrl: 'http://localhost:4000/graphql')

// Android エミュレーター
GraphQLHttpClient(baseUrl: 'http://10.0.2.2:4000/graphql')

// 実機デバッグ（PC の IP アドレスを使用）
GraphQLHttpClient(baseUrl: 'http://192.168.x.x:4000/graphql')
```

`plan_list_viewmodel.dart` の `graphQLHttpClientProvider` でインスタンス生成箇所を変更します:

```dart
@riverpod
GraphQLHttpClient graphQLHttpClient(Ref ref) {
  final client = GraphQLHttpClient(baseUrl: 'http://10.0.2.2:4000/graphql');
  ref.onDispose(client.dispose);
  return client;
}
```

#### 4. アプリ起動

```bash
cd travel_booking_mobile

# 利用可能なデバイス一覧を確認
flutter devices

# iOS シミュレーターで起動（デバイスIDを指定）
flutter run -d <シミュレーターのデバイスID>

# または、デバイスを選択しながら起動
flutter run
```

> **初回のみ:** iOS プラットフォームファイルが存在しない場合は先に生成してください。
>
> ```bash
> cd travel_booking_mobile
> flutter create --org com.example --platforms ios,android .
> flutter pub get
> ```
>
> その後、通常通り `flutter run` を実行できます。

### Unit Test

ViewModelの全メソッドに対してUnitTestを実装しています（Mockito使用）。

```bash
# travel_booking_mobile/ で実行
cd travel_booking_mobile
flutter test

# または melos 経由（リポジトリルートで実行）
cd travel_booking
dart run melos run test
```

テスト対象:

| テストファイル | テスト項目 |
|--------------|-----------|
| `plan_list_viewmodel_test.dart` | 初期状態・プラン取得・エラーハンドリング・フィルタ更新・無限スクロール |
| `plan_detail_viewmodel_test.dart` | プラン詳細取得・お気に入りトグル・エラーハンドリング |
| `booking_viewmodel_test.dart` | フォームバリデーション・予約成功/失敗・料金計算・リセット |
| `favorite_viewmodel_test.dart` | お気に入り一覧・リアルタイム更新・削除・エラーハンドリング |

> **テストの注意点:** `FavoriteViewModel` のテストでは Riverpod 3.x の autoDispose の  
> 挙動を考慮し、`container.listen()` でプロバイダーを生存させてからストリームのテストを行います。

### melos スクリプト一覧

> **実行場所:** リポジトリルート（`melos.yaml` がある場所、`dart pub get` 済み）で実行してください。

```bash
dart run melos run build_runner         # コード生成（Riverpod + Mockito）
dart run melos run "build_runner:watch" # コード生成（ウォッチモード）
dart run melos run test                 # ユニットテスト実行
dart run melos run analyze              # 静的解析
dart run melos run format               # コードフォーマット
dart run melos run clean                # ビルド成果物クリーン
dart run melos run get                  # 依存パッケージ取得
```

---

## 開発フロー

```
0. 初回セットアップ（リポジトリルートで実行）
   cd travel_booking
   dart pub get
   dart run melos bootstrap

   ※ ios/ や android/ ディレクトリが存在しない場合は以下を実行:
   cd travel_booking_mobile
   flutter create --org com.example --platforms ios,android .
   flutter pub get

1. バックエンド起動（travel_booking_backend/ で実行）
   docker compose up -d
   docker compose exec backend npm run db:migrate   # マイグレーション名を入力
   docker compose exec backend npm run db:seed

2. コード生成（travel_booking_mobile/ で実行）
   dart run build_runner build --delete-conflicting-outputs

3. アプリ起動（travel_booking_mobile/ で実行）
   flutter devices              # デバイス一覧確認
   flutter run                  # デバイス選択して起動
   flutter run -d <デバイスID>  # デバイス指定して起動

4. テスト（travel_booking_mobile/ で実行）
   flutter test
```

---

## 注意事項

- Riverpod 3.x の `@riverpod` アノテーションを使用しているため、`build_runner` によるコード生成が必須です
- GraphQL 通信は `http` パッケージで実装しており、`graphql_flutter` は不使用です（native build hooks による `build_runner` エラーを回避するため）
- お気に入り機能は `SharedPreferences` を使用しており、`Drift`（SQLite）は不使用です（同じく native build hooks 回避のため）
- Android エミュレーターでバックエンドに接続する場合は `localhost` ではなく `10.0.2.2` を使用してください
- Docker 起動直後は MySQL の準備に数秒かかるため、`db:migrate` は少し待ってから実行してください
