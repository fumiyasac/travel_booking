# Preview 環境ボイラープレート

実際の `lib/preview/` 構成から抽出したテンプレート。
新規セットアップ時はこのファイルを Read してから各ファイルを生成すること。

---

## 1. mock_providers.dart（完全版）

既存の `FakeInMemoryFavoritesStorage` に加え、
Screen-level Preview 用の `FakeTravelPlanRepository` を追加した完全版。

```dart
// lib/preview/mock_providers.dart
import 'dart:async';
import '../core/database/app_database.dart';
import '../data/models/booking.dart';
import '../data/models/favorite_plan.dart';
import '../data/models/plan_filter.dart';
import '../data/models/travel_plan.dart';
import '../data/repositories/favorite_repository.dart';
import '../data/repositories/travel_plan_repository.dart';
import '../presentation/viewmodels/plan_list_viewmodel.dart';
import 'mock_data.dart';

// ── FavoritesStorage モック ───────────────────────────────────────────────
// SharedPreferences に依存しない in-memory 実装
class FakeInMemoryFavoritesStorage extends FavoritesStorage {
  final List<FavoritePlan> _favorites;

  FakeInMemoryFavoritesStorage({List<FavoritePlan>? initialFavorites})
      : _favorites = initialFavorites != null ? List.of(initialFavorites) : [];

  @override
  Future<List<FavoritePlan>> getAll() async => List.of(_favorites);

  @override
  Future<void> add(FavoritePlan plan) async {
    _favorites.removeWhere((f) => f.planId == plan.planId);
    _favorites.insert(0, plan);
  }

  @override
  Future<void> remove(String planId) async =>
      _favorites.removeWhere((f) => f.planId == planId);

  @override
  Future<void> clear() async => _favorites.clear();

  @override
  Future<bool> contains(String planId) async =>
      _favorites.any((f) => f.planId == planId);
}

// ── TravelPlanRepository モック ──────────────────────────────────────────
// isEmpty / throwError フラグで3モードを切り替える
class FakeTravelPlanRepository implements TravelPlanRepository {
  final bool isEmpty;
  final bool throwError;

  const FakeTravelPlanRepository({
    this.isEmpty = false,
    this.throwError = false,
  });

  // ローディング中を模擬するファクトリ（Completer で未解決のまま保持）
  factory FakeTravelPlanRepository.loading() => _LoadingFakeTravelPlanRepository();

  @override
  Future<(List<TravelPlan>, int, bool, int)> getPlans({
    PlanFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (throwError) throw Exception('Preview: データ取得エラーが発生しました');
    if (isEmpty) return (const <TravelPlan>[], 0, false, 1);
    return (mockPlans, mockPlans.length, false, 1);
  }

  @override
  Future<TravelPlan> getPlan(String id) async {
    if (throwError) throw Exception('Preview: プラン取得エラー');
    return mockPlans.firstWhere(
      (p) => p.id == id,
      orElse: () => mockPlans.first,
    );
  }

  @override
  Future<Booking> createBooking({
    required String planId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required int numberOfPeople,
    required DateTime travelDate,
    String? specialRequests,
    String? paymentMethod,
  }) async {
    return Booking(
      id: 'preview_booking_001',
      planId: planId,
      planTitle: mockPlans.first.title,
      planImageUrl: mockPlans.first.primaryImageUrl,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      numberOfPeople: numberOfPeople,
      travelDate: travelDate,
      specialRequests: specialRequests,
      totalPrice: mockPlans.first.effectivePrice * numberOfPeople,
      status: 'CONFIRMED',
      paymentMethod: paymentMethod,
      createdAt: DateTime(2025, 4, 1),
      updatedAt: DateTime(2025, 4, 1),
    );
  }

  @override
  Future<void> cancelBooking(String bookingId) async {}
}

// ローディング状態専用（Completer が未完了のまま保持）
class _LoadingFakeTravelPlanRepository extends FakeTravelPlanRepository {
  @override
  Future<(List<TravelPlan>, int, bool, int)> getPlans({
    PlanFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) => Completer<(List<TravelPlan>, int, bool, int)>().future;

  @override
  Future<TravelPlan> getPlan(String id) =>
      Completer<TravelPlan>().future;
}

// ── Provider overrides ───────────────────────────────────────────────────
// ProviderScope(overrides: previewProviderOverrides) で使う
final previewProviderOverrides = [
  favoritesStorageProvider.overrideWith(
    (ref) => FakeInMemoryFavoritesStorage(),
  ),
  travelPlanRepositoryProvider.overrideWith(
    (ref) => const FakeTravelPlanRepository(),
  ),
];

// Screen ごとにモードを変えたい場合は個別に overrides リストを組み立てる
List<Override> previewOverridesWith({
  bool isEmpty = false,
  bool throwError = false,
  bool loading = false,
}) => [
  favoritesStorageProvider.overrideWith(
    (ref) => FakeInMemoryFavoritesStorage(),
  ),
  travelPlanRepositoryProvider.overrideWith(
    (ref) => loading
        ? FakeTravelPlanRepository.loading()
        : FakeTravelPlanRepository(isEmpty: isEmpty, throwError: throwError),
  ),
];
```

---

## 2. mock_data.dart（10件版）

10件の多様なモックプランを定義する完全版。
`_makePlan()` ヘルパーでコンストラクタを直接呼び出し、`fromJson` は使わない。

```dart
// lib/preview/mock_data.dart
import '../data/models/travel_plan.dart';
import '../data/models/travel_plan_image.dart';

TravelPlan _makePlan({
  required String id,
  required String title,
  required String destination,
  required String country,
  required String category,
  required String difficulty,
  required double rating,
  required int reviewCount,
  required double price,
  double? discountPrice,
  required int durationDays,
  required String imagePhotoId,
}) {
  final effectivePrice = discountPrice ?? price;
  return TravelPlan(
    id: id,
    title: title,
    description: 'プレビュー用のサンプル説明文です。',
    destination: destination,
    country: country,
    region: 'サンプル地域',
    latitude: 35.0,
    longitude: 135.0,
    price: price,
    discountPrice: discountPrice,
    effectivePrice: effectivePrice,
    durationDays: durationDays,
    maxParticipants: 20,
    currentBookings: 5,
    availableSpots: 15,
    category: category,
    difficulty: difficulty,
    rating: rating,
    reviewCount: reviewCount,
    isAvailable: true,
    language: '日本語',
    tags: const [],
    images: [
      TravelPlanImage(
        id: '${id}_img',
        url: 'https://images.unsplash.com/photo-$imagePhotoId?auto=format&fit=crop&w=800&q=60',
        isPrimary: true,
        displayOrder: 0,
      ),
    ],
    highlights: const [],
    itinerary: const [],
    includedItems: const [],
    excludedItems: const [],
    reviews: const [],
    createdAt: DateTime(2025, 4, 1),
  );
}

// ── 個別定数（既存の3件と互換） ──────────────────────────────────────────
final mockPlanTokyo = _makePlan(
  id: 'mock_tokyo', title: '東京エクスプローラー5日間',
  destination: '東京', country: '日本', category: 'city', difficulty: 'easy',
  rating: 4.8, reviewCount: 128, price: 150000, durationDays: 5,
  imagePhotoId: '1540959733332-eab4deabeeaf',
);

final mockPlanParis = _makePlan(
  id: 'mock_paris', title: 'パリ・ロマンス＆カルチャー6日間',
  destination: 'パリ', country: 'フランス', category: 'cultural', difficulty: 'moderate',
  rating: 4.5, reviewCount: 96, price: 320000, discountPrice: 268000, durationDays: 6,
  imagePhotoId: '1511739001486-6bfe10ce785f',
);

final mockPlanHimalayas = _makePlan(
  id: 'mock_himalayas', title: 'ヒマラヤ山岳トレッキング10日間',
  destination: 'カトマンズ', country: 'ネパール', category: 'adventure', difficulty: 'hard',
  rating: 4.9, reviewCount: 43, price: 480000, durationDays: 10,
  imagePhotoId: '1464822759023-fed622ff2c3b',
);

final mockPlanBali = _makePlan(
  id: 'mock_bali', title: 'バリ島リゾート＆スパ7日間',
  destination: 'バリ', country: 'インドネシア', category: 'resort', difficulty: 'easy',
  rating: 4.7, reviewCount: 215, price: 280000, discountPrice: 238000, durationDays: 7,
  imagePhotoId: '1537996088701-be9b9c39dac8',
);

final mockPlanRome = _makePlan(
  id: 'mock_rome', title: 'ローマ＆フィレンツェ 古都めぐり8日間',
  destination: 'ローマ', country: 'イタリア', category: 'cultural', difficulty: 'easy',
  rating: 4.6, reviewCount: 184, price: 380000, durationDays: 8,
  imagePhotoId: '1552832134-bb0977a8f2a0',
);

final mockPlanNewYork = _makePlan(
  id: 'mock_new_york', title: 'ニューヨーク シティブレイク4日間',
  destination: 'ニューヨーク', country: 'アメリカ', category: 'city', difficulty: 'easy',
  rating: 4.3, reviewCount: 72, price: 350000, durationDays: 4,
  imagePhotoId: '1531973019510-492e728d2c53',
);

final mockPlanSafari = _makePlan(
  id: 'mock_safari', title: 'ケニア大自然サファリ9日間',
  destination: 'ナイロビ', country: 'ケニア', category: 'adventure', difficulty: 'moderate',
  rating: 4.9, reviewCount: 31, price: 620000, durationDays: 9,
  imagePhotoId: '1516426122078-c23e76319801',
);

final mockPlanKyoto = _makePlan(
  id: 'mock_kyoto', title: '京都・奈良 古都文化体験3日間',
  destination: '京都', country: '日本', category: 'cultural', difficulty: 'easy',
  rating: 4.7, reviewCount: 302, price: 85000, discountPrice: 72000, durationDays: 3,
  imagePhotoId: '1493976040374-85c8e12f0c0e',
);

final mockPlanPhuket = _makePlan(
  id: 'mock_phuket', title: 'プーケット マリンリゾート5日間',
  destination: 'プーケット', country: 'タイ', category: 'resort', difficulty: 'easy',
  rating: 4.4, reviewCount: 156, price: 195000, durationDays: 5,
  imagePhotoId: '1507525428034-b723cf961d3e',
);

final mockPlanPatagonia = _makePlan(
  id: 'mock_patagonia', title: 'パタゴニア 秘境トレッキング14日間',
  destination: 'プエルトナタレス', country: 'チリ', category: 'adventure', difficulty: 'hard',
  rating: 4.8, reviewCount: 19, price: 750000, durationDays: 14,
  imagePhotoId: '1501854140801-50d01698950b',
);

// ── まとめリスト（Screen Preview の "正常10件" で使う） ──────────────────
final mockPlans = [
  mockPlanTokyo,
  mockPlanParis,
  mockPlanHimalayas,
  mockPlanBali,
  mockPlanRome,
  mockPlanNewYork,
  mockPlanSafari,
  mockPlanKyoto,
  mockPlanPhuket,
  mockPlanPatagonia,
];
```

---

## 3. main.dart（完全版）

`@widgetbook.App()` アノテーション + MaterialTheme / Viewport / TextScale / Localization アドオン構成。

```dart
// lib/preview/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook/widgetbook.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../core/theme/app_theme.dart';
import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookPreviewApp());
}

@widgetbook.App()
class WidgetbookPreviewApp extends StatelessWidget {
  const WidgetbookPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.lightTheme),
          ],
        ),
        ViewportAddon([
          IosViewports.iPhone13,
          AndroidViewports.samsungGalaxyA50,
        ]),
        TextScaleAddon(min: 0.85, max: 2.0),
        LocalizationAddon(
          locales: [const Locale('ja', 'JP')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ],
    );
  }
}
```

---

## 4. GoRouter Preview 用インスタンス（Screen Preview で使う）

Screen Preview では実際の `app_router.dart` の GoRouter を使うとリダイレクトや
ネストルートでクラッシュする場合がある。以下のシンプルな GoRouter を使うこと。

```dart
// Screen Preview ファイル内で定義して使う（global でなくファイルスコープで十分）
import 'package:go_router/go_router.dart';

final _previewRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SizedBox.shrink(),
    ),
  ],
);
```

Screen を MaterialApp.router にラップする場合：

```dart
Widget buildXxxScreenPreview(BuildContext context) {
  return ProviderScope(
    overrides: previewOverridesWith(/* モード指定 */),
    child: MaterialApp.router(
      routerConfig: _previewRouter,
      builder: (context, child) => const XxxScreen(),
      // Widgetbook の Localization アドオンが効かない場合は以下を追加
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', 'JP')],
    ),
  );
}
```
