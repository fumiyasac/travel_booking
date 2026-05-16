# ViewModel テストコードパターン

## テストファイルの基本構成

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_booking_mobile/data/repositories/xxxxx_repository.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/xxxxx_viewmodel.dart';

import 'xxxxx_viewmodel_test.mocks.dart';

@GenerateMocks([XxxxxRepository])
void main() {
  late MockXxxxxRepository mockRepository;
  late ProviderContainer container;

  // --- テストデータ ---
  // 日本語の現実的な値を使う
  final mockItem = XxxxxModel(
    id: 'item-1',
    title: 'テスト用タイトル',
    // ...
  );

  setUp(() {
    mockRepository = MockXxxxxRepository();
    container = ProviderContainer(
      overrides: [
        xxxxxRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('XxxxxViewModel', () {
    // テストケースをここに追加
  });
}
```

## テストケースのパターン集

### 初期状態のテスト

```dart
test('初期状態が正しいデフォルト値を持つ', () {
  final state = container.read(xxxxxViewModelProvider);
  expect(state.items, isEmpty);
  expect(state.isLoading, isFalse);
  expect(state.error, isNull);
});
```

### 成功パスのテスト

```dart
test('loadItems が成功したとき items が更新され isLoading が false になる', () async {
  when(mockRepository.getItems())
      .thenAnswer((_) async => [mockItem]);

  await container.read(xxxxxViewModelProvider.notifier).loadItems();

  final state = container.read(xxxxxViewModelProvider);
  expect(state.isLoading, isFalse);
  expect(state.items.length, 1);
  expect(state.items.first.id, 'item-1');
  expect(state.error, isNull);
});
```

### 失敗パスのテスト

```dart
test('loadItems が失敗したとき error がセットされ isLoading が false になる', () async {
  when(mockRepository.getItems())
      .thenThrow(Exception('ネットワークエラー'));

  await container.read(xxxxxViewModelProvider.notifier).loadItems();

  final state = container.read(xxxxxViewModelProvider);
  expect(state.isLoading, isFalse);
  expect(state.items, isEmpty);
  expect(state.error, isNotNull);
  expect(state.error, contains('ネットワークエラー'));
});
```

### 入力値更新のテスト

```dart
test('updateKeyword がフィルターキーワードを更新する', () async {
  when(mockRepository.getItems(filter: anyNamed('filter')))
      .thenAnswer((_) async => [mockItem]);

  await container.read(xxxxxViewModelProvider.notifier).updateKeyword('東京');

  final state = container.read(xxxxxViewModelProvider);
  expect(state.filter.keyword, '東京');
});
```

### clearError のテスト

```dart
test('clearError がエラー状態をクリアする', () async {
  when(mockRepository.getItems()).thenThrow(Exception('エラー'));
  await container.read(xxxxxViewModelProvider.notifier).loadItems();

  expect(container.read(xxxxxViewModelProvider).error, isNotNull);

  container.read(xxxxxViewModelProvider.notifier).clearError();

  expect(container.read(xxxxxViewModelProvider).error, isNull);
});
```

### 二重実行防止のテスト

```dart
test('loadItems がローディング中に再呼び出しされても二重実行しない', () async {
  when(mockRepository.getItems())
      .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [mockItem];
      });

  // 1回目（完了を待たない）
  final future1 = container.read(xxxxxViewModelProvider.notifier).loadItems();
  // 2回目（ローディング中なので無視される）
  final future2 = container.read(xxxxxViewModelProvider.notifier).loadItems();

  await Future.wait([future1, future2]);

  // getItems は1回だけ呼ばれる
  verify(mockRepository.getItems()).called(1);
});
```

### ページネーションのテスト

```dart
test('loadMore が既存リストに追加で読み込む', () async {
  when(mockRepository.getItems(page: 1, pageSize: anyNamed('pageSize')))
      .thenAnswer((_) async => ([mockItem1], true));  // hasNextPage: true

  when(mockRepository.getItems(page: 2, pageSize: anyNamed('pageSize')))
      .thenAnswer((_) async => ([mockItem2], false));  // hasNextPage: false

  await container.read(xxxxxViewModelProvider.notifier).loadItems();
  await container.read(xxxxxViewModelProvider.notifier).loadMore();

  final state = container.read(xxxxxViewModelProvider);
  expect(state.items.length, 2);
  expect(state.hasNextPage, isFalse);
});

test('hasNextPage が false のとき loadMore が何もしない', () async {
  when(mockRepository.getItems(
    page: anyNamed('page'),
    pageSize: anyNamed('pageSize'),
  )).thenAnswer((_) async => ([mockItem1], false));

  await container.read(xxxxxViewModelProvider.notifier).loadItems();

  // hasNextPage が false なので loadMore は何もしない
  await container.read(xxxxxViewModelProvider.notifier).loadMore();

  verify(mockRepository.getItems(
    page: anyNamed('page'),
    pageSize: anyNamed('pageSize'),
  )).called(1);  // loadItems の1回のみ
});
```

## よくある間違いと修正

| 間違い | 修正 |
|---|---|
| `tearDown` で `container.dispose()` を忘れる | 必ず `tearDown(() => container.dispose())` を追加 |
| `@GenerateMocks` 後に `build_runner` を実行しない | `melos run build_runner` でモッククラスを再生成 |
| `when` の引数マッチャーを付け忘れる | `anyNamed('page')` など Mockito のマッチャーを使う |
| テストデータを英語にする | 日本語の現実的な値（`'東京エクスプローラー5日間'`）を使う |
