# ADR-007: MVVM + Repository パターンの採用

## ステータス

承認済み

## 日付

2026-10-04

## 背景

旅行プランの閲覧・検索・予約ができる Flutter アプリ（`travel_booking_mobile`）を構築するにあたり、GraphQL バックエンドとの通信、ローカルストレージ（お気に入り・閲覧履歴）、画面の状態管理をどのように責務分離するかが設計上の主要な課題だった。

具体的には以下の要件を満たす必要があった。

- **6 画面・6 ViewModel**（home / plan_detail / booking / favorites / booking_history / recently_viewed）が同一パターンで実装され、画面追加時にアーキテクチャが安定していること
- **GraphQL（Remote）と SharedPreferences（Local）** という異なるデータソースを統一的に扱い、お気に入りのようにリアルタイムで複数画面へ変更を通知する仕組みが必要
- **テスト容易性**：各レイヤーを独立してテストでき、mock への差し替えが容易であること
- **エラーハンドリングの統一**：通信エラー・GraphQL エラー・バリデーションエラーを型安全に分類し、UI 層で一貫した表示ができること
- **AI 活用との親和性**：Claude Code のカスタムスキル（`/add-feature` で雛形生成、`/add-viewmodel-test` でテスト自動生成）がパターンを前提に動作できること

## 検討した選択肢

### 1. MVVM + Repository（採用）

ViewModel（`@riverpod AsyncNotifier`）が画面の状態を管理し、Repository（interface + impl）がデータソースの切り替えを吸収する 3 層構造。Riverpod 3.x のコード生成（`riverpod_generator`）と自然に対応する。

### 2. Clean Architecture（UseCase 層あり）

Repository と ViewModel の間に UseCase 層を挟み、「1 UseCase = 1 ビジネスルール」として分離する。Google の推奨アーキテクチャにも近い構成。

### 3. MVC（Model-View-Controller）

Controller が入力を受け取り Model を更新、View が Model を描画する古典的パターン。Flutter の Widget ツリーとの相性や、状態管理ライブラリとの統合に課題がある。

### 4. BLoC パターン

Event / State を明示的に定義し、Stream ベースで状態変更を伝播させるパターン。`flutter_bloc` パッケージが標準的な実装を提供する。

## 決定

**MVVM + Repository パターンを採用する。UseCase 層は設けず、ViewModel が Repository を直接呼び出す構成とする。** 状態管理には Riverpod 3.x（`@riverpod` アノテーションによるコード生成）を使用する。

加えて、以下の横断的設計を合わせて採用した。

- **`GraphQLClientInterface`**：GraphQL 通信クライアントを `abstract interface class GraphQLClientInterface` として抽象化し、`GraphQLHttpClient` がその実装を担う。テストでの差し替えおよび将来的な実装変更に備える。
- **`AppError` sealed class**：ViewModel のエラー状態を `sealed class AppError` で型安全に表現する。サブクラスは `NetworkError`・`GraphQLError`・`ValidationError`・`UnknownError` の 4 種で、UI 層は `switch` 式による網羅的なパターンマッチングでエラー種別に応じた表示を行う。
- **`AsyncStateBuilder<T>` ウィジェット**：loading / error / data の 3 状態分岐を共通ウィジェット `AsyncStateBuilder<T>` として抽象化する。全 Screen がこのウィジェットを経由して状態を描画し、`AppErrorWidget` や `LoadingIndicator` を直接 if 文で分岐させない。

## 理由

### Riverpod との自然な対応

Riverpod 3.x の `@riverpod` アノテーションから生成される `AsyncNotifier` が、MVVM の ViewModel の責務とそのまま一致する。`build()` で初期データを取得し、State を `copyWith` で更新するパターンが自然に成立するため、ViewModel の設計に特別な工夫が不要だった。

Riverpod は実務での採用実績が多く、Flutter の状態管理ライブラリとして広く支持されている。`riverpod_generator` によるコード生成も強力で、Provider の定義を `@riverpod` アノテーション一つで完結できるため、ボイラープレートが最小限に抑えられている。

### UseCase 層は現在の規模では過剰

Clean Architecture の導入も検討したが、現状の ViewModel のメソッド（`loadPlans` / `loadMore` / `submitBooking` / `toggleFavorite` / `loadBookings` / `clearHistory` など）はいずれも Repository の 1 メソッドを呼び出すだけで、複数 Repository を組み合わせる複雑なユースケースが存在しない。UseCase を入れると「Repository のメソッドをそのまま委譲するだけの中間クラス」が量産され、コードの見通しがかえって悪くなると判断した。

### DI とテストの容易性

`TravelPlanRepository`・`FavoriteRepository`・`RecentlyViewedRepository` をそれぞれインターフェース（`abstract class`）と実装（`Impl`）に分離し、Riverpod の Provider で DI する構成にしたことで、テストで mock に差し替えるのが容易になっている。同様に `GraphQLClientInterface` を抽象化したことで、DataSource レイヤーもテスト時に差し替え可能となっている。実際に `@GenerateMocks` と `ProviderContainer.overrides` を組み合わせた ViewModel テストが 6 件、Widget テストが 6 件稼働しており、この DI 設計がテストピラミッドの土台として機能している。

### AppError による型安全なエラーハンドリング

Flutter の `sealed class` 機構を利用した `AppError` により、ViewModel が throw するエラーを 4 種類に分類している。`NetworkError` のみリトライボタンを表示する、`ValidationError` はフォームフィールド単位でメッセージを表示するなど、エラー種別に応じた UI 分岐を `switch` 式で網羅的に記述できる。型安全な分岐は将来的なエラー種別の追加時にコンパイルエラーで検出できるため、ハンドリング漏れを防ぐ。

### AsyncStateBuilder による状態描画の統一

loading / error / data の 3 状態は全 Screen で共通して扱われる。`AsyncStateBuilder<T>` を設けたことで、各 Screen は状態描画のロジックを持たずに済み、`builder` / `emptyBuilder` / `onRetry` の 3 コールバックを渡すだけでよい。`isLoading == true && data != null` の条件（loadMore 中に既存データを継続表示）など、状態が複合した場合の挙動も 1 箇所で管理される。

### AI 活用・スキルとの親和性

「Screen → ViewModel → Repository → DataSource」という一定のパターンが全画面で統一されているため、21 のカスタムスキルがこのパターンを前提に動作できる。`/add-feature` で MVVM 雛形を一括生成し、`/add-viewmodel-test` でテストコードを自動生成し、`/refactor-screen` で既存画面をリファクタするフローが確立している。レイヤー構成が複雑になるほどスキルのテンプレートも複雑になるため、シンプルな 3 層構造が AI 活用の観点でも有利だった。

### BLoC を選ばなかった理由

BLoC の Event / State パターンは厳格で型安全だが、小さな画面（お気に入り一覧、予約履歴など）でも Event クラスと State クラスの定義が必要になりボイラープレートが多い。Riverpod の `@riverpod AsyncNotifier` であれば、メソッドを直接呼び出す形で同等の状態管理ができ、コード量が少なく済む。

## 結果

### 得られたもの

- **パターンの安定性**：6 画面すべてが同じ「Screen → ViewModel → Repository → DataSource」の構造で統一されており、新画面追加のコストが低い
- **テスト基盤**：ViewModel テスト 6 件 + Widget テスト 6 件（Flutter）、Resolver テスト 29 件（Jest / 3 スイート）が CI で自動実行される体制が構築できた
- **スキルの定型化**：21 のカスタムスキルが MVVM パターンを前提に設計されており、`/add-feature` → `/add-route` → `/add-widget-test` → `/add-viewmodel-test` の一貫したフローが機能している
- **リアルタイム更新**：`FavoriteLocalDataSource` の `StreamController<List<FavoritePlan>>.broadcast()` パターンが Repository 層で吸収され、複数画面への変更通知が自然に動作している
- **型安全なエラーハンドリング**：`AppError` sealed class により、エラー種別に応じた UI 分岐がコンパイル時に保証される
- **状態描画の一貫性**：`AsyncStateBuilder<T>` により、loading / error / data の描画ロジックが全 Screen で統一されている

### トレードオフ

- **ViewModel の肥大化リスク**：UseCase 層がないため、ビジネスロジックが複雑化すると ViewModel が肥大化する可能性がある。予約フォームの `BookingViewModel`（`currentStep` / `validateStep` / `nextStep` 等のステップ管理 + 6 フィールドのバリデーション）で既にその兆候が見え始めている
- **将来の UseCase 導入コスト**：複数 Repository を横断するロジック（例：認証導入時に User + Booking + Favorite を組み合わせる処理）が出てきた場合、UseCase 層の導入を再検討する必要がある。Repository → ViewModel の間に UseCase を挟む形での後追い導入は構造上可能
- **Repository のインターフェースと実装が 1:1 で冗長**：現時点で各 Repository の実装が 1 つしかないため、インターフェース分離が冗長に感じる場面もある。ただしテストでの mock 差し替えおよび Preview 環境でのフェイク実装（`FakeTravelPlanRepository`）に必要なため、この冗長さはテスト容易性とのトレードオフとして受容している

## 参考

- [Flutter アーキテクチャガイド（公式）](https://docs.flutter.dev/app-architecture)
- [Riverpod 公式ドキュメント](https://riverpod.dev/)
- [go_router 公式パッケージ](https://pub.dev/packages/go_router)
- 本プロジェクトの [architecture_guidance.md](../../architecture_guidance.md)
