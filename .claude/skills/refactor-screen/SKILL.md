---
name: refactor-screen
description: |
  既存の Screen を構造的にリファクタする。
  add-feature（新規作成）とは異なり、既存コードを読んで分割・再構成する。
  以下の発言で自動起動すること：
  - 「画面をリファクタしたい」
  - 「画面を分割したい」
  - 「ウィザード形式に変えたい」
  - 「ステップUIに変更したい」
  - 「画面のコンポーネントを分離したい」
  - 「1画面に詰め込みすぎているので整理したい」
argument-hint: "<ScreenName> [--wizard] [--extract-widgets] [--split <数>]"
allowed-tools:
  - Read
  - Edit
  - Bash
disable-model-invocation: false
---

# refactor-screen — 既存 Screen 構造リファクタ

対象: `$ARGUMENTS`

> **add-feature との使い分け**
> - 新しい画面・機能を追加する → `/add-feature`
> - 既存画面の構造を変更・整理する → `/refactor-screen`（このスキル）

リファクタパターンの詳細: `references/refactor-patterns.md` を参照。

## 引数

| 引数 | 説明 |
|---|---|
| `<ScreenName>` | 対象 Screen のクラス名（例: `BookingScreen`） |
| `--wizard` | ステップウィザード形式に変換する |
| `--extract-widgets` | build() 内のセクションを個別ウィジェットとして抽出する |
| `--split <数>` | 指定した数の子ウィジェットに分割する |

---

## Step 1: 現状分析（必須・ユーザー確認あり）

引数からスクリーン名を解釈し、以下のファイルをすべて Read する。

```
lib/presentation/screens/<name>/<name>_screen.dart
lib/presentation/viewmodels/<name>_viewmodel.dart
lib/presentation/viewmodels/<name>_viewmodel.g.dart
```

スクリーン内の import を確認し、参照している共通ウィジェットも Read する：
```
lib/presentation/widgets/（import されているもの）
lib/core/error/app_error.dart
```

関連テストを確認する：
```bash
find travel_booking_mobile/test -name "*<name>*" -type f
```

### Read 後に日本語で報告し「この方針で進めてよいですか？」と確認を取る

報告する内容：

**現状の構造:**
- build() メソッドの行数
- `_build*` プライベートメソッドの一覧と行数
- ViewModel の State フィールド一覧
- 子ウィジェットとして抽出可能なセクションの候補

**提案するリファクタ方針:**
- `--wizard` の場合: ステップ分割の候補（何ステップに分けるか、各ステップの責務）
- `--extract-widgets` の場合: 抽出するウィジェット名と対応するメソッドの一覧
- `--split <数>` の場合: 分割境界の候補

**影響範囲:**
- 変更するファイルの一覧
- 既存テストへの影響（壊れる可能性があるもの）

ユーザーが「進めてください」「はい」などの確認をするまでファイルを変更しない。

---

## Step 2: リファクタ実行

`references/refactor-patterns.md` を Read してから方針に沿って実装する。

### --wizard の場合

**a. ViewModel に currentStep を追加する**

`<Name>FormState`（または対応する State クラス）に以下のフィールドを追加：
```dart
final int currentStep;   // 0 始まり
final int totalSteps;    // 固定値（定数でも可）
```

`copyWith` にも追加し、ステップ操作メソッドを ViewModel に実装：
```dart
void nextStep() { ... }
void previousStep() { ... }
bool validateCurrentStep() { ... }  // ステップ固有バリデーション
```

**b. 各ステップを StatelessWidget として抽出する**

配置先: `lib/presentation/screens/<name>/steps/<step_name>_step.dart`

各ステップは `ConsumerWidget` または `StatelessWidget` として実装し、
必要なデータ・コールバックをコンストラクタ引数で受け取る。

**c. メイン Screen をステップコントローラーに変更する**

`PageView.builder` または `IndexedStack` でステップを切り替える。
```dart
PageView.builder(
  controller: _pageController,
  physics: const NeverScrollableScrollPhysics(), // 手動スワイプ無効
  itemCount: state.totalSteps,
  itemBuilder: (context, index) => _buildStep(index, state),
)
```

**d. ステップインジケーターを追加する**

`_StepIndicator` ウィジェット（プライベートまたは steps/ 配下）として実装。
パターン: `references/refactor-patterns.md` の「ステップインジケーター」を参照。

**e. 「次へ」「戻る」ナビゲーションを AppBar または bottom に追加する**

パターン: `references/refactor-patterns.md` の「ウィザードナビゲーション」を参照。

### --extract-widgets の場合

**a. 抽出対象の特定**

`build()` 内の `_build*` メソッドを確認し、再利用可能・独立したセクションを選ぶ。
目安: 50行以上のメソッド、または複数の Screen から参照される可能性があるもの。

**b. 個別ウィジェットとして抽出する**

配置先を判断する：
- このスクリーン固有 → `lib/presentation/screens/<name>/widgets/<widget_name>.dart`
- 複数スクリーンで再利用可能 → `lib/presentation/widgets/<widget_name>.dart`

パターン: `references/refactor-patterns.md` の「ウィジェット抽出」を参照。

**c. メイン Screen を書き換える**

`_buildXxx()` 呼び出しを抽出したウィジェットのインスタンスに置き換える。

### --split <数> の場合

**a. 分割境界の決定**

UIの論理セクション単位（フォームグループ、カード、リストセクション）で
指定された数になるよう分割境界を決定する。

**b. 親子ウィジェット構成に変換する**

パターン: `references/refactor-patterns.md` の「分割パターン」を参照。

---

## Step 3: ViewModel の更新

Step 2 でコード変更を行った後、ViewModel の変更が必要かを確認する：

- wizard: `currentStep` / `totalSteps` フィールドと `nextStep` / `previousStep` メソッドを追加
- extract-widgets / split: ViewModel 変更が不要な場合が多い（確認のみ）

エラー型は必ず既存の sealed class を使う：
```dart
import '../../core/error/app_error.dart';
// NetworkError / GraphQLError / ValidationError / UnknownError
```

ViewModel 変更後は必ず再生成する：
```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run build_runner
```

---

## Step 4: テストの更新

既存テストを Read し、リファクタで壊れたものを修正する。

```bash
# 変更前に確認
dart run melos run test

# 修正後に再確認
dart run melos run test
```

新しいウィジェットが生成された場合:
- 「`/add-viewmodel-test <ViewModel名>` でステップ ViewModel のテスト追加を推奨します」と案内
- 抽出したウィジェットが Widget テスト対象になる場合は「`test/widgets/<widget_name>_test.dart` の追加を推奨します」と案内

---

## Step 5: 最終確認

```bash
# 静的解析
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run analyze

# 全テスト
dart run melos run test
```

エラーがあれば修正してから完了とする。

---

## 完了後の案内

完了時に以下を表示する：

```
✅ リファクタが完了しました

変更ファイル:
  （変更したファイルの一覧）

次のステップ（任意）:
  /state-audit <名前>     → 状態管理を確認
  /perf-audit <名前>      → パフォーマンスを確認
  /preview-setup <Screen名> → Widgetbook Preview ケースを追加

使い分けメモ:
  新しい画面・機能を追加 → /add-feature
  既存画面を構造変更・整理 → /refactor-screen（このスキル）
```

---

## 注意事項

- **Step 1 でユーザー確認を必ず取ること**（確認前にファイルを変更しない）
- `lib/core/router/app_router.dart` のルートは変更しない
  ルート追加が必要な場合は「`/add-route` で別途追加してください」と案内する
- `.g.dart` ファイルは直接編集しない（`build_runner` で再生成する）
- 既存の命名規約・インデントスタイルを維持する（`dart format` 準拠）
- `ConsumerStatefulWidget` / `ConsumerWidget` の使い分けは元のコードに従う
