import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_booking_mobile/data/models/favorite_plan.dart';
import 'package:travel_booking_mobile/data/repositories/favorite_repository.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/plan_list_viewmodel.dart';

import 'favorite_viewmodel_test.mocks.dart';

@GenerateMocks([FavoriteRepository])
void main() {
  late MockFavoriteRepository mockRepository;
  late ProviderContainer container;
  late StreamController<List<FavoritePlan>> favoritesController;

  FavoritePlan createFavoritePlan(String planId, String title) {
    return FavoritePlan(
      planId: planId,
      title: title,
      destination: '東京',
      country: '日本',
      price: 150000,
      effectivePrice: 135000,
      rating: 4.7,
      durationDays: 5,
      category: 'city',
      difficulty: 'easy',
      primaryImageUrl: 'https://example.com/image.jpg',
      region: 'アジア',
      savedAt: DateTime(2024, 1, 1),
    );
  }

  setUp(() {
    mockRepository = MockFavoriteRepository();
    favoritesController = StreamController<List<FavoritePlan>>.broadcast();

    when(mockRepository.watchFavorites()).thenAnswer((_) => favoritesController.stream);

    container = ProviderContainer(
      overrides: [
        favoriteRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    favoritesController.close();
  });

  group('FavoriteViewModel', () {
    test('initial state has loading true', () {
      final state = container.read(favoriteViewModelProvider);
      expect(state.isLoading, isTrue);
      expect(state.favorites, isEmpty);
    });

    test('favorites list updates when stream emits', () async {
      // listen keeps the autoDispose provider alive
      final sub = container.listen(favoriteViewModelProvider, (_, __) {});

      final fav1 = createFavoritePlan('plan-1', '東京エクスプローラー');
      final fav2 = createFavoritePlan('plan-2', '京都伝統文化');

      favoritesController.add([fav1, fav2]);
      await Future.delayed(Duration.zero);

      final state = container.read(favoriteViewModelProvider);
      expect(state.favorites.length, 2);
      expect(state.isLoading, isFalse);
      expect(state.favorites[0].planId, 'plan-1');
      expect(state.favorites[1].planId, 'plan-2');
      sub.close();
    });

    test('isEmpty returns true when no favorites', () async {
      final sub = container.listen(favoriteViewModelProvider, (_, __) {});
      favoritesController.add([]);
      await Future.delayed(Duration.zero);

      final state = container.read(favoriteViewModelProvider);
      expect(state.isEmpty, isTrue);
      sub.close();
    });

    test('isEmpty returns false when favorites exist', () async {
      final sub = container.listen(favoriteViewModelProvider, (_, __) {});
      favoritesController.add([createFavoritePlan('plan-1', 'テスト')]);
      await Future.delayed(Duration.zero);

      final state = container.read(favoriteViewModelProvider);
      expect(state.isEmpty, isFalse);
      sub.close();
    });

    test('removeFavorite calls repository', () async {
      when(mockRepository.removeFavorite(any)).thenAnswer((_) async {});

      final sub = container.listen(favoriteViewModelProvider, (_, __) {});
      favoritesController.add([createFavoritePlan('plan-1', 'テスト')]);
      await Future.delayed(Duration.zero);

      await container
          .read(favoriteViewModelProvider.notifier)
          .removeFavorite('plan-1');

      verify(mockRepository.removeFavorite('plan-1')).called(1);
      sub.close();
    });

    test('removeFavorite sets error on failure', () async {
      when(mockRepository.removeFavorite(any)).thenThrow(Exception('DB error'));

      final sub = container.listen(favoriteViewModelProvider, (_, __) {});
      favoritesController.add([]);
      await Future.delayed(Duration.zero);

      await container
          .read(favoriteViewModelProvider.notifier)
          .removeFavorite('plan-1');

      final state = container.read(favoriteViewModelProvider);
      expect(state.error, isNotNull);
      sub.close();
    });

    test('clearError clears error state', () async {
      when(mockRepository.removeFavorite(any)).thenThrow(Exception('error'));

      final sub = container.listen(favoriteViewModelProvider, (_, __) {});
      favoritesController.add([]);
      await Future.delayed(Duration.zero);

      await container
          .read(favoriteViewModelProvider.notifier)
          .removeFavorite('plan-1');
      expect(container.read(favoriteViewModelProvider).error, isNotNull);

      container.read(favoriteViewModelProvider.notifier).clearError();
      expect(container.read(favoriteViewModelProvider).error, isNull);
      sub.close();
    });

    test('favorites list updates reactively when stream changes', () async {
      final sub = container.listen(favoriteViewModelProvider, (_, __) {});

      favoritesController.add([createFavoritePlan('plan-1', 'テスト1')]);
      await Future.delayed(Duration.zero);
      expect(container.read(favoriteViewModelProvider).favorites.length, 1);

      favoritesController.add([
        createFavoritePlan('plan-1', 'テスト1'),
        createFavoritePlan('plan-2', 'テスト2'),
      ]);
      await Future.delayed(Duration.zero);
      expect(container.read(favoriteViewModelProvider).favorites.length, 2);
      sub.close();
    });
  });
}
