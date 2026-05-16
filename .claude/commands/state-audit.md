ViewModel名または画面名: $ARGUMENTS

指定された ViewModel の状態管理に問題がないか監査してください。

## 調査対象

`travel_booking_mobile/lib/presentation/viewmodels/$ARGUMENTS_viewmodel.dart` を読み込む。
引数が画面名の場合（例: `home`、`booking`）は対応する `_viewmodel.dart` を探して読み込む。

---

## チェック項目

### 1. 三態管理（loading / error / success）の完全性

各非同期メソッドについて確認:
- [ ] メソッド開始時に `isLoading: true` をセットしているか
- [ ] 成功パスで `isLoading: false` + データセットを行っているか
- [ ] エラーパスで `isLoading: false` + `error: e.toString()` をセットしているか（どちらかのパスに漏れがないか）
- [ ] `clearError: true` を使ったエラークリアが適切に呼ばれているか

### 2. 二重実行防止ガード

- [ ] `if (state.isLoading || state.isLoadingMore) return;` などのガードがあるか
- [ ] ページネーション（`loadMore`）で `hasNextPage` チェックがあるか

### 3. リソースリーク

- [ ] `StreamSubscription` は `ref.onDispose(() => subscription?.cancel())` で解放されているか
- [ ] `GraphQLHttpClient` は `ref.onDispose(client.dispose)` で解放されているか
- [ ] Widget 側の `ScrollController` / `TextEditingController` は `dispose()` で解放されているか

### 4. copyWith の一貫性

- [ ] `clearError` などのクリア専用フラグが一貫して使われているか
- [ ] 同じフィールドの更新パターンが他のメソッドと統一されているか

### 5. Provider の配置

- [ ] この ViewModel が依存する Provider（Repository など）が `plan_list_viewmodel.dart` の Provider セクションに定義されているか、または適切なファイルに分離されているか
- [ ] `ref.watch` と `ref.read` の使い分けが正しいか（build/監視に `watch`、メソッド内に `read`）

---

## 報告フォーマット

問題が見つかった場合:
```
【高/中/低】問題タイトル
- 箇所: ファイルパス:行番号
- 内容: 何が問題か
- 修正案: 具体的なコード
```

問題がなければ「✓ 状態管理に問題は見つかりませんでした」と報告する。

問題がある場合は修正も実施する（ユーザーに確認を取ってから）。
