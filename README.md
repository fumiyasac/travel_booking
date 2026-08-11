# Travel Booking App

[![CI](https://github.com/fumiyasac/travel_booking/actions/workflows/ci.yml/badge.svg)](https://github.com/fumiyasac/travel_booking/actions/workflows/ci.yml)

旅行プランの閲覧・予約サービスのサンプルアプリです。  
Flutter モバイルアプリ（iOS / Android）と Node.js / GraphQL バックエンドで構成される Melos モノレポです。

---

## 目次

1. [前提条件](#前提条件)
   - [mise によるツールバージョン管理（推奨）](#mise-によるツールバージョン管理推奨)
2. [クイックスタート](#クイックスタート)
3. [詳細セットアップ](#詳細セットアップ)
   - [バックエンドのセットアップ](#step-2-バックエンドのセットアップdocker)
   - [モバイルアプリのセットアップ](#step-3-モバイルアプリのセットアップ)
   - [接続 URL の設定](#step-4-接続-url-の設定重要)
4. [実行環境別の起動手順](#実行環境別の起動手順)
   - [iOS シミュレーター](#ios-シミュレーター)
   - [Android エミュレーター](#android-エミュレーター)
   - [iOS 実機](#ios-実機)
   - [Android 実機](#android-実機)
5. [開発コマンド（melos）](#開発コマンドmelos)
6. [Claude Code スキル](#claude-code-スキル)
7. [プロジェクト構成](#プロジェクト構成)
8. [アーキテクチャ](#アーキテクチャ)
9. [GraphQL API リファレンス](#graphql-api-リファレンス)
10. [テスト](#テスト)
11. [Widgetbook Preview](#widgetbook-preview)
12. [トラブルシューティング](#トラブルシューティング)

---

## 前提条件

開発を始める前に以下のツールをインストールしてください。

| ツール | 推奨バージョン | 確認コマンド |
|---|---|---|
| Flutter | 3.x 以上 | `flutter --version` |
| Dart | 3.x 以上（Flutter に同梱） | `dart --version` |
| Node.js | 20 以上 | `node --version` |
| Docker Desktop | 最新安定版 | `docker --version` |
| Xcode | 15 以上（iOS 開発時） | `xcode-select -p` |
| Android Studio | 最新版（Android 開発時） | — |
| mise | 最新安定版 | `mise --version` |

### mise によるツールバージョン管理（推奨）

[mise](https://mise.jdx.dev/) はプロジェクトごとのツールバージョンを `.mise.toml` で管理するバージョンマネージャーです。  
チームメンバー全員が同じ Flutter / Node.js のバージョンを使えるよう、このリポジトリでは `.mise.toml` を用意しています。

#### mise のインストール

```bash
# Homebrew でインストール
brew install mise

# シェルへの統合（~/.zshrc に追記して source する）
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

#### mise でツールを一括セットアップ

```bash
# リポジトリルートで実行
# .mise.toml に定義されたバージョン（flutter 3.38.5 / node 20）が自動でインストールされます
mise install
```

> **mise を使わない場合も手動インストールで開発できます。**  
> `.mise.toml` のバージョン表記（`flutter = "3.38.5"` / `node = "20"`）を参考に、各ツールの公式サイトからインストールしてください。

---

### Flutter のインストール（未インストールの場合）

```bash
# Flutter 公式サイト (https://docs.flutter.dev/get-started/install) から
# インストーラーをダウンロードするか、以下のコマンドで確認
flutter doctor
```

`flutter doctor` の出力に `✓` が並んでいれば準備完了です。
`✗` が表示されている場合はその指示に従ってセットアップを完了させてください。

---

## クイックスタート

> 最短でアプリを起動する手順です。各ステップの詳細は後続セクションを参照してください。

```bash
# 1. リポジトリをクローン
git clone https://github.com/fumiyasac/travel_booking.git
cd travel_booking

# 1.5（推奨）mise でツールを一括セットアップ
mise install

# 2. melos をグローバルインストール（初回のみ）
dart pub global activate melos

# 3. モバイルアプリの依存関係をインストール
dart pub get && dart run melos bootstrap

# 3. バックエンドを Docker で起動し、DB を初期化
cd travel_booking_backend
cp .env.example .env
docker compose up -d
docker compose exec backend npm run db:migrate
docker compose exec backend npm run db:seed
cd ..

# 4. pre-commit フックを有効化（初回のみ）
dart run melos run setup-hooks

# 5. 接続 URL を設定（実機使用時のみ必要 — 詳細は後述）
#    シミュレーター/エミュレーターは自動設定のためスキップ可

# 6. アプリを起動
cd travel_booking_mobile
flutter run
```

> **Step 4 はシミュレーター・エミュレーターでは不要です。** プラットフォームに応じた URL が自動で使われます。  
> 実機で動作させる場合のみ、PC の IP アドレスを明示指定してください。

---

## 詳細セットアップ

### Step 1: リポジトリのクローン

```bash
git clone https://github.com/fumiyasac/travel_booking.git
cd travel_booking
```

---

### Step 2: バックエンドのセットアップ（Docker）

```bash
cd travel_booking_backend

# 環境変数ファイルを作成
cp .env.example .env
```

`.env` の内容（デフォルトで動作します。変更不要）:

```
DATABASE_URL="mysql://root:password@localhost:3306/travel_booking"
PORT=4000
NODE_ENV=development
```

#### Docker でサービスを起動

```bash
# MySQL + バックエンドサービスをバックグラウンドで起動
docker compose up -d

# 起動状態を確認
docker compose ps
```

正常に起動すると以下のように表示されます：

```
NAME                       STATUS          PORTS
travel_booking_backend     Up              0.0.0.0:4000->4000/tcp
travel_booking_mysql       Up (healthy)    0.0.0.0:3306->3306/tcp
```

> **mysql が `healthy` になるまで次のコマンドを実行しないでください。**  
> `docker compose ps` を繰り返し実行して `(healthy)` になったことを確認してください。  
> 初回は MySQL イメージのダウンロードが発生するため 1〜2 分かかる場合があります。

#### DB マイグレーションとシードデータ投入

```bash
# マイグレーション実行（「Enter a name for the new migration:」と聞かれたら任意の名前を入力）
docker compose exec backend npm run db:migrate

# シードデータ投入（旅行プラン 10 件、予約サンプルデータが入ります）
docker compose exec backend npm run db:seed
```

#### 動作確認

ブラウザまたは curl で GraphQL エンドポイントにアクセスして確認します:

```bash
curl -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ travelPlans { totalCount } }"}'
# 期待される出力: {"data":{"travelPlans":{"totalCount":10}}}
```

---

### Step 3: モバイルアプリのセットアップ

```bash
# リポジトリルート（travel_booking/）で実行
cd travel_booking   # すでにいる場合はスキップ

# melos をグローバルインストール（初回のみ）
dart pub global activate melos

# PATH に pub-cache/bin を追加（未設定の場合）
# ~/.zshrc または ~/.bashrc に以下を追記して source する
export PATH="$PATH":"$HOME/.pub-cache/bin"

# ワークスペースの依存関係を解決
dart pub get

# 全パッケージの依存関係を解決
dart run melos bootstrap
```

> **melos コマンドが `command not found` になる場合**  
> `dart pub global activate melos` を実行し、`$HOME/.pub-cache/bin` が PATH に含まれているか確認してください。

> **`dart run melos bootstrap` が失敗する場合**  
> `dart pub get` が完了していることを確認してください。  
> それでも失敗する場合は `travel_booking_mobile/` で `flutter pub get` を直接実行してください。

#### コード生成ファイルについて

`@riverpod` アノテーションから生成される `.g.dart` ファイルはリポジトリにコミット済みです。  
**クローン直後は `build_runner` の実行は不要です。**

ViewModel やモデルを変更した後は以下を実行してください:

```bash
# リポジトリルートで実行
dart run melos run build_runner
```

#### pre-commit フックの有効化

コミット前に Dart ファイルを自動フォーマットする Git フックをセットアップします。  
**初回セットアップ時に一度だけ実行してください。**

```bash
# リポジトリルートで実行
dart run melos run setup-hooks
```

これにより `.githooks/pre-commit` が有効になり、`git commit` のたびに `dart format` が自動実行されます。  
CI の format チェックが失敗するケースを防ぐことができます。

---

### Step 4: 接続 URL の設定

`graphql_config.dart` はプラットフォームを自動検出し、適切な URL をデフォルトで使用します。

| 実行環境 | 使用される URL（自動） |
|---|---|
| iOS シミュレーター | `http://localhost:4000/graphql` |
| Android エミュレーター | `http://10.0.2.2:4000/graphql` |

**実機の場合のみ手動設定が必要です。**  
PC と実機が同じ Wi-Fi に接続されていることを確認し、`graphql_config.dart` の `GraphQLHttpClient` に `baseUrl` を明示指定してください:

```dart
// graphql_config.dart 内の Provider 定義で URL を上書きする場合
GraphQLHttpClient(baseUrl: 'http://192.168.1.50:4000/graphql')  // PC の実際の IP に変更
```

または `flutter run` 実行時に `--dart-define` で渡すことも可能です:

```bash
flutter run --dart-define=GRAPHQL_URL=http://192.168.1.50:4000/graphql
```

**ホスト PC の IP アドレスを確認するコマンド（実機使用時）:**
```bash
# Mac の場合
ipconfig getifaddr en0
# または
ifconfig | grep "inet " | grep -v 127.0.0.1
```

> **Claude Code を使っている場合:** `/fix-endpoint` スキルを使うと  
> 環境別の選択肢を提示して自動的に変更してくれます。

---

## 実行環境別の起動手順

> **地図表示には Google Maps API キーが必要です**  
> プラン詳細画面の地図を表示するには、[Google Cloud Console](https://console.cloud.google.com/) で
> **Maps SDK for iOS** / **Maps SDK for Android** を有効化し、API キーを取得してください。  
> API キーはリポジトリにコミットせず、以下の方法で設定します：
>
> | プラットフォーム | 設定方法 |
> |---|---|
> | iOS | Xcode > Build Settings > User-Defined に `GOOGLE_MAPS_API_KEY` を追加 |
> | Android | 環境変数 `GOOGLE_MAPS_API_KEY` を設定（`build.gradle.kts` 経由で `AndroidManifest.xml` に注入） |
>
> **未設定の場合でも地図以外の機能は正常に動作します。**

### iOS シミュレーター

#### 1. Xcode のインストール確認

```bash
xcode-select -p
# /Applications/Xcode.app/Contents/Developer と表示されれば OK
```

表示されない場合は Mac App Store から Xcode をインストールしてください。

#### 2. iOS シミュレーターの起動

```bash
# シミュレーターアプリを開く
open -a Simulator
```

または Xcode メニュー → **Open Developer Tool** → **Simulator** から起動。

#### 3. 利用可能なデバイスの確認

```bash
flutter devices
```

出力例:
```
iPhone 16 Pro (mobile) • <デバイスID> • ios • com.apple.CoreSimulator...
```

#### 4. 接続 URL の設定（自動）

iOS シミュレーター用の `http://localhost:4000/graphql` は **自動で設定されます**。  
`graphql_config.dart` を手動で変更する必要はありません。

#### 5. アプリの起動

```bash
cd travel_booking_mobile

# デバイスを選択して起動（複数デバイスがある場合）
flutter run

# 特定のデバイスを指定して起動
flutter run -d <シミュレーターのデバイスID>

# 最新の iPhone シミュレーターを自動選択
flutter run -d "iPhone"
```

---

### Android エミュレーター

#### 1. Android Studio と AVD のセットアップ

1. [Android Studio](https://developer.android.com/studio) をインストール
2. Android Studio → **Virtual Device Manager** → **Create Device**
3. デバイスを選択（例: Pixel 8）し、システムイメージをダウンロード（API 34 以上推奨）

#### 2. エミュレーターの起動

```bash
# コマンドラインで起動
emulator -avd <AVD名>
# または Android Studio の Virtual Device Manager から再生ボタン

# 起動確認
flutter devices
# emulator-5554 と表示されれば OK
```

#### 3. 接続 URL の設定（自動）

Android エミュレーター用の `http://10.0.2.2:4000/graphql` は **自動で設定されます**。  
`graphql_config.dart` を手動で変更する必要はありません。

> **なぜ `10.0.2.2` なのか?**  
> Android エミュレーターの `localhost` はエミュレーター自身を指します。  
> ホスト PC（Mac）の `localhost` には `10.0.2.2` でアクセスします。  
> `Platform.isAndroid` を使ってビルド時に自動で切り替えています。

#### 4. HTTP 通信の許可（cleartext 設定）

本プロジェクトの `AndroidManifest.xml` には `android:usesCleartextTraffic="true"` が設定済みです。  
API 28 以上の Android で `http://` のローカルサーバーに接続するために必要な設定です。

#### 5. アプリの起動

```bash
cd travel_booking_mobile
flutter run -d emulator-5554
# または
flutter run
```

---

### iOS 実機

#### 前提条件
- Mac に接続した iPhone（USB または Wi-Fi）
- Apple ID（無料の開発者アカウントで OK）

#### 1. 接続 URL の設定

PC と iPhone が **同じ Wi-Fi ネットワーク** に接続されていることを確認し、PC の IP を設定します:

```bash
# PC の IP アドレスを確認
ipconfig getifaddr en0   # 例: 192.168.1.50
```

```dart
// graphql_config.dart
String baseUrl = 'http://192.168.1.50:4000/graphql'  // PC の実際の IP に変更
```

#### 2. デバイスの接続と信頼設定

1. iPhone を USB ケーブルで Mac に接続
2. iPhone に「このコンピュータを信頼しますか？」と表示されたら **「信頼」** をタップ
3. デバイスが認識されているか確認:
   ```bash
   flutter devices
   # iPhone (mobile) • <デバイスID> • ios が表示されれば OK
   ```

#### 3. Xcode での署名設定

```bash
open travel_booking_mobile/ios/Runner.xcworkspace
```

Xcode が開いたら:
1. ナビゲーターで **Runner** を選択
2. **Signing & Capabilities** タブを開く
3. **Team** で自分の Apple ID を選択
4. **Bundle Identifier** を任意の一意な文字列に変更（例: `com.yourname.travelbooking`）

#### 4. アプリのインストールと起動

```bash
cd travel_booking_mobile
flutter run -d <iPhoneのデバイスID>
```

> **「デベロッパを信頼する」の設定が必要な場合:**  
> iPhone の **設定** → **一般** → **VPN とデバイス管理** → デベロッパApp → **信頼** をタップ

---

### Android 実機

#### 前提条件
- USB ケーブルまたは Wi-Fi で接続した Android デバイス
- **USB デバッグの有効化**（下記手順を参照）

#### 1. USB デバッグの有効化

1. Android の **設定** → **デバイス情報**（または「端末情報」）を開く
2. **ビルド番号** を 7 回連続でタップ → 「開発者向けオプションが有効になりました」と表示
3. **設定** → **開発者向けオプション** → **USB デバッグ** をオン

#### 2. デバイスの接続確認

```bash
# USB ケーブルで接続後
flutter devices
# Android デバイス名が表示されれば OK

# 「Allow USB debugging?」が Android 側に表示されたら「許可」をタップ
```

#### 3. 接続 URL の設定

PC と Android が **同じ Wi-Fi ネットワーク** に接続されていることを確認:

```bash
ipconfig getifaddr en0   # PC の IP を確認
```

```dart
// graphql_config.dart
String baseUrl = 'http://192.168.1.50:4000/graphql'  // PC の IP に変更
```

#### 4. HTTP 通信の許可（cleartext 設定）

本プロジェクトの `AndroidManifest.xml` には `android:usesCleartextTraffic="true"` が設定済みです。

#### 5. アプリの起動

```bash
cd travel_booking_mobile
flutter run -d <AndroidデバイスID>
```

---

## 開発コマンド（melos）

> 以下のコマンドはすべて **リポジトリルート**（`travel_booking/`）で実行します。

```mermaid
graph TD
  subgraph Mise["バージョン管理（mise）"]
    FL["Flutter 3.38.5"]
    ND["Node.js 20"]
  end
  subgraph Melos["タスクランナー（melos）"]
    BR["build_runner"]
    TEST["test / analyze"]
    PREV["preview"]
  end
  subgraph Docker["コンテナ（Docker Compose）"]
    MY["MySQL 8.0"]
    BK["Apollo Server<br/>(port 4000)"]
  end
  FL --> BR & TEST & PREV
  ND --> BK
  BK --> MY
```

mise がツールバージョンを固定し、melos がモバイルタスクを束ね、Docker がバックエンドを提供します。

```bash
dart run melos run build_runner          # Riverpod .g.dart ファイルを生成
dart run melos run "build_runner:watch"  # コード生成をウォッチモードで実行
dart run melos run test                  # ユニットテスト実行
dart run melos run analyze               # 静的解析
dart run melos run format                # コードフォーマット
dart run melos run clean                 # ビルド成果物をクリーン
dart run melos run get                   # 依存パッケージを取得
dart run melos run preview               # Widgetbook をデフォルトデバイスで起動
dart run melos run "preview:web"         # Widgetbook を Chrome で起動
```

### バックエンドコマンド

> `travel_booking_backend/` で実行します。

```bash
npm run dev              # 開発サーバー起動（ホットリロード）
npm run db:migrate       # DB マイグレーション実行
npm run db:seed          # シードデータ投入
npm run db:studio        # Prisma Studio 起動（GUI で DB 確認）
npm run db:push          # スキーマ変更を即反映（プロトタイプ時）
npm run db:reset         # DB 完全リセット（全データ削除 → 再マイグレーション）
npm run build            # TypeScript ビルド
npm run start            # 本番サーバー起動
```

---

## Claude Code スキル

このプロジェクトには Claude Code の開発を効率化するカスタムスキルが定義されています。  
詳細な活用ガイドは [`skill_guidance.md`](./skill_guidance.md) を参照してください。

| スキル | 呼び出し方 | 用途 |
|---|---|---|
| `flutter-gen` | `/flutter-gen` | Riverpod `.g.dart` 再生成 |
| `backend-up` | `/backend-up` | Docker バックエンド起動 |
| `db-reset` | `/db-reset` | 開発用 DB 初期化 |
| `fix-endpoint` | `/fix-endpoint [IP]` | 接続先 URL を変更 |
| `graphql-check` | `/graphql-check` | GraphQL スキーマ整合性確認 |
| `add-feature` | `/add-feature <機能名>` | MVVM 雛形ファイル生成 |
| `add-route` | `/add-route <path> <Screen> [--tab]` | GoRoute 追加・ボトムナビ更新 |
| `backend-resolver` | `/backend-resolver <EntityName>` | GraphQL Resolver と typeDefs 生成 |
| `schema-update` | `/schema-update <変更内容>` | 全レイヤースキーマ変更（8ステップ） |
| `bug-trace` | `/bug-trace <エラー>` | バグ原因特定と修正 |
| `add-viewmodel-test` | `/add-viewmodel-test <名前>` | ViewModel テスト追加 |
| `add-mock-data` | `/add-mock-data <条件>` | 条件付きテストデータ DB 投入 |
| `state-audit` | `/state-audit <名前>` | 状態管理監査 |
| `perf-audit` | `/perf-audit <名前>` | パフォーマンス静的監査 |
| `widget-gen` | `/widget-gen <名前>` | 共通ウィジェット雛形生成 |
| `preview-setup` | `/preview-setup [--init] [<名前>]` | Widgetbook Preview 初期化・ケース追加 |

### スキル連携フロー

```mermaid
graph LR
  AF["/add-feature"] --> AR["/add-route"]
  AR --> WG["/widget-gen"]
  WG --> PS["/preview-setup"]
  PS --> AVT["/add-viewmodel-test"]
  AVT --> SA["/state-audit"]
  SA --> GC["/graphql-check"]
  SU["/schema-update"] --> GC
  BR["/backend-resolver"] --> GC
```

機能追加の典型フロー（左→右）と、スキーマ変更・バックエンド追加後の整合性確認（→ graphql-check）を示します。

---

## プロジェクト構成

```
travel_booking/
├── .mise.toml                     # ツールバージョン管理（mise）
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI（Flutter + Node.js）
├── pubspec.yaml                   # ルートワークスペース（melos インストール用）
├── melos.yaml                     # モノレポパッケージ管理
├── CLAUDE.md                      # Claude Code 向けプロジェクト仕様
├── skill_guidance.md              # Claude Code スキル活用ガイド
├── travel_booking_backend/        # バックエンドサービス
└── travel_booking_mobile/         # Flutter モバイルアプリ
```

### バックエンド (`travel_booking_backend/`)

```
travel_booking_backend/
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── package.json
├── prisma/
│   ├── schema.prisma              # DB スキーマ
│   └── seed.ts                    # サンプルデータ
└── src/
    ├── index.ts                   # Apollo Server エントリーポイント (port 4000)
    └── graphql/
        ├── typeDefs.ts            # GraphQL スキーマ定義
        └── resolvers/
            ├── planResolver.ts    # TravelPlan クエリ
            └── bookingResolver.ts # Booking ミューテーション
```

### モバイルアプリ (`travel_booking_mobile/`)

```
lib/
├── core/
│   ├── config/graphql_config.dart  # GraphQLHttpClient（接続先 URL）
│   ├── database/app_database.dart  # SharedPreferences ラッパー
│   ├── router/app_router.dart      # GoRouter 設定
│   └── theme/app_theme.dart        # カラー・テーマ定義
├── data/
│   ├── models/                     # ドメインモデル（fromJson/toJson/copyWith 手書き）
│   ├── datasources/
│   │   ├── remote/                 # GraphQL 通信（http パッケージ）
│   │   └── local/                  # SharedPreferences + Stream
│   └── repositories/               # インターフェース + 実装ペア
├── presentation/
│   ├── viewmodels/                  # @riverpod AsyncNotifier（.g.dart は自動生成）
│   ├── screens/                     # home / plan_detail / booking / favorites
│   └── widgets/                     # 共通ウィジェット
└── preview/                         # Widgetbook Preview 環境（開発用）
    ├── main.dart                    # Widgetbook エントリポイント
    ├── mock_data.dart               # プレビュー用モックプラン
    ├── mock_providers.dart          # FakeInMemoryFavoritesStorage
    ├── main.directories.g.dart      # build_runner 自動生成
    └── components/                  # 各ウィジェットの UseCase 定義
```

---

## アーキテクチャ

### パターン

**MVVM + Repository パターン**

```mermaid
graph TB
  subgraph Presentation["Presentation 層"]
    Screen["Screen<br/>(ConsumerWidget)"]
    VM["ViewModel<br/>(@riverpod Notifier)"]
  end
  subgraph Data["Data 層"]
    Repo["Repository<br/>(abstract)"]
    RepoImpl["RepositoryImpl"]
    RDS["RemoteDataSource<br/>(GraphQL HTTP)"]
    LDS["LocalDataSource<br/>(SharedPreferences)"]
  end
  subgraph Backend["Backend"]
    Apollo["Apollo Server<br/>(port 4000)"]
    Prisma["Prisma ORM"]
    MySQL["MySQL 8.0"]
  end
  Screen -->|watches| VM
  VM --> Repo
  Repo --> RepoImpl
  RepoImpl --> RDS
  RepoImpl --> LDS
  RDS -->|HTTP POST| Apollo
  Apollo --> Prisma
  Prisma --> MySQL
```

Presentation は Riverpod Provider 経由で Data 層を参照し、Backend には RemoteDataSource のみが接触します。

### 技術スタック

#### モバイル

| 技術 | バージョン | 用途 |
|---|---|---|
| Flutter | 3.x | UI フレームワーク |
| Riverpod | 3.x | 状態管理 |
| riverpod_generator | 3.x | `@riverpod` コード生成 |
| go_router | 14.x | ナビゲーション |
| SharedPreferences | 2.x | お気に入りのローカル保存 |
| http | 1.x | GraphQL HTTP クライアント |
| shimmer | 3.x | ローディングアニメーション |
| mockito | 5.x | テスト用モック生成 |
| widgetbook | 3.23.x | ウィジェット Preview 環境（開発用） |

> **Freezed 不使用**: モデルクラスは `copyWith` / `fromJson` / `toJson` を手動実装  
> **graphql_flutter 不使用**: native build hooks によるビルドエラーを回避するため `http` パッケージで実装

#### バックエンド

| 技術 | バージョン | 用途 |
|---|---|---|
| Node.js | 20+ | ランタイム |
| TypeScript | 5.x | 言語 |
| Apollo Server | 4.x | GraphQL サーバー |
| Prisma | 5.x | ORM |
| MySQL | 8.0 | データベース |
| Docker Compose | — | コンテナ管理 |

### Riverpod Provider 依存関係

```mermaid
graph TB
  GQL["graphQLHttpClient\nProvider"]
  RDS["travelPlanRemoteDataSource\nProvider"]
  TPR["travelPlanRepository\nProvider"]
  FST["favoritesStorage\nProvider"]
  FLD["favoriteLocalDataSource\nProvider"]
  FRP["favoriteRepository\nProvider"]
  PIF["planIsFavorite\nProvider(planId)"]
  PLV["planListViewModel\nProvider"]
  PDV["planDetailViewModel\nProvider(id)"]
  BKV["bookingViewModel\nProvider"]
  BHV["bookingHistoryViewModel\nProvider"]
  FAV["favoriteViewModel\nProvider"]

  GQL --> RDS --> TPR
  FST --> FLD
  FLD --> FRP
  FLD --> PIF
  TPR --> PLV
  TPR --> PDV
  TPR --> BKV
  TPR --> BHV
  FRP --> PDV
  FRP --> FAV
```

GraphQL 系（左）と SharedPreferences 系（右）の 2 系統で構成し、planDetailViewModel は両方に依存します。

### ルーティング（GoRouter）

```mermaid
graph TD
  Nav["BottomNavBar<br/>(StatefulShellRoute)"]
  Home["/\nHomeScreen"]
  Fav["/favorites\nFavoritesScreen"]
  Hist["/booking-history\nBookingHistoryScreen"]
  PD["/plan/:id\nPlanDetailScreen"]
  BK["/plan/:id/booking\nBookingScreen"]
  FPD["/favorites/plan/:id\nPlanDetailScreen"]
  Conf["/booking/confirmation/:bookingId\nBookingConfirmationScreen"]

  Nav -->|"Tab: プラン"| Home
  Nav -->|"Tab: お気に入り"| Fav
  Nav -->|"Tab: 予約履歴"| Hist
  Home --> PD --> BK
  Fav --> FPD
  BK -->|"push(extra)"| Conf
```

ボトムナビ 3 タブ構成（StatefulShellRoute）で、BookingConfirmationScreen のみシェル外のトップレベルルートです。

---

## GraphQL API リファレンス

### クエリ

```graphql
# プラン一覧取得（フィルタ・ページネーション対応）
query GetTravelPlans($filter: PlanFilterInput, $page: Int, $pageSize: Int) {
  travelPlans(filter: $filter, page: $page, pageSize: $pageSize) {
    plans { id title destination price effectivePrice rating isAvailable }
    totalCount hasNextPage currentPage totalPages
  }
}

# プラン詳細取得（全情報）
query GetTravelPlan($id: ID!) {
  travelPlan(id: $id) {
    id title description latitude longitude meetingPoint cancellationPolicy
    itinerary { dayNumber title activities { name startTime duration } }
    reviews { reviewerName rating comment }
    includedItems { item }
    excludedItems { item }
  }
}
```

### ミューテーション

```graphql
# 予約作成
mutation CreateBooking($input: CreateBookingInput!) {
  createBooking(input: $input) {
    success message
    booking { id status totalPrice travelDate }
  }
}

# 予約キャンセル
mutation CancelBooking($id: ID!) {
  cancelBooking(id: $id) { success message }
}
```

### フィルタオプション

| フィールド | 値 |
|---|---|
| `category` | `city` / `cultural` / `nature` / `adventure` / `leisure` |
| `region` | `アジア` / `ヨーロッパ` / `アメリカ大陸` / `オセアニア` / `アフリカ` |
| `difficulty` | `easy` / `moderate` / `hard` |
| `sortBy` | `rating` / `price` / `duration` / `createdAt` |
| `minPrice` / `maxPrice` | 価格帯（円） |
| `maxDuration` | 最大日数 |

### シードデータ（旅行プラン 30 件）

<details>
<summary>シードデータ一覧（全30件）— クリックで展開</summary>

| # | プラン名 | 目的地 | カテゴリ | 地域 | 料金/人 |
|---|---|---|---|---|---|
| 1 | 東京エクスプローラー5日間 | 東京 | city | アジア | ¥150,000 |
| 2 | 京都伝統文化探訪4日間 | 京都 | cultural | アジア | ¥120,000 |
| 3 | 北海道大自然アドベンチャー7日間 | 北海道 | nature | アジア | ¥200,000 |
| 4 | パリ・ロマンス＆カルチャー6日間 | パリ | leisure | ヨーロッパ | ¥280,000 |
| 5 | スイスアルプス トレッキング8日間 | インターラーケン他 | adventure | ヨーロッパ | ¥350,000 |
| 6 | バリ島スピリチュアルリトリート5日間 | ウブド・バリ | leisure | アジア | ¥100,000 |
| 7 | ニューヨーク・シティ・エクスペリエンス4日間 | ニューヨーク | city | アメリカ大陸 | ¥180,000 |
| 8 | オーストラリア グレートバリアリーフ6日間 | ケアンズ | adventure | オセアニア | ¥320,000 |
| 9 | モロッコ砂漠とメディナ7日間 | マラケシュ他 | adventure | アフリカ | ¥160,000 |
| 10 | サントリーニ島 エーゲ海5日間 | サントリーニ島 | leisure | ヨーロッパ | ¥250,000 |
| 11 | 上海アート&グルメ探訪3日間 | 上海 | city | アジア | ¥65,000 |
| 12 | メキシコシティ 歴史&グルメ探訪4日間 | メキシコシティ | city | アメリカ大陸 | ¥78,000 |
| 13 | プラハ・ウィーン 中欧芸術の旅6日間 | プラハ・ウィーン | cultural | ヨーロッパ | ¥245,000 |
| 14 | エジプト 古代遺跡&ナイル川クルーズ5日間 | カイロ・ルクソール | cultural | アフリカ | ¥155,000 |
| 15 | ニュージーランド フィヨルドランド6日間 | クイーンズタウン他 | nature | オセアニア | ¥280,000 |
| 16 | カナダ バンフ国立公園 ロッキー絶景5日間 | バンフ・ルイーズ湖 | nature | アメリカ大陸 | ¥190,000 |
| 17 | キリマンジャロ登山チャレンジ7日間 | キリマンジャロ | adventure | アフリカ | ¥460,000 |
| 18 | アイスランド オーロラ&氷河5日間 | レイキャビク他 | adventure | ヨーロッパ | ¥390,000 |
| 19 | バンコク 寺院巡り&スパ3日間 | バンコク | leisure | アジア | ¥58,000 |
| 20 | フィジー 水上バンガロー楽園5日間 | ナディ・マナ島 | leisure | オセアニア | ¥400,000 |
| 21 | タヒチ・ボラボラ島 南太平洋楽園5日間 | タヒチ・ボラボラ島 | leisure | オセアニア | ¥480,000 |
| 22 | ケニア マサイマラ 大サファリ体験7日間 | ナイロビ・マサイマラ | nature | アフリカ | ¥420,000 |
| 23 | インド ラジャスタン王侯の旅8日間 | デリー・ジャイプール他 | cultural | アジア | ¥195,000 |
| 24 | ペルー マチュピチュ&インカ帝国7日間 | リマ・クスコ他 | adventure | アメリカ大陸 | ¥320,000 |
| 25 | 南アフリカ ケープタウン&ワインランド5日間 | ケープタウン他 | adventure | アフリカ | ¥285,000 |
| 26 | 台湾一周鉄道旅行5日間 | 台北・九份他 | cultural | アジア | ¥95,000 |
| 27 | コスタリカ エコツーリズム7日間 | サンホセ他 | nature | アメリカ大陸 | ¥165,000 |
| 28 | スペイン バルセロナ&アンダルシア8日間 | バルセロナ他 | cultural | ヨーロッパ | ¥145,000 |
| 29 | タンザニア セレンゲティ 大移動サファリ7日間 | アルーシャ他 | nature | アフリカ | ¥450,000 |
| 30 | ブラジル リオ&アマゾン 大自然と情熱7日間 | リオデジャネイロ他 | leisure | アメリカ大陸 | ¥280,000 |

</details>

---

## テスト

ViewModel の全メソッドに対してユニットテストを実装しています（Mockito + ProviderContainer）。

```bash
# リポジトリルートで実行
dart run melos run test

# または travel_booking_mobile/ で直接実行
flutter test
```

| テストファイル | テスト内容 |
|---|---|
| `plan_list_viewmodel_test.dart` | 初期状態・プラン取得・エラー処理・フィルタ・無限スクロール |
| `plan_detail_viewmodel_test.dart` | 詳細取得・お気に入りトグル・エラー処理 |
| `booking_viewmodel_test.dart` | フォームバリデーション・予約成功/失敗・料金計算・リセット |
| `favorite_viewmodel_test.dart` | 一覧取得・リアルタイム更新・削除・エラー処理 |
| `booking_history_viewmodel_test.dart` | 初期状態・予約履歴取得・空リスト・エラー処理・メールバリデーション・clearError・二重実行防止 |

### テストでのモック再生成

ViewModel やモデルを変更してテストファイルの `@GenerateMocks` を更新した後は以下を実行:

```bash
dart run melos run build_runner
```

`test/viewmodels/*.mocks.dart` が更新されます。

---

## Widgetbook Preview

`lib/preview/` に [Widgetbook 3.x](https://docs.widgetbook.io/) を使ったウィジェット Preview 環境を用意しています。  
デザイン確認・コンポーネントのバリエーション検証をバックエンド・GoRouter 不要で行えます。

### 起動方法

```bash
# Chrome で確認（ウィンドウサイズ調整しやすくておすすめ）
dart run melos run "preview:web"

# デフォルトデバイス（iOS Simulator など）で確認
dart run melos run preview
```

### 収録コンポーネント

| コンポーネント | UseCase 数 | バリエーション |
|---|:---:|---|
| `RatingStars` | 3 | 高評価・中評価（レビュー数なし）・低評価（大サイズ） |
| `LoadingIndicator` | 2 | メッセージあり・なし |
| `AppErrorWidget` | 2 | 再試行ボタンあり・なし |
| `PlanCard` | 3 | 通常プラン・セール（割引バッジあり）・ハード難易度 |

### アドオン構成

| アドオン | 内容 |
|---|---|
| MaterialThemeAddon | Light テーマ（`AppTheme.lightTheme`） |
| ViewportAddon | iPhone 13 / Samsung Galaxy A50 |
| TextScaleAddon | 0.85〜2.0 倍 |
| LocalizationAddon | ja_JP |

### 新しいコンポーネントを追加するには

1. `lib/preview/components/xxx_preview.dart` を作成し `@widgetbook.UseCase()` を定義する
2. `dart run melos run build_runner` で `main.directories.g.dart` を再生成する
3. `dart run melos run "preview:web"` で動作確認する

`ConsumerWidget`（Riverpod 依存あり）の場合は `ProviderScope(overrides: previewProviderOverrides, child: ...)` でラップする。

---

## トラブルシューティング

### バックエンド関連

#### `mysql: healthy` にならない / バックエンドが起動しない

```bash
# コンテナのログを確認
docker compose logs mysql --tail=30
docker compose logs backend --tail=30

# コンテナを完全に停止・削除して再起動
docker compose down -v
docker compose up -d
```

ポート競合が原因の場合:

```bash
# 3306 / 4000 ポートを使っているプロセスを確認
lsof -i :3306
lsof -i :4000
```

#### `db:migrate` でマイグレーション名の入力後にエラー

`.env` の `DATABASE_URL` が設定されているか確認:

```bash
cat travel_booking_backend/.env
# DATABASE_URL="mysql://root:password@localhost:3306/travel_booking" と表示されれば OK
```

---

### 接続関連

#### `SocketException: Connection refused` または `Connection refused`

1. バックエンドが起動しているか確認: `docker compose ps`
2. `graphql_config.dart` の URL が正しいか確認（下表参照）
3. 実機の場合は PC と同じ Wi-Fi に接続されているか確認

| 環境 | 正しい URL |
|---|---|
| iOS シミュレーター | `http://localhost:4000/graphql` |
| Android エミュレーター | `http://10.0.2.2:4000/graphql` |
| iOS / Android 実機 | `http://<PC の IP>:4000/graphql` |

> **Claude Code を使っている場合:** `/fix-endpoint` で現在の設定を確認・変更できます。

#### Android で `Cleartext HTTP traffic not permitted`

`AndroidManifest.xml` に `android:usesCleartextTraffic="true"` が設定されているか確認してください。  
本プロジェクトでは設定済みですが、設定が失われた場合は `<application>` タグに追加してください:

```xml
<application
    android:usesCleartextTraffic="true"
    ... >
```

---

### Flutter / Dart 関連

#### `The getter 'xxxProvider' isn't defined for the class`

`.g.dart` ファイルの再生成が必要です:

```bash
dart run melos run build_runner
```

#### `melos: command not found` が出る

`melos` がグローバルインストールされていません。以下を実行してください：

```bash
dart pub global activate melos
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

PATH を永続化するには `~/.zshrc`（または `~/.bashrc`）に上記の `export` 行を追記して `source ~/.zshrc` を実行してください。

#### `melos bootstrap` に失敗する

```bash
# まず dart pub get を実行
dart pub get
# その後再試行
dart run melos bootstrap

# それでも失敗する場合は直接インストール
cd travel_booking_mobile && flutter pub get
```

#### iOS ビルドで `CocoaPods not installed` / Pod 関連エラー

```bash
cd travel_booking_mobile/ios
pod install --repo-update
cd ..
flutter run
```

CocoaPods 未インストールの場合:

```bash
sudo gem install cocoapods
```

#### Android ビルドで `Gradle` 関連エラー

```bash
cd travel_booking_mobile
flutter clean
flutter pub get
flutter run
```

#### `flutter devices` に何も表示されない

**iOS シミュレーターの場合:**
```bash
open -a Simulator
# シミュレーターが起動してから再度 flutter devices を実行
```

**Android エミュレーターの場合:**
- Android Studio → Virtual Device Manager でエミュレーターを起動してから再実行

**実機の場合:**
- USB ケーブルを抜き差しして再実行
- `flutter doctor` で Xcode / Android Studio の設定を確認

---

### DB 関連

#### テストデータが壊れた・クリーンな状態に戻したい

```bash
cd travel_booking_backend
docker compose exec backend npm run db:reset
docker compose exec backend npm run db:seed
```

> **Claude Code を使っている場合:** `/db-reset` スキルで確認プロンプト付きで実行できます。

---

### mise 関連

#### `mise install` で失敗する

mise 自体が古い可能性があります。アップグレードしてから再試行してください:

```bash
brew upgrade mise
mise install
```

#### mise を使わずにセットアップしたい

`.mise.toml` に記載されているバージョンを参考に、各ツールを手動でインストールしてください:

| ツール | バージョン | 公式ページ |
|---|---|---|
| Flutter | 3.38.5 | https://docs.flutter.dev/get-started/install |
| Node.js | 20 | https://nodejs.org/ |
