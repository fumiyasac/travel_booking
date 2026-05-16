# 状態管理監査チェックリスト

## 観点 1: 三態管理（loading / error / success）

### 非同期メソッドの基本パターン

```dart
// ✓ 正しいパターン
Future<void> loadItems() async {
  if (state.isLoading) return;                          // 二重実行防止
  state = state.copyWith(isLoading: true, clearError: true);  // 開始時

  try {
    final data = await repo.getItems();
    state = state.copyWith(items: data, isLoading: false);    // 成功時
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString()); // 失敗時
  }
}

// ✗ よくあるミス: catch で isLoading: false を忘れる
Future<void> loadItems() async {
  state = state.copyWith(isLoading: true);
  try {
    final data = await repo.getItems();
    state = state.copyWith(items: data, isLoading: false);
  } catch (e) {
    state = state.copyWith(error: e.toString()); // isLoading: false が抜けている
  }
}
```

### チェックリスト

- [ ] メソッド開始時に `isLoading: true` または `isSubmitting: true` をセットしているか
- [ ] 成功パスで loading フラグを `false` にセットしているか
- [ ] `catch` ブロックでも loading フラグを `false` にセットしているか（**最重要**）
- [ ] エラー文字列は `e.toString()` または `e.toString().replaceAll('Exception: ', '')`か
- [ ] `clearError: true` を適切なタイミングで渡しているか

---

## 観点 2: 二重実行防止

### パターン別ガード

```dart
// データ読み込み系
Future<void> loadItems() async {
  if (state.isLoading) return;  // ✓
  ...
}

// ページネーション系
Future<void> loadMore() async {
  if (!state.hasNextPage || state.isLoadingMore || state.isLoading) return;  // ✓
  ...
}

// フォーム送信系
Future<bool> submitForm() async {
  if (state.isSubmitting) return false;  // ✓
  ...
}
```

### チェックリスト

- [ ] データ読み込みメソッドに `if (state.isLoading) return;` があるか
- [ ] `loadMore` に `hasNextPage` と `isLoadingMore` の両方チェックがあるか
- [ ] フォーム送信に `isSubmitting` チェックがあるか

---

## 観点 3: リソースリーク

### StreamSubscription のパターン

```dart
@riverpod
class FavoriteViewModel extends _$FavoriteViewModel {
  StreamSubscription<List<FavoritePlan>>? _subscription;

  @override
  FavoriteState build() {
    ref.onDispose(() {
      _subscription?.cancel();  // ✓ 必須
    });
    _startWatching();
    return const FavoriteState(isLoading: true);
  }
}
```

### GraphQLHttpClient のパターン

```dart
@riverpod
GraphQLHttpClient graphQLHttpClient(Ref ref) {
  final client = GraphQLHttpClient();
  ref.onDispose(client.dispose);  // ✓ 必須
  return client;
}
```

### Widget 側のリソース（Screen ファイルで確認）

```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();   // ✓ 必須
    _searchController.dispose();   // ✓ 必須
    super.dispose();
  }
}
```

### チェックリスト

- [ ] `StreamSubscription` フィールドが `ref.onDispose` でキャンセルされているか
- [ ] `GraphQLHttpClient` が `ref.onDispose(client.dispose)` で破棄されているか
- [ ] `Timer` フィールドが `ref.onDispose(() => _timer?.cancel())` でキャンセルされているか
- [ ] Widget 側の `dispose()` で全コントローラーが解放されているか

---

## 観点 4: copyWith の一貫性

### 正しいパターン

```dart
class XxxxxState {
  XxxxxState copyWith({
    List<XxxxxModel>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,      // nullable フィールドのクリアに専用フラグ
    bool clearSelection = false,  // 同様
  }) {
    return XxxxxState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),           // ✓
      selection: clearSelection ? null : (selection ?? this.selection),  // ✓
    );
  }
}
```

### チェックリスト

- [ ] nullable フィールドをクリアする際に専用フラグ（`clearXxx = false`）を使っているか
- [ ] 全メソッドで `clearError: true` の呼び出しパターンが一貫しているか

---

## 観点 5: Provider 配置と ref 使い分け

### 正しい使い分け

```dart
@riverpod
class XxxxxViewModel extends _$XxxxxViewModel {
  @override
  XxxxxState build() {
    // build() 内: ref.watch を使う（再描画トリガー）
    final config = ref.watch(configProvider);
    return const XxxxxState();
  }

  Future<void> loadItems() async {
    // メソッド内: ref.read を使う（読み取りのみ、再描画不要）
    final repo = ref.read(xxxxxRepositoryProvider);
    ...
  }
}
```

### チェックリスト

- [ ] `build()` 内では `ref.watch` を使っているか
- [ ] `Future<void>` メソッド内では `ref.read` を使っているか（`ref.watch` は使わない）
- [ ] Provider の依存関係がループしていないか

---

## 重大度の基準

| 重大度 | 基準 |
|---|---|
| **高** | クラッシュ・無限ローディング・メモリリーク（確実） |
| **中** | 状態不整合・不意のエラー表示・潜在的メモリリーク |
| **低** | コードスタイルの不統一・軽微なパフォーマンス問題 |
