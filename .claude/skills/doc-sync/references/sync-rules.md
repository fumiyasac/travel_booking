# doc-sync 同期ルール

このファイルは `doc-sync` スキルが参照するドキュメントとソースコードのマッピング定義です。

---

## 信頼できる情報源（Source of Truth）

| ドキュメント対象 | 信頼できる情報源 |
|---|---|
| スキル一覧（件数・名前・概要） | `.claude/skills/` ディレクトリ一覧 + 各 `SKILL.md` の `name` / `description` |
| ルーティング構成 | `travel_booking_mobile/lib/core/router/app_router.dart` |
| Screen 一覧 | `travel_booking_mobile/lib/presentation/screens/` 配下のディレクトリ |
| ViewModel 一覧 | `travel_booking_mobile/lib/presentation/viewmodels/` の `*_viewmodel.dart`（`.g.dart` 除外） |
| Provider 一覧 | `travel_booking_mobile/lib/presentation/viewmodels/plan_list_viewmodel.dart` の `@riverpod` / `@Riverpod(keepAlive: true)` アノテーション |
| Repository 一覧 | `travel_booking_mobile/lib/data/repositories/` の `*.dart`（`*_impl.dart` 除外） |
| テストファイル一覧 | `travel_booking_mobile/test/` の `*_test.dart`（`widget_test.dart` 除外） |
| シードデータ一覧 | `travel_booking_backend/prisma/seed.ts` |

---

## 差分タイプ定義

### SKILL_COUNT
- **検出条件**: `find .claude/skills -mindepth 1 -maxdepth 1 -type d | wc -l` の値 ≠ `grep -cE '\| [✓—] \|$' skill_guidance.md` の値
- **修正対象**: `skill_guidance.md` のスキルテーブル行数
- **判定**: `.claude/skills/` ディレクトリ数が正

### SKILL_MISSING
- **検出条件**: `.claude/skills/<name>/` が存在するが `skill_guidance.md` のテーブルに `| \`<name>\` |` 行がない
- **修正対象**: `skill_guidance.md` テーブルに行を追加 + 詳細セクション (`###`) を追加 + `CLAUDE.md` テーブルに行を追加
- **行フォーマット** (`skill_guidance.md`):
  ```
  | `<name>` | `/<name> <arg-hint>` または自然文 | <description 1行目> | ✓ または — |
  ```
- **行フォーマット** (`CLAUDE.md`):
  ```
  | `<name>` | `/<name>` または自然文 | <概要1行> | ✓ または — |
  ```

### SKILL_DETAIL
- **検出条件**: `skill_guidance.md` に `### <name>` 見出しがない、または概要・引数が SKILL.md と乖離している
- **修正対象**: `skill_guidance.md` の対応 `###` セクション

### ROUTE_OUTDATED
- **検出条件**: `app_router.dart` の GoRoute path 集合 ≠ ドキュメントの mermaid ノード集合
- **修正対象**: `README.md` の「ルーティング（GoRouter）」セクション + `architecture_guidance.md` Section 2-7
- **ノード命名規則**:
  - BottomNav タブ内: 短い識別子（`Home`, `Fav`, `Hist`, `BK`, `Conf` など）
  - Shell 外トップレベル: 末尾に `※ Shell 外のトップレベルルート` を注記
  - 同じ Screen を複数ルートから使う場合（`PlanDetailScreen`）は別ノードで表現可

### SCREEN_MISSING
- **検出条件**: `lib/presentation/screens/<name>/` ディレクトリが存在するが Screen 一覧テーブルに未記載
- **修正対象**: `README.md` のアーキテクチャセクション (screens/ コメント行) + `architecture_guidance.md` Section 2-2・2-4
- **Screen 一覧テーブル列**: `Screen 名` / `ルート` / `Widget 種別`

### TEST_MISSING
- **検出条件**: `test/` に `*_test.dart` が存在するが テスト一覧テーブルに未記載
- **修正対象**: `README.md` のテスト一覧テーブル + `architecture_guidance.md` Section 5
- **テスト一覧テーブル列**: ファイル名 (backtick) / テストケース概要（カンマ区切り）

### PROVIDER_OUTDATED
- **検出条件**: `plan_list_viewmodel.dart` の Provider 定義が `architecture_guidance.md` Section 2-6 テーブルと不一致
- **修正対象**: `architecture_guidance.md` Section 2-6（Provider 一覧テーブル + 依存関係グラフ）
- **keepAlive 判定**: `@Riverpod(keepAlive: true)` → ✓、`@riverpod` → —

### SEED_OUTDATED
- **検出条件**: `seed.ts` に定義されているプラン件数・タイトルが `README.md` のシードデータ一覧と不一致
- **修正対象**: `README.md` のシードデータ一覧テーブル

---

## ドキュメントとソースの対応マップ

```
ソースコード                          → ドキュメント
─────────────────────────────────────────────────────────────────
.claude/skills/<name>/SKILL.md        → skill_guidance.md テーブル + ### セクション
                                      → CLAUDE.md スキルテーブル
app_router.dart GoRoute               → README.md ### ルーティング mermaid
                                      → architecture_guidance.md Section 2-7 mermaid
lib/presentation/screens/<name>/      → README.md screens/ コメント行
                                      → architecture_guidance.md Section 2-2 ツリー
                                      → architecture_guidance.md Section 2-4 Screen一覧
lib/presentation/viewmodels/*_vm.dart → architecture_guidance.md Section 2-2 ツリー
                                      → architecture_guidance.md Section 2-4 ViewModel一覧
plan_list_viewmodel.dart @riverpod    → architecture_guidance.md Section 2-6 Provider一覧
                                      → architecture_guidance.md Section 2-6 依存関係グラフ
lib/data/repositories/*.dart          → architecture_guidance.md Section 2-3 Repository一覧
test/*_test.dart                      → README.md テスト一覧テーブル
                                      → architecture_guidance.md Section 5 テストツリー
prisma/seed.ts                        → README.md シードデータ一覧テーブル
```

---

## 修正ルール

### mermaid の書き方

- **色指定なし原則**: `fill:` / `stroke:` / `color:` は追加しない（ダークモード互換）
- **既存の `style` 行**: 元から存在する場合のみ維持する
- **ノード数上限**: 1図あたり 20 ノード以内を目安にする
- **Shell 外ルート**: `※ Shell 外のトップレベルルート` のコメントを末尾に付ける

### スキルテーブルの行順

既存行の末尾に追記する（アルファベット順のソートは不要）。

### テスト一覧テーブルの行順

テストファイル名のアルファベット順。

### Screen 一覧の行順

ルートのアルファベット順（`/` → `/booking` → `/favorites` → ... の順）。
