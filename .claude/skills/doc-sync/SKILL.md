---
name: doc-sync
description: |
  ドキュメントの更新漏れを検出・修復するサブエージェントスキル。
  ソースコードとドキュメントの差分を8種類の diff タイプで分類し、
  context: fork で独立実行するため本会話のコンテキストを汚さない。
  以下のような発言で自動起動すること：
  - 「ドキュメントが古い」
  - 「doc を同期して」
  - 「README を最新にして」
  - 「ドキュメント更新漏れを直して」
  - 「アーキテクチャドキュメントを更新して」
argument-hint: "[--check|--fix|--readme|--skills|--arch]"
context: fork
allowed-tools:
  - Read
  - Edit
  - Bash
---

# doc-sync — ドキュメント更新漏れ検出・修復

対象オプション: `$ARGUMENTS`

`context: fork` で独立実行するため本会話のコンテキストを汚しません。
マッピングルール詳細: `references/sync-rules.md` を参照。

---

## オプション

| オプション | 対象 | 動作 |
|---|---|---|
| `--check`（省略時デフォルト） | 全ドキュメント | 差分を検出してレポートのみ（修正なし） |
| `--fix` | 全ドキュメント | 差分を検出して自動修正まで実行 |
| `--readme` | README.md のみ | README の差分を検出・修正 |
| `--skills` | skill_guidance.md + CLAUDE.md のみ | スキル一覧の差分を検出・修正 |
| `--arch` | architecture_guidance.md のみ | アーキテクチャ図の差分を検出・修正 |

---

## Step 1: ソースを読み込む

`references/sync-rules.md` を Read してから、以下を Read する：

### 信頼できる情報源（Source of Truth）

```bash
# スキルディレクトリ
ls .claude/skills/

# ソースコード
find travel_booking_mobile/lib/presentation/screens -mindepth 1 -maxdepth 1 -type d
find travel_booking_mobile/lib/presentation/viewmodels -name '*_viewmodel.dart' ! -name '*.g.dart'
find travel_booking_mobile/lib/data/repositories -name '*.dart' ! -name '*_impl.dart'
find travel_booking_mobile/test -name '*_test.dart' ! -name 'widget_test.dart'
```

合わせて以下のファイルを Read する：
- `travel_booking_mobile/lib/core/router/app_router.dart`
- `travel_booking_mobile/lib/presentation/viewmodels/plan_list_viewmodel.dart`（Provider 定義を含む）

### ドキュメント

- `README.md`
- `skill_guidance.md`
- `CLAUDE.md`
- `architecture_guidance.md`

---

## Step 2: 差分を検出する

`references/sync-rules.md` の「差分タイプ」定義に従い、以下の8種類を検出する。

| 差分タイプ | 検出方法 |
|---|---|
| **SKILL_COUNT** | `.claude/skills/` ディレクトリ数 ≠ `skill_guidance.md` テーブル行数 |
| **SKILL_MISSING** | `.claude/skills/` に存在するが `skill_guidance.md` や `CLAUDE.md` のスキルテーブルにない |
| **SKILL_DETAIL** | `skill_guidance.md` の詳細セクション（`###` 見出し）がスキルディレクトリと不一致 |
| **ROUTE_OUTDATED** | `app_router.dart` の GoRoute 定義が `README.md` / `architecture_guidance.md` のルーティング mermaid と不一致 |
| **SCREEN_MISSING** | `lib/presentation/screens/` のディレクトリが `README.md` / `architecture_guidance.md` の Screen 一覧に未記載 |
| **TEST_MISSING** | `test/` の `*_test.dart` ファイルが `README.md` / `architecture_guidance.md` のテスト一覧に未記載 |
| **PROVIDER_OUTDATED** | `plan_list_viewmodel.dart` の Provider 定義が `architecture_guidance.md` の Provider 一覧と不一致 |
| **SEED_OUTDATED** | `prisma/seed.ts` の変更が `README.md` のシードデータ一覧に未反映（git diff で検出） |

検出結果を以下の形式で表示する：

```
検出された差分:
  [ROUTE_OUTDATED] README.md ルーティング mermaid
    - 追加: RecentlyViewedScreen (/recently-viewed, /recently-viewed/plan/:id)

  [SCREEN_MISSING] architecture_guidance.md Screen 一覧
    - 追加: BookingHistoryScreen, RecentlyViewedScreen

  [PROVIDER_OUTDATED] architecture_guidance.md Provider 一覧
    - 追加: recentlyViewedStorageProvider, recentlyViewedLocalDataSourceProvider,
            recentlyViewedRepositoryProvider, recentlyViewedViewModelProvider
```

---

## Step 3: 修正方針を確認する

`--check` の場合はここで終了し、検出結果のみを報告する。

`--fix` / `--readme` / `--skills` / `--arch` の場合は、修正内容の一覧をユーザーに提示して確認を取る：

```
以下の修正を行います:
  1. [ROUTE_OUTDATED] README.md ルーティング mermaid に RecentlyViewedScreen を追加
  2. [SCREEN_MISSING] architecture_guidance.md の Screen 一覧を更新
  3. [PROVIDER_OUTDATED] architecture_guidance.md の Provider 一覧を更新

続行してよいですか？
```

---

## Step 4: 修正を適用する

`references/sync-rules.md` の「修正ルール」に従い、差分タイプ別に修正を実施する。

### SKILL_COUNT / SKILL_MISSING / SKILL_DETAIL

`skill_guidance.md` のスキルテーブルと詳細セクションを更新する。
`CLAUDE.md` のスキルテーブルも同様に更新する。

スキルテーブルの行フォーマット（`skill_guidance.md`）：
```
| `スキル名` | 起動方法 | 概要 | 自動起動 |
```

`| ✓ |` または `| — |` で行末を終える（自動起動列）。

### ROUTE_OUTDATED

`app_router.dart` の GoRoute 定義を読み取り、
`README.md` と `architecture_guidance.md` の mermaid ブロックを書き直す。

mermaid ノードの命名規則：
- Shell 内（BottomNav タブ）: Branch名 + ルート (`Home["/\nHomeScreen"]`)
- Shell 外（トップレベル）: `Top["...\n...Screen\n※ Shell 外のトップレベルルート"]` 形式

### SCREEN_MISSING

`lib/presentation/screens/` のディレクトリを基準に：
- `README.md`: Screen 一覧テーブル（Screen 名, ルート, Widget 種別）
- `architecture_guidance.md` Section 2-4: Screen 一覧テーブルと Section 2-2 のディレクトリツリー

### TEST_MISSING

`test/` のテストファイルリストを基準に：
- `README.md`: テスト一覧テーブル（ファイル名, テストケース概要）
- `architecture_guidance.md` Section 5: ディレクトリツリー

### PROVIDER_OUTDATED

`plan_list_viewmodel.dart` の Provider 定義を基準に：
- `architecture_guidance.md` Section 2-6: Provider 一覧テーブル
- `architecture_guidance.md` Section 2-6: Provider 依存関係グラフ（mermaid）

### SEED_OUTDATED

`prisma/seed.ts` を Read してシードデータを確認し、
`README.md` のシードデータ一覧テーブルを更新する。

---

## 完了報告

修正が完了したら以下を実行して全チェックがグリーンであることを確認する：

```bash
bash scripts/check-doc-freshness.sh --debug
```

```
✅ doc-sync 完了

修正内容:
  （差分タイプ別の修正サマリ）

チェック結果:
  ✅ スキル数: N 件
  ✅ Screen 数: N 件
  ✅ テスト数: N 件

次のステップ（任意）:
  git diff --stat  → 変更ファイルを確認
  /flutter-gen     → .g.dart を再生成（Provider 変更時）
```

---

## 注意事項

- `context: fork` のため修正ファイルは本会話に反映されない。確認後に `git diff` でユーザーが差分確認する。
- mermaid ブロックを書き直す際は**色指定（fill: / stroke:）を追加しない**（ダークモード互換性を維持）。
- `architecture_guidance.md` の mermaid は既存の `style` 指定がある場合のみそれを維持する。
- スキルテーブルの行は `grep -cE '\| [✓—] \|$'` でカウント可能な形式を維持する。
