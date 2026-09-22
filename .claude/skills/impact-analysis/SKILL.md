---
name: impact-analysis
description: |
  指定したファイルやクラスを変更した場合の影響範囲を事前に分析する。
  リファクタや DI 変更の前に実行して「何が壊れうるか」を把握するために使う。
  以下の発言で自動起動すること：
  - 「この変更の影響範囲を教えて」
  - 「リファクタの影響を分析して」
  - 「何が壊れるか事前に確認したい」
  - 「GraphQLHttpClient を変えたら何に影響する？」
  - 「影響範囲を調べて」
argument-hint: "<ファイルパスまたはクラス名>"
allowed-tools:
  - Read
  - Bash
context: fork
disable-model-invocation: false
---

# impact-analysis — 変更前影響範囲分析

対象: `$ARGUMENTS`

`context: fork` で独立実行するため本会話のコンテキストを汚しません。
チェックリスト詳細: `references/analysis-checklist.md` を参照。

---

## 引数

- `$ARGUMENTS` = ファイルパス（例: `lib/core/config/graphql_config.dart`）
  またはクラス名（例: `GraphQLHttpClient`）

---

## Step 1: 対象を特定する

`references/analysis-checklist.md` を Read してから開始する。

引数がクラス名の場合は `grep -rl` で該当ファイルを特定する：

```bash
grep -rl "$ARGUMENTS" \
  travel_booking_mobile/lib/ \
  travel_booking_backend/src/ \
  2>/dev/null | grep -E '\.(dart|ts)$' | head -5
```

ファイルパスの場合はそのまま使う。
対象ファイルを Read してクラス定義・エクスポートを把握する。

---

## Step 2: 依存ファイルを分析する（import 追跡）

対象ファイルの import パスを特定し、それを import している全ファイルを検索する。

### Flutter（Dart）の場合

```bash
# lib/ 内でインポートしているファイルを検索
grep -rl "import.*$ARGUMENTS" \
  travel_booking_mobile/lib/ \
  travel_booking_mobile/test/ \
  2>/dev/null | head -20
```

さらに、見つかったファイルを import しているファイルも再帰的に検索する
（最大2階層まで。それ以上はリストのみ表示）。

### TypeScript（バックエンド）の場合

```bash
grep -rl "from.*['\"].*$ARGUMENTS['\"]" \
  travel_booking_backend/src/ \
  travel_booking_backend/__tests__/ \
  2>/dev/null | head -20
```

結果を以下のカテゴリに分類する：

| カテゴリ | ディレクトリ |
|---|---|
| Screen | `lib/presentation/screens/` |
| ViewModel | `lib/presentation/viewmodels/` |
| Repository | `lib/data/repositories/` |
| DataSource | `lib/data/datasources/` |
| Widget | `lib/presentation/widgets/` |
| Core | `lib/core/` |
| Preview | `lib/preview/` |
| Resolver テスト | `src/__tests__/` |

---

## Step 3: テスト影響を分析する

`test/` 配下で対象ファイルを直接・間接的に参照しているテストを検索する：

```bash
grep -rl "$ARGUMENTS" \
  travel_booking_mobile/test/ \
  2>/dev/null | head -20
```

見つかったテストファイルごとに、対象をどう使っているかを分類する：

| 種別 | 判定基準 |
|---|---|
| **mock 更新が必要** | `@GenerateMocks([対象クラス])` または `when(mock...)` で直接参照 |
| **テストデータ更新が必要** | `fromJson` / コンストラクタ呼び出しで対象モデルを使っている |
| **影響なし** | 対象を import しているが mock 経由でのみ利用 |

---

## Step 4: ドキュメント影響を分析する

以下のファイルで対象のクラス名・ファイル名に言及している箇所を検索する：

```bash
grep -n "$ARGUMENTS" \
  README.md \
  skill_guidance.md \
  architecture_guidance.md \
  2>/dev/null
```

見つかった行番号と該当セクション名を報告する。

---

## Step 5: スキル影響を分析する

`.claude/skills/` 配下の `references/` ディレクトリで対象ファイル名・クラス名に言及しているファイルを検索する：

```bash
grep -rl "$ARGUMENTS" .claude/skills/ 2>/dev/null
```

見つかったスキルの SKILL.md を Read してテンプレートコードに影響があるか判定する。

---

## Step 6: 影響レポートを出力する

以下のテキスト構造でレポートを出力する：

```
影響分析レポート: <対象クラス名>
━━━━━━━━━━━━━━━━━━━━━━━━
対象: <ファイルパス>

【依存ファイル】 N件
  直接依存（import している）:
    - <ファイルパス> (<カテゴリ>)
    - <ファイルパス> (<カテゴリ>)
    ...
  間接依存（依存ファイルをさらに import）:
    - <ファイルパス> (<カテゴリ>)
    ...

【影響テスト】 N件
  mock 更新が必要:
    - <テストファイルパス> — 理由: <mock のクラスが変わるため>
    ...
  影響なし:
    - <テストファイルパス> — 理由: <対象を直接使っていない>
    ...

【ドキュメント更新】 N箇所
  - <ドキュメント名>: <セクション名> (行N) — <言及内容>
  ...

【スキル更新】 N件
  - <スキル名>: <references/ファイル名> — <言及内容>
  ...

【推奨アクション】
  1. <最初にやるべきこと>
  2. <次にやること>
  3. /test-fix で一括テスト修復
  4. /doc-sync --fix でドキュメント同期
```

---

## 注意事項

- **分析のみ。コードの変更は一切しない**（Read + Bash のみ使用）。
- `grep` の結果が大量の場合は上位 20 件に絞り「他 N 件」と表示する。
- 推奨アクションには `/test-fix` と `/doc-sync` への誘導を必ず含める。
- バックエンド（TypeScript）のファイルが対象の場合も同じ手順で分析する
  （grep パターンを TypeScript の import 構文に変えるだけ）。
- 間接依存の追跡は最大2階層まで。それ以上はファイルリストのみ表示して
  「さらに N 件の間接依存があります（詳細は省略）」と添える。
