# MVVM + Repository パターン 実装ガイド

## アーキテクチャ依存関係

```
Screen (ConsumerWidget)
  └─ watches ─→ ViewModel (@riverpod AsyncNotifier)
                  └─ reads ──→ Repository (interface)
                                 └─ delegates → RepositoryImpl
                                                  └─ calls → RemoteDataSource
                                                               └─ calls → GraphQLHttpClient
```

## 各レイヤーの責務

| レイヤー | 責務 | 依存 |
|---|---|---|
| Screen | UI 描画・ユーザーイベント受付 | ViewModel |
| ViewModel | UI 状態管理・ビジネスロジック呼び出し | Repository |
| Repository (I/F) | データアクセスの抽象化 | なし |
| RepositoryImpl | Repository の実装 | DataSource |
| RemoteDataSource | GraphQL 通信 | GraphQLHttpClient |

## 既存ファイルの参考先

| 生成物 | 参考ファイル |
|---|---|
| Model | `lib/data/models/travel_plan.dart` |
| Remote DataSource | `lib/data/datasources/remote/travel_plan_remote_datasource.dart` |
| Repository I/F | `lib/data/repositories/travel_plan_repository.dart` |
| RepositoryImpl | `lib/data/repositories/travel_plan_repository_impl.dart` |
| ViewModel | `lib/presentation/viewmodels/plan_list_viewmodel.dart` |
| Screen | `lib/presentation/screens/booking_history/booking_history_screen.dart` |

## State クラスのパターン

```dart
class {Feature}State {
  final List<{Feature}Model> items;  // データ
  final bool isLoading;
  final AppError? error;  // AppError 型（NetworkError / GraphQLError / UnknownError）

  const {Feature}State({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  {Feature}State copyWith({
    List<{Feature}Model>? items,
    bool? isLoading,
    AppError? error,
    bool clearError = false,  // nullable フィールドのクリアには専用フラグ
  }) {
    return {Feature}State(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
```

## ViewModel のパターン

```dart
@riverpod
class {Feature}ViewModel extends _{Feature}ViewModel {
  @override
  {Feature}State build() => const {Feature}State();

  Future<void> load() async {
    if (state.isLoading) return;  // 二重実行防止
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read({feature}RepositoryProvider);
      final data = await repo.getItems();
      state = state.copyWith(items: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppError ? e : UnknownError(e.toString()),
      );
    }
  }
}
```

## Provider の配置ルール

新機能の Provider は `plan_list_viewmodel.dart` のグローバル Provider セクションに追加するか、
`lib/presentation/viewmodels/{feature}_viewmodel.dart` 内のトップレベルに定義する。

```dart
@riverpod
{Feature}Repository {feature}Repository(Ref ref) {
  return {Feature}RepositoryImpl(ref.watch({feature}RemoteDataSourceProvider));
}

@riverpod
{Feature}RemoteDataSource {feature}RemoteDataSource(Ref ref) {
  return {Feature}RemoteDataSource(ref.watch(graphQLHttpClientProvider));
}
```

## Screen のパターン

loading / error / data の3状態分岐は `AsyncStateBuilder<T>` を使う。
`AppErrorWidget` / `LoadingIndicator` を直接 if 文で分岐させない。

```dart
import '../../widgets/async_state_builder.dart';

class {Feature}Screen extends ConsumerStatefulWidget {
  const {Feature}Screen({super.key});

  @override
  ConsumerState<{Feature}Screen> createState() => _{Feature}ScreenState();
}

class _{Feature}ScreenState extends ConsumerState<{Feature}Screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read({feature}ViewModelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch({feature}ViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('{Feature}')),
      body: AsyncStateBuilder<List<{Feature}Model>>(
        isLoading: state.isLoading,
        error: state.error,
        data: state.items.isNotEmpty ? state.items : null,
        onRetry: () => ref.read({feature}ViewModelProvider.notifier).load(),
        emptyBuilder: () => _buildEmptyState(),
        builder: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => _buildItem(items[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('データがありません'));
  }

  Widget _buildItem({Feature}Model item) {
    return ListTile(title: Text(item.toString()));
  }
}
```

## app_router.dart への追加

```dart
GoRoute(
  path: '/{feature}',
  builder: (context, state) => const {Feature}Screen(),
),
```
