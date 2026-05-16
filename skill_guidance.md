# Claude Code スキル活用ガイド — travel_booking

このプロジェクトには 10 個のカスタムスキル（スラッシュコマンド）が定義されています。
Claude Code のチャット欄で `/コマンド名 [引数]` と入力することで実行できます。

---

## 目次

1. [スキル一覧早見表](#1-スキル一覧早見表)
2. [開発環境セットアップ系](#2-開発環境セットアップ系)
   - [`/backend-up`](#backend-up--バックエンド環境起動)
   - [`/db-reset`](#db-reset--開発用db初期化)
   - [`/fix-endpoint`](#fix-endpoint--graphqlエンドポイント設定)
3. [コード生成・整合性チェック系](#3-コード生成整合性チェック系)
   - [`/flutter-gen`](#flutter-gen--riverpodコード生成)
   - [`/graphql-check`](#graphql-check--graphql整合性チェック)
4. [機能開発系](#4-機能開発系)
   - [`/add-feature`](#add-feature--mvvm機能スキャフォールド)
   - [`/schema-update`](#schema-update--全レイヤースキーマ変更)
5. [バグ調査・品質改善系](#5-バグ調査品質改善系)
   - [`/bug-trace`](#bug-trace--バグ原因特定と修正)
   - [`/add-viewmodel-test`](#add-viewmodel-test--viewmodelテスト追加)
   - [`/state-audit`](#state-audit--状態管理監査)
6. [シナリオ別推奨フロー](#6-シナリオ別推奨フロー)

---

## 1. スキル一覧早見表

| コマンド | 引数 | 用途 | 引数なし可 |
|---|---|---|:---:|
| `/backend-up` | なし | Docker で MySQL + GraphQL サーバーを起動 | ✓ |
| `/db-reset` | なし | 開発用 DB をリセット＋シード再投入 | ✓ |
| `/fix-endpoint` | IPアドレス or ホスト名 | GraphQL 接続先を変更 | ✓ |
| `/flutter-gen` | なし | Riverpod `.g.dart` ファイルを再生成 | ✓ |
| `/graphql-check` | なし | バックエンドとモバイルの GraphQL 整合性を確認 | ✓ |
| `/add-feature` | 機能名（英語） | MVVM+Repository の雛形ファイルを一括生成 | — |
| `/schema-update` | 変更内容（日本語） | DB〜Dart まで全レイヤーのスキーマ変更をガイド | — |
| `/bug-trace` | エラーメッセージ | バグ原因を特定して修正 | — |
| `/add-viewmodel-test` | ViewModel名 | ViewModel のユニットテストを追加 | — |
| `/state-audit` | ViewModel名 or 画面名 | 状態管理の問題点をチェック | — |

> `—` は引数必須、`✓` は引数なしでも動作します。

---

## 2. 開発環境セットアップ系

### `/backend-up` — バックエンド環境起動

#### 概要
`travel_booking_backend/` の Docker Compose を起動し、MySQL と Apollo GraphQL サーバーを立ち上げます。
ヘルスチェックの確認、GraphQL エンドポイントの疎通確認まで自動で行います。

#### 使い方
```
/backend-up
```

#### 実行内容
1. `docker-compose up -d` でコンテナをバックグラウンド起動
2. `docker-compose ps` でコンテナ状態を確認
3. MySQL の health check が `healthy` になるまで待機
4. `http://localhost:4000/graphql` が応答するか確認
5. 使えるツール（GraphQL Playground、Prisma Studio 等）を案内

#### こんな時に使う
- 朝の開発開始時にバックエンドをまとめて起動したいとき
- `Connection refused` エラーが出てバックエンドの状態を確認したいとき
- Docker コンテナが正常に動いているか確認したいとき

#### 注意点
- Docker Desktop が起動していることが前提です
- ポート 3306（MySQL）・4000（GraphQL）が他のプロセスで使われていると失敗します
- 初回は MySQL イメージのダウンロードが発生するため数分かかります

---

### `/db-reset` — 開発用DB初期化

#### 概要
`travel_booking` データベースを完全リセットし、`prisma/seed.ts` のシードデータを再投入します。
実行前に確認プロンプトが表示されます。

#### 使い方
```
/db-reset
```

#### 実行内容
1. 「本当にリセットしますか？」の確認を求める
2. `npm run db:reset`（Prisma migrate reset --force）を実行
3. `npm run db:seed` でシードデータを投入
4. 投入されたデータ件数（TravelPlan 数、Booking 数）を報告

#### こんな時に使う
- テスト中にデータが壊れてクリーンな状態に戻したいとき
- スキーマ変更後に全データを一から作り直したいとき
- 開発環境を初期状態にリセットしたいとき

#### 注意点
> **警告**: 全データが削除されます。開発環境専用です。
> 本番環境では絶対に使用しないでください（本番は `npm run db:migrate:prod`）。
- バックエンド Docker が起動していないと失敗します。先に `/backend-up` を実行してください
- `.env` の `DATABASE_URL` が開発用 MySQL を指していることを確認してください

---

### `/fix-endpoint` — GraphQL エンドポイント設定

#### 概要
`core/config/graphql_config.dart` の `_baseUrl`（GraphQL 接続先 IP）を確認・変更します。
PC の IP アドレスが変わった時や、実機テストに切り替えるときに使います。

#### 使い方

**現在の設定を確認して選択肢を提示してもらう場合:**
```
/fix-endpoint
```

**特定の IP アドレスに変更する場合:**
```
/fix-endpoint 192.168.1.50
/fix-endpoint localhost
```

#### 実行内容（引数あり）
1. 現在の `_baseUrl` を表示
2. 指定アドレスに変更（ポート `4000/graphql` は維持）
3. 変更後の URL を確認

#### 実行内容（引数なし）
1. 現在の `_baseUrl` を表示
2. 環境別の推奨設定を提案：

| 実行環境 | 推奨設定 |
|---|---|
| iOS シミュレーター | `http://localhost:4000/graphql` |
| Android エミュレーター | `http://10.0.2.2:4000/graphql` |
| 実機（LAN） | `http://<ホストPCのIP>:4000/graphql` |

3. `--dart-define` を使った環境別設定へのリファクタも提案

#### こんな時に使う
- 自宅 Wi-Fi から職場 Wi-Fi に変わって PC の IP が変わったとき
- シミュレーターから実機に切り替えるとき
- `SocketException: Connection refused` が発生したとき
- 接続先を `--dart-define` で環境変数化したいとき

---

## 3. コード生成・整合性チェック系

### `/flutter-gen` — Riverpod コード生成

#### 概要
`melos run build_runner` を実行し、`@riverpod` アノテーション付きクラスから `.g.dart` ファイルを再生成します。

#### 使い方
```
/flutter-gen
```

#### 実行内容
1. `melos run build_runner` を実行
2. 生成・更新されたファイルを一覧表示
3. エラーがあれば原因と修正方法を日本語で説明

#### こんな時に使う
- `@riverpod` アノテーション付きの ViewModel を新規作成・変更したとき
- `The getter 'xxxProvider' isn't defined` エラーが出たとき
- `.g.dart` ファイルと実装の内容がずれていそうなとき
- `add-feature` や `add-viewmodel-test` の実行後

#### 補足
ウォッチモードで常時生成したい場合は Claude Code 外で以下を実行してください：
```bash
melos run build_runner:watch
```

---

### `/graphql-check` — GraphQL 整合性チェック

#### 概要
バックエンドの GraphQL スキーマ（`typeDefs.ts`）とモバイルアプリのクエリ文字列（`TravelPlanRemoteDataSource`）を比較し、型・フィールドの不整合を検出します。

#### 使い方
```
/graphql-check
```

#### チェック内容
- モバイルが要求しているフィールドがバックエンドスキーマに存在するか
- Query/Mutation 名がバックエンドの Resolver に存在するか
- 変数の型（`$id: ID!`、`$input: CreateBookingInput!` 等）がスキーマと一致するか
- バックエンドに定義済みだがモバイルで未使用のフィールドがあるか

#### 出力例
```
【高】GetTravelPlan クエリで `updatedAt` を要求しているが typeDefs.ts に未定義
  - typeDefs.ts: TravelPlan type に updatedAt フィールドを追加してください

【低】TravelPlan.meetingPoint はスキーマに定義されているがモバイル側クエリで未取得
  - 不要であれば typeDefs.ts から削除を検討してください

整合性に問題のある箇所: 1件（高: 1、中: 0、低: 1）
```

#### こんな時に使う
- バックエンドのスキーマを変更した後にモバイル側への影響を確認したいとき
- GraphQL エラーが出てどこが原因か分からないとき
- スキーマレビュー前の自己チェックとして

---

## 4. 機能開発系

### `/add-feature` — MVVM 機能スキャフォールド

#### 概要
新しい機能名を指定すると、MVVM + Repository パターンに沿った雛形ファイルを一括生成します。

#### 使い方
```
/add-feature hotel_search
/add-feature review_submission
/add-feature user_profile
```

> 機能名は英語のスネークケースで指定してください。

#### 生成されるファイル（例: `hotel_search`）

**データ層**
```
lib/data/
├── models/hotel_search.dart                              # データモデル
├── datasources/remote/hotel_search_remote_datasource.dart  # GraphQL クエリ
└── repositories/
    ├── hotel_search_repository.dart                     # インターフェース
    └── hotel_search_repository_impl.dart               # 実装
```

**プレゼンテーション層**
```
lib/presentation/
├── viewmodels/hotel_search_viewmodel.dart               # @riverpod AsyncNotifier
└── screens/hotel_search/hotel_search_screen.dart        # ConsumerWidget
```

#### 生成後の手順（自動案内）
1. `app_router.dart` への新ルート追加方法を案内
2. `melos run build_runner` で `.g.dart` を生成

#### こんな時に使う
- 全く新しい画面・機能を追加するとき
- 既存コードのアーキテクチャパターンを統一したいとき

#### 注意点
- 生成後に各ファイルの `TODO` コメント箇所（GraphQL クエリ等）を実装してください
- 既存ファイルのスタイル参考: `plan_list_viewmodel.dart`、`home_screen.dart`

---

### `/schema-update` — 全レイヤースキーマ変更

#### 概要
Prisma スキーマへのフィールド追加・変更を起点として、GraphQL スキーマ → Resolver → Dart モデル → DataSource クエリ → DB マイグレーション → コード再生成まで、全 8 ステップをガイドします。

#### 使い方
```
/schema-update TravelPlan に評価コメント数フィールド(reviewCount)を追加
/schema-update Booking に支払い確認日時(paidAt)フィールドを nullable で追加
/schema-update Review モデルに役立った数(helpfulCount Int デフォルト0)を追加
```

#### 実行ステップ

```
Step 1  prisma/schema.prisma         フィールド追加
Step 2  src/graphql/typeDefs.ts      GraphQL スキーマ更新
Step 3  src/graphql/resolvers/       Resolver 更新
Step 4  lib/data/models/xxx.dart     Dart モデル更新（fromJson/toJson/copyWith）
Step 5  remote_datasource.dart       クエリ文字列にフィールド追加
Step 6  npm run db:migrate           DB マイグレーション実行
Step 7  melos run build_runner       .g.dart 再生成
Step 8  解析・テスト確認             動作確認
```

#### こんな時に使う
- バックエンドとフロントエンドをまたがるスキーマ変更をするとき
- どのファイルを修正すればいいか分からないとき
- 変更漏れが心配なとき（フィールド1つの追加でも7ファイル以上が対象）

#### 注意点
- Step 6 の DB マイグレーションは Docker が起動していないと失敗します
- nullable フィールドを non-null に変更する場合は既存データの移行戦略が必要です

---

## 5. バグ調査・品質改善系

### `/bug-trace` — バグ原因特定と修正

#### 概要
エラーメッセージやスタックトレースを貼り付けると、このプロジェクト固有のバグパターンと照合して原因箇所を特定・修正します。

#### 使い方
```
/bug-trace The getter 'planListViewModelProvider' isn't defined for the class
/bug-trace Exception: GraphQL request failed: 400
/bug-trace Null check operator used on a null value
/bug-trace GoException: No routes for location: /booking/plan-999
```

#### 対応するエラー種別

| 種別 | 症状例 | 典型的な原因 |
|---|---|---|
| Riverpod / コード生成 | `getter 'xxxProvider' isn't defined` | `.g.dart` の再生成忘れ |
| Riverpod / コード生成 | `ProviderNotFoundException` | `ProviderScope` ラップ漏れ |
| GraphQL 通信 | `GraphQL request failed: 4xx` | Resolver のエラー、スキーマ不整合 |
| GraphQL 通信 | `Connection refused` / `SocketException` | Docker 未起動、IP アドレス違い |
| JSON パース | `Null check operator used on a null value` | `fromJson` の型キャスト (`as String` → `as String?`) |
| Navigation | `GoException: No routes for location` | `app_router.dart` のパス定義漏れ |
| State 管理 | 画面がずっとローディングのまま | `isLoading: false` の設定漏れ |

#### 実行内容
1. エラー種別を自動判定
2. スタックトレースからファイルパスと行番号を特定
3. 該当コードを確認して原因を日本語で説明
4. 修正を実施
5. 同様のバグが他の箇所に潜んでいないか検索
6. `melos run analyze` で静的解析を確認

#### こんな時に使う
- エラーが出たが原因が分からないとき
- スタックトレースを見ても該当箇所が特定できないとき
- 修正後に類似バグが他にないか確認したいとき

---

### `/add-viewmodel-test` — ViewModel テスト追加

#### 概要
指定した ViewModel の未テストメソッドを特定し、このプロジェクトの既存テストパターン（Mockito + ProviderContainer）に従ってユニットテストを追加します。

#### 使い方
```
/add-viewmodel-test booking
/add-viewmodel-test favorite
/add-viewmodel-test plan_list
/add-viewmodel-test plan_detail
```

#### 既存テストファイルとの対応

| 引数 | 対象 ViewModel | 既存テストファイル |
|---|---|---|
| `plan_list` | `PlanListViewModel` | あり（拡充） |
| `plan_detail` | `PlanDetailViewModel` | あり（拡充） |
| `booking` | `BookingViewModel` | あり（拡充） |
| `favorite` | `FavoriteViewModel` | あり（拡充） |
| 新規機能名 | 新規 ViewModel | なし（新規作成） |

#### テストのカバー範囲（自動で特定）
- 初期状態のデフォルト値
- 成功パス（データ取得 → state 更新）
- 失敗パス（例外 → error セット、isLoading: false）
- 各 `updateXxx()` メソッドの入力検証
- `reset()` / `clearError()` の動作
- エッジケース（空リスト、null、ページネーション境界）

#### 実行後の自動手順
1. `melos run build_runner` でモッククラス（`.mocks.dart`）を再生成
2. `melos run test` でテスト実行・確認

#### こんな時に使う
- 新しいメソッドを ViewModel に追加したとき
- バグ修正後にリグレッションテストを書きたいとき
- テストカバレッジを上げたいとき
- `/add-feature` で新機能を作成した後

---

### `/state-audit` — 状態管理監査

#### 概要
指定した ViewModel の状態管理コードを 5 つの観点から監査し、問題箇所を重大度付きで報告します。

#### 使い方
```
/state-audit booking
/state-audit favorite
/state-audit plan_list
/state-audit plan_detail
```

#### チェック観点

| 観点 | 確認内容 |
|---|---|
| 三態管理 | loading/error/success の各パスで isLoading と error が正しくセットされているか |
| 二重実行防止 | `if (state.isLoading) return;` などのガードがあるか |
| リソースリーク | StreamSubscription・GraphQLHttpClient が `ref.onDispose` で解放されているか |
| copyWith の一貫性 | `clearError: true` フラグが一貫して使われているか |
| Provider 配置 | `ref.watch` と `ref.read` の使い分けが正しいか |

#### 出力例
```
【高】BookingViewModel.submitBooking でエラー時に isLoading が false にならない
  - 箇所: booking_viewmodel.dart:89
  - 内容: catch ブロックで isSubmitting: false の copyWith が呼ばれていない
  - 修正案: state = state.copyWith(isSubmitting: false, error: e.toString());

【中】FavoriteViewModel._subscription が onDispose で cancel されていない
  - 箇所: favorite_viewmodel.dart:23
  - 内容: ref.onDispose コールバック内で _subscription?.cancel() が抜けている
  - 修正案: ref.onDispose(() { _subscription?.cancel(); });

✗ 問題が 2 件見つかりました（高: 1、中: 1、低: 0）
```

#### こんな時に使う
- 予期しない状態の不整合が起きているとき
- ViewModel を新規作成・大幅修正したとき
- メモリリークが疑われるとき
- コードレビューの前に自己チェックとして

---

## 6. シナリオ別推奨フロー

### 開発開始時（毎朝）
```
1. /backend-up          # バックエンドを起動
```

---

### 新機能を追加するとき

```
1. /add-feature hotel_search            # 雛形ファイルを生成
2. （各ファイルの TODO を実装）
3. /schema-update ホテル検索用のフィールドを TravelPlan に追加  # DB〜Dart まで反映
4. /flutter-gen                         # .g.dart を再生成
5. /add-viewmodel-test hotel_search     # テストを追加
6. /graphql-check                       # 整合性を確認
```

---

### バグが発生したとき

```
1. /bug-trace <エラーメッセージをそのまま貼る>
   └─ 原因特定 → 修正 → 静的解析まで自動実行
2. /add-viewmodel-test <対象ViewModel名>  # リグレッションテストを追加
```

---

### バックエンドのスキーマを変更するとき

```
1. /schema-update <変更内容を日本語で記述>
   └─ Step 1〜8 を順番に実施
2. /graphql-check                        # 変更後の整合性を確認
3. /flutter-gen                          # コード再生成（schema-update 内で実施済みだが念のため）
```

---

### コードレビュー前の品質チェック

```
1. /state-audit <変更した画面名>          # 状態管理の問題を確認
2. /graphql-check                        # GraphQL の整合性を確認
3. /add-viewmodel-test <変更したViewModel名>  # テストカバレッジを確認
```

---

### PC の IP が変わったとき（実機テスト時など）

```
1. /fix-endpoint                         # 現在の設定と選択肢を確認
   または
   /fix-endpoint 192.168.x.x            # 直接 IP を変更
2. /backend-up                           # バックエンドが起動しているか確認
```

---

### テスト環境を初期化したいとき

```
1. /backend-up                           # Docker が起動していることを確認
2. /db-reset                             # DB をリセットしてシードを再投入
```

---

## 補足: スキルファイルの場所

```
.claude/commands/
├── add-feature.md         → /add-feature
├── add-viewmodel-test.md  → /add-viewmodel-test
├── backend-up.md          → /backend-up
├── bug-trace.md           → /bug-trace
├── db-reset.md            → /db-reset
├── fix-endpoint.md        → /fix-endpoint
├── flutter-gen.md         → /flutter-gen
├── graphql-check.md       → /graphql-check
├── schema-update.md       → /schema-update
└── state-audit.md         → /state-audit
```

スキルの内容を変更したい場合は、対応する `.md` ファイルをテキストエディタで直接編集してください。
