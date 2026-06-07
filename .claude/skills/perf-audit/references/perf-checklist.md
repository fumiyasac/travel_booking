# パフォーマンス監査チェックリスト

このプロジェクトの実際のコードから抽出した Bad / Good ペアと確認基準。

---

## 観点1: keepAlive / autoDispose の設計

### StreamSubscription を持つ Provider

```dart
// ✗ Bad: StreamController を持つのに autoDispose（デフォルト）のまま
//   画面遷移のたびにストリームが再接続され、古い購読が残る可能性
@riverpod
FavoriteLocalDataSource favoriteLocalDataSource(Ref ref) {
  final ds = FavoriteLocalDataSource(ref.watch(favoritesStorageProvider));
  // ref.onDispose(ds.dispose) が抜けている
  return ds;
}

// ✓ Good: keepAlive: true + ref.onDispose でライフサイクルを明示
@Riverpod(keepAlive: true)
FavoriteLocalDataSource favoriteLocalDataSource(Ref ref) {
  final ds = FavoriteLocalDataSource(ref.watch(favoritesStorageProvider));
  ref.onDispose(ds.dispose);  // ストリームの破棄を保証
  return ds;
}
```

### カード単位の短命 Stream（planIsFavorite パターン）

このプロジェクトの `planIsFavorite` は `@riverpod`（autoDispose）で正しい。
ただし `ListView` に多数カードがある場合、スクロールによる再生成コストに注意:

```dart
// 現状（plan_list_viewmodel.dart:54）
// autoDispose: カード単位で必要な間だけ生存すれば十分
@riverpod
Stream<bool> planIsFavorite(Ref ref, String planId) {
  final dataSource = ref.watch(favoriteLocalDataSourceProvider);
  return dataSource
      .watchFavorites()
      .map((favorites) => favorites.any((f) => f.planId == planId));
}
// → ⚠️ warning: ListView でカードが再描画されるたびに Stream が再接続される
//   改善案: keepAlive: true にするか、上位で favorites リストを1本 watch して
//           カードには bool を引数で渡す設計に変更する
```

### チェックリスト

- [ ] `StreamController` / `StreamSubscription` を持つ Provider に `keepAlive: true` があるか
- [ ] `keepAlive: true` の Provider に `ref.onDispose` によるリソース解放があるか
- [ ] アプリ全体で共有するストレージ・リポジトリに `keepAlive: true` があるか
- [ ] 画面スコープ（1回のデータ取得）の Provider は `@riverpod`（autoDispose）か

---

## 観点2: 不要な rebuild の検出

### ref.watch でState 全体を監視するパターン

```dart
// ✗ Bad: State 全体を watch → isLoadingMore が変わるだけで画面全体が再ビルド
//   （home_screen.dart:47 の現状）
@override
Widget build(BuildContext context) {
  final state = ref.watch(planListViewModelProvider);  // 全 State を監視
  // state.plans だけ使っている Widget も isLoading 変化で再ビルドされる
  ...
}

// ✓ Good: select() で必要なフィールドのみ監視
@override
Widget build(BuildContext context) {
  final plans   = ref.watch(planListViewModelProvider.select((s) => s.plans));
  final isLoading = ref.watch(planListViewModelProvider.select((s) => s.isLoading));
  final error   = ref.watch(planListViewModelProvider.select((s) => s.error));
  ...
}

// ✓ Best: Consumer で rebuild 範囲を Widget 単位に分割
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer(
      builder: (context, ref, _) {
        final plans = ref.watch(planListViewModelProvider.select((s) => s.plans));
        return ListView.builder(...);
      },
    ),
  );
}
```

### const 化できるサブウィジェット

```dart
// ✗ Bad: build() ごとに新しいインスタンスが生成される
AppBar(
  title: Text('旅行プラン'),  // const にできる
)

// ✓ Good
AppBar(
  title: const Text('旅行プラン'),
)
```

### チェックリスト

- [ ] `ref.watch(xxxProvider)` で State 全体を watch している箇所で、実際に使うフィールドが1〜2個なら `.select()` に変えられないか
- [ ] ページネーション中（`isLoadingMore` 変化）に画面全体が再ビルドされていないか
- [ ] リスト内の各カード Widget が `const` コンストラクタを持っているか
- [ ] `build()` 内で生成しているサブウィジェットのうち `const` にできるものはないか

---

## 観点3: GraphQL クエリの効率

### リスト画面での過剰取得

```
// ✗ Bad: _getPlansQuery（travel_plan_remote_datasource.dart:12）で
//   リスト表示に不要なフィールドを取得している疑いがある箇所

images { id url caption isPrimary displayOrder }
highlights { id text }

// → ⚠️ warning: リスト画面では primaryImageUrl だけ必要なのに
//   全画像（複数枚）と全ハイライトを取得している
//   20件 × (画像N枚 + ハイライト3〜5件) = 大量のデータ転送

// ✓ Good: リスト用クエリでは最小限に絞る
images(where: { isPrimary: true }) { url }  // サーバー側フィルタが使えれば理想
// または: クライアント側で primaryImage のみ使うよう制限する
```

### ハードコードのスクロール閾値

```dart
// ✗ Bad: home_screen.dart:39
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 300) {  // 300px 固定
    ref.read(planListViewModelProvider.notifier).loadMore();
  }
}
// → ⚠️ warning: 300px はカードの高さに依存する。
//   スクロールイベントごとに毎回呼ばれるが loadMore() 内部のガードで防いでいる。
//   改善案: 閾値を画面高の割合（例: viewportDimension * 0.5）にする

// ✓ Good
void _onScroll() {
  final threshold = _scrollController.position.viewportDimension * 0.5;
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - threshold) {
    ref.read(planListViewModelProvider.notifier).loadMore();
  }
}
```

### チェックリスト

- [ ] `_getPlansQuery` でリスト表示に不要な `itinerary` / `includedItems` / `excludedItems` / `reviews` を取得していないか
- [ ] `_getPlansQuery` の `images` がプライマリ画像に絞れているか（全件取得になっていないか）
- [ ] スクロール loadMore のトリガー閾値がハードコードの px 値になっていないか
- [ ] `_onScroll` が高頻度で呼ばれても `loadMore()` 内部のガード（`isLoadingMore` チェック）で多重発火を防いでいるか

---

## 観点4: リソースリークの可能性

### ScrollController / TextEditingController の解放

```dart
// ✓ Good（home_screen.dart:32 現状の正しいパターン）
@override
void dispose() {
  _scrollController.dispose();   // ✓
  _searchController.dispose();   // ✓
  super.dispose();
}

// ✗ Bad: dispose() でコントローラーを解放し忘れ
@override
void dispose() {
  // _scrollController.dispose() が抜けている → リーク
  super.dispose();
}
```

### GraphQLHttpClient の解放

```dart
// ✓ Good（plan_list_viewmodel.dart:25 現状の正しいパターン）
@riverpod
GraphQLHttpClient graphQLHttpClient(Ref ref) {
  final client = GraphQLHttpClient();
  ref.onDispose(client.dispose);  // ✓ autoDispose 時に確実に解放
  return client;
}

// ✗ Bad: ref.onDispose なし
@riverpod
GraphQLHttpClient graphQLHttpClient(Ref ref) {
  return GraphQLHttpClient();  // dispose されない
}
```

### AnimationController のリーク（追加機能実装時の注意）

```dart
// ✗ Bad: AnimationController を dispose() で解放しない
class _MyScreenState extends ConsumerState<MyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: ...);
  }
  // dispose() で _controller.dispose() が抜けている → メモリリーク

  // ✓ Good
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### チェックリスト

- [ ] `ConsumerStatefulWidget` の `dispose()` で `ScrollController` を解放しているか
- [ ] `ConsumerStatefulWidget` の `dispose()` で `TextEditingController` を解放しているか
- [ ] `ConsumerStatefulWidget` の `dispose()` で `AnimationController` を解放しているか（使用時）
- [ ] `GraphQLHttpClient` を生成する Provider に `ref.onDispose(client.dispose)` があるか
- [ ] `StreamSubscription` を保持する Provider に `ref.onDispose(() => sub.cancel())` があるか

---

## 重大度の基準

| 重大度 | 基準 | 例 |
|---|---|---|
| **critical** | 確実なメモリリーク・クラッシュリスク | `ScrollController` 未解放・`StreamSubscription` 未キャンセル |
| **warning** | 修正推奨・段階的に悪化する問題 | 全 State watch・リスト画面での過剰 GraphQL 取得・固定 px 閾値 |
| **info** | 改善の余地・将来的なリスク | `const` 化できる Widget・select() 適用可能箇所 |
