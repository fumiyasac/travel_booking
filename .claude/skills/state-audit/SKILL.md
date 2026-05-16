---
name: state-audit
description: |
  ViewModel の状態管理コードを三態管理・二重実行防止・リソースリーク・
  copyWith 一貫性・Provider 配置の 5 観点で監査し、問題を重大度付きで報告する。
  「状態管理を確認して」「ViewModel のコードレビューをして」
  「isLoading が消えない」「メモリリークが心配」「state が正しく更新されない」
  などのリクエストで使用する。本会話コンテキストを汚さず独立実行する。
argument-hint: "ViewModel名または画面名 (例: booking, home, plan_detail)"
context: fork
allowed-tools:
  - Read
  - Bash
metadata:
  version: "1.0.0"
---

# state-audit — 状態管理監査

ViewModel名: `$ARGUMENTS`

チェックリストの詳細: `references/checklist.md` を参照。

## 実行手順

### 1. 対象ファイルの読み込み

```
Read: travel_booking_mobile/lib/presentation/viewmodels/{arguments}_viewmodel.dart
```

画面名が指定された場合（例: `home`、`booking`）は対応する ViewModel を探す：
```bash
find /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_mobile/lib/presentation/viewmodels \
  -name "*{arguments}*_viewmodel.dart"
```

関連する Screen も確認する（Widget 側のリソース管理のため）：
```
Read: travel_booking_mobile/lib/presentation/screens/{arguments}/{arguments}_screen.dart
```

### 2. チェック項目の確認

`references/checklist.md` の全チェック項目に従って監査する。

---

**観点 1: 三態管理（loading / error / success）**

各 `Future<void>` メソッドについて確認：
- メソッド開始時に `isLoading: true` をセットしているか
- 成功パスで `isLoading: false` + データセットを行っているか
- エラーパスで `isLoading: false` + `error: e.toString()` をセットしているか
- `clearError: true` を使ったクリアが適切か

---

**観点 2: 二重実行防止**

- `if (state.isLoading) return;` または `if (state.isSubmitting) return;` のガードがあるか
- ページネーションの `loadMore` で `hasNextPage` と `isLoadingMore` をチェックしているか

---

**観点 3: リソースリーク**

- `StreamSubscription` が `ref.onDispose(() => _subscription?.cancel())` で解放されているか
- `GraphQLHttpClient` が `ref.onDispose(client.dispose)` で解放されているか
- Widget 側の `ScrollController` / `TextEditingController` が `dispose()` で解放されているか

---

**観点 4: copyWith の一貫性**

- `clearError` などのクリア専用フラグが一貫して使われているか
- 同じフィールドの更新パターンが他のメソッドと統一されているか

---

**観点 5: Provider 配置と ref 使い分け**

- `build()` 内の監視は `ref.watch` を使っているか
- メソッド内のアクセスは `ref.read` を使っているか
- Provider が適切なスコープに定義されているか

---

### 3. 問題の報告

以下のフォーマットで報告する：

```
【高】{問題タイトル}
  箇所: {ファイルパス}:{行番号}
  内容: {何が問題か}
  修正案:
  ```dart
  // 修正後のコード
  ```

【中】{問題タイトル}
  ...
```

問題がなければ「✓ 状態管理に問題は見つかりませんでした」と報告する。

問題があった場合、ユーザーに確認を取ってから修正を実施する（`context: fork` のため本会話への反映はユーザー操作が必要）。
