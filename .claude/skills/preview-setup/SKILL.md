---
name: preview-setup
description: |
  Widgetbook を使った Flutter Preview 環境の初期化と、
  既存 Screen・Widget への Preview ケース追加を行う。
  widget-gen・add-feature・add-route の後続ステップとして使うことが多い。
  以下の発言で自動起動すること：
  - 「Preview を追加して」
  - 「Widgetbook を設定して」
  - 「ウィジェットをプレビューで確認したい」
  - 「モックデータで画面を確認したい」
  - 「widget-gen したあと Preview ケースを作りたい」
argument-hint: "[--init] [<ScreenName|WidgetName>]"
allowed-tools:
  - Read
  - Edit
  - Bash
disable-model-invocation: false
---

# preview-setup — Widgetbook Preview 環境セットアップ・ケース追加

対象: `$ARGUMENTS`

## 前処理（必須）

実行前に必ず Read する：
- `travel_booking_mobile/pubspec.yaml`
- `travel_booking_mobile/lib/data/repositories/travel_plan_repository.dart`
- `travel_booking_mobile/lib/data/repositories/favorite_repository.dart`
- `travel_booking_mobile/lib/core/config/graphql_config.dart`

## モード判定

`$ARGUMENTS` を確認して動作モードを選択する：

| 条件 | モード |
|---|---|
| `lib/preview/` が存在しない、または `--init` | 初回セットアップモード |
| Screen名 または Widget名 の引数あり | ケース追加モード |
| 引数なし・既に初期化済み | 現在の Preview 構成一覧を表示して案内 |

---

## ━━ 初回セットアップモード（--init） ━━

### Init Step 1: 依存パッケージを確認・追加

`pubspec.yaml` の `dev_dependencies` に以下があるか確認する：
```yaml
widgetbook: ^3.x
widgetbook_annotation: ^3.x
widgetbook_generator: ^3.x
```

不足している場合のみ追記して `cd travel_booking_mobile && flutter pub get` を実行する。
既に存在する場合はスキップして次のステップへ進む。

### Init Step 2: ディレクトリ構成を生成

`references/preview-structure.md` を Read してから以下のファイルを生成する：

```
lib/preview/
├── main.dart                          # Widgetbook エントリポイント
├── mock_providers.dart                # FakeRepositories + previewProviderOverrides
├── mock_data.dart                     # TravelPlan サンプルデータ定数（10件）
└── components/
    ├── rating_stars_preview.dart
    ├── loading_indicator_preview.dart
    └── app_error_widget_preview.dart
```

**`mock_providers.dart` 実装要件:**
- `FakeInMemoryFavoritesStorage extends FavoritesStorage`: 既存ファイルを維持
- `FakeTravelPlanRepository implements TravelPlanRepository`: 3モードを `bool` フラグで切り替え
  - 正常モード (`isEmpty: false, throwError: false`): `mock_data.dart` の定数10件を返す
  - 空リストモード (`isEmpty: true`): `([], 0, false, 1)` を返す
  - エラーモード (`throwError: true`): `Exception('Preview: データ取得エラー')` を投げる
- `previewProviderOverrides`: `favoritesStorageProvider` + `travelPlanRepositoryProvider` を両方 override

**`mock_data.dart` 実装要件:**
- `_makePlan()` ヘルパーでコンストラクタ直接呼び出し（fromJson 不使用）
- 10件のモックプランを定数で定義（地域・カテゴリ・価格帯を多様に）
- `mockPlans` として `List<TravelPlan>` をまとめた定数も定義する

**`components/` 配下の3ファイル:**
- 各ウィジェットを Read してから代表的な props を網羅した `@widgetbook.UseCase` を実装
- `RatingStars`: 高評価・中評価・大サイズの3ケース
- `LoadingIndicator`: メッセージあり・なしの2ケース
- `AppErrorWidget`: リトライあり・なしの2ケース

### Init Step 3: melos.yaml のスクリプトを確認

`melos.yaml` の `scripts` に `preview` と `preview:web` が既にあるか確認する。
存在しない場合のみ追記する：
```yaml
preview:
  description: Widgetbook プレビューをデフォルトデバイスで起動
  exec: flutter run -t lib/preview/main.dart
  packageFilters:
    dirExists: lib/preview

preview:web:
  description: Widgetbook プレビューを Chrome で起動
  exec: flutter run -t lib/preview/main.dart -d chrome
  packageFilters:
    dirExists: lib/preview
```

### Init Step 4: コード生成と確認

```bash
dart run melos run build_runner
dart analyze travel_booking_mobile/lib/preview/
```

エラーがない場合は以下を案内する：
```
✅ Preview 環境の初期化が完了しました

起動コマンド:
  dart run melos run preview          # デバイスで起動
  dart run melos run "preview:web"    # Chrome で起動

次のステップ:
  /preview-setup <ScreenName>  → 画面の Preview ケースを追加
  /preview-setup <WidgetName>  → ウィジェットの Preview ケースを追加
```

---

## ━━ ケース追加モード（引数あり） ━━

### Add Step 1: 対象ファイルを特定して Read する

`$ARGUMENTS` から以下を判定して対象ファイルを Read する：

| 引数パターン | Read 対象 |
|---|---|
| `*Screen` suffix または `screens/` 配下 | 対象 Screen ファイル + ViewModel ファイル |
| それ以外 | `lib/presentation/widgets/<name>.dart` |

あわせて以下も Read する：
- `lib/preview/mock_providers.dart`
- `lib/preview/mock_data.dart`
- `lib/preview/main.dart`

Screen の場合、ViewModel の Provider 依存チェーンを把握して
どの Provider を override すべきか確認する。

### Add Step 2: Preview ケースファイルを生成する

`references/preview-case-template.md` を Read してから生成する。

**Screen の場合** (`lib/preview/screens/<name>_preview.dart`):

4つのシナリオを `@widgetbook.UseCase` で定義する：

| シナリオ名 | override 内容 |
|---|---|
| 正常表示 | `FakeTravelPlanRepository()` — 10件返す |
| 空リスト | `FakeTravelPlanRepository(isEmpty: true)` |
| ローディング中 | `FakeTravelPlanRepository.loading()` — `Completer` で未解決のまま保持 |
| エラー状態 | `FakeTravelPlanRepository(throwError: true)` |

各ケースは `ProviderScope(overrides: [...])` で Screen をラップする。
`GoRouter` は Preview 用の `_previewRouter`（遷移先なし）を使い、クラッシュしない構成にする。

**Widget の場合** (`lib/preview/components/<name>_preview.dart`):

各 prop の代表値を網羅したケース（最低3つ）を定義する：
- 基本的な表示ケース（必須 prop のみ）
- オプション prop を組み合わせたケース
- エッジケース（空文字・最大値・null 許容フィールド）

### Add Step 3: main.dart に登録する

生成したファイルを `lib/preview/main.dart` に反映する。
Widgetbook は `@widgetbook.App()` アノテーションのファイルを起点に
`build_runner` が自動収集するため、import の追加は**不要**。
ただし、新しいディレクトリ（`screens/`）を追加した場合は
`build_runner` を再実行して `main.directories.g.dart` を更新する。

### Add Step 4: 確認する

```bash
dart run melos run build_runner
dart analyze travel_booking_mobile/lib/preview/
```

エラーがない場合は以下を案内する：
```
✅ Preview ケースを追加しました

起動: dart run melos run preview

推奨フロー:
/add-feature → /add-route → /widget-gen → /preview-setup → /add-viewmodel-test
```
