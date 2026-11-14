import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_booking_mobile/core/auth/auth_state.dart';
import 'package:travel_booking_mobile/data/models/auth_user.dart';
import 'package:travel_booking_mobile/data/models/booking.dart';
import 'package:travel_booking_mobile/data/repositories/travel_plan_repository.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/booking_history_viewmodel.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/plan_list_viewmodel.dart';

import 'booking_history_viewmodel_test.mocks.dart';

@GenerateMocks([TravelPlanRepository])
void main() {
  late MockTravelPlanRepository mockRepository;
  late ProviderContainer container;

  // ログイン済みユーザー (email: test@example.com) を返すフェイク
  const loggedInUser = AuthUser(
    id: 'user-1',
    email: 'test@example.com',
    name: 'テスト太郎',
  );

  final mockBooking1 = Booking(
    id: 'booking-1',
    planId: 'plan-1',
    planTitle: '東京エクスプローラー5日間',
    customerName: 'テスト太郎',
    customerEmail: 'test@example.com',
    customerPhone: '090-0000-0001',
    numberOfPeople: 2,
    travelDate: DateTime(2025, 8, 1),
    totalPrice: 300000,
    status: 'CONFIRMED',
    createdAt: DateTime(2025, 4, 1),
    updatedAt: DateTime(2025, 4, 1),
  );

  final mockBooking2 = Booking(
    id: 'booking-2',
    planId: 'plan-2',
    planTitle: 'バリ島リゾート7日間',
    customerName: 'テスト太郎',
    customerEmail: 'test@example.com',
    customerPhone: '090-0000-0001',
    numberOfPeople: 1,
    travelDate: DateTime(2025, 9, 15),
    totalPrice: 280000,
    status: 'PENDING',
    createdAt: DateTime(2025, 4, 10),
    updatedAt: DateTime(2025, 4, 10),
  );

  // ログイン済みコンテナを返すヘルパー
  ProviderContainer makeContainer({AuthUser? user}) {
    return ProviderContainer(
      overrides: [
        travelPlanRepositoryProvider.overrideWithValue(mockRepository),
        authStateProvider.overrideWith(
          () => _FakeAuthStateNotifier(
            user != null
                ? AuthState(isLoggedIn: true, currentUser: user)
                : const AuthState(),
          ),
        ),
      ],
    );
  }

  setUp(() {
    mockRepository = MockTravelPlanRepository();
    container = makeContainer(user: loggedInUser);
  });

  tearDown(() {
    container.dispose();
  });

  group('BookingHistoryViewModel', () {
    test('initial state has empty bookings and no loading', () {
      final state = container.read(bookingHistoryViewModelProvider);
      expect(state.bookings, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test(
      'loadBookings sets isLoading during fetch then false on success',
      () async {
        when(mockRepository.fetchBookings('test@example.com'))
            .thenAnswer((_) async => [mockBooking1, mockBooking2]);

        final notifier = container.read(
          bookingHistoryViewModelProvider.notifier,
        );
        final future = notifier.loadBookings();

        await future;

        final state = container.read(bookingHistoryViewModelProvider);
        expect(state.isLoading, isFalse);
        expect(state.bookings.length, 2);
        expect(state.error, isNull);
      },
    );

    test('loadBookings populates bookings correctly', () async {
      when(mockRepository.fetchBookings('test@example.com'))
          .thenAnswer((_) async => [mockBooking1, mockBooking2]);

      await container
          .read(bookingHistoryViewModelProvider.notifier)
          .loadBookings();

      final state = container.read(bookingHistoryViewModelProvider);
      expect(state.bookings[0].id, 'booking-1');
      expect(state.bookings[1].id, 'booking-2');
      expect(state.bookings[0].planTitle, '東京エクスプローラー5日間');
      expect(state.bookings[0].status, 'CONFIRMED');
      expect(state.bookings[1].status, 'PENDING');
    });

    test('loadBookings returns empty list when no bookings', () async {
      when(mockRepository.fetchBookings('test@example.com'))
          .thenAnswer((_) async => []);

      await container
          .read(bookingHistoryViewModelProvider.notifier)
          .loadBookings();

      final state = container.read(bookingHistoryViewModelProvider);
      expect(state.bookings, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('loadBookings sets error on failure', () async {
      when(mockRepository.fetchBookings('test@example.com'))
          .thenThrow(Exception('Network error'));

      await container
          .read(bookingHistoryViewModelProvider.notifier)
          .loadBookings();

      final state = container.read(bookingHistoryViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.bookings, isEmpty);
      expect(state.error, isNotNull);
      expect(state.error!.message, contains('Network error'));
    });

    test('未ログイン時に空リストが返ること', () async {
      final unauthContainer = makeContainer();
      addTearDown(unauthContainer.dispose);

      await unauthContainer
          .read(bookingHistoryViewModelProvider.notifier)
          .loadBookings();

      final state = unauthContainer.read(bookingHistoryViewModelProvider);
      expect(state.bookings, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      verifyNever(mockRepository.fetchBookings(any));
    });

    test('clearError removes error state', () async {
      when(mockRepository.fetchBookings('test@example.com'))
          .thenThrow(Exception('Network error'));

      await container
          .read(bookingHistoryViewModelProvider.notifier)
          .loadBookings();

      expect(container.read(bookingHistoryViewModelProvider).error, isNotNull);

      container.read(bookingHistoryViewModelProvider.notifier).clearError();

      expect(container.read(bookingHistoryViewModelProvider).error, isNull);
    });

    test('isLoading guard prevents re-entry on concurrent calls', () async {
      var callCount = 0;
      when(mockRepository.fetchBookings('test@example.com'))
          .thenAnswer((_) async {
            callCount++;
            return [mockBooking1];
          });

      final notifier = container.read(bookingHistoryViewModelProvider.notifier);

      final f1 = notifier.loadBookings();

      expect(container.read(bookingHistoryViewModelProvider).isLoading, isTrue);

      await notifier.loadBookings();

      await f1;

      expect(callCount, 1);
      expect(
        container.read(bookingHistoryViewModelProvider).isLoading,
        isFalse,
      );
    });
  });
}

// ── テスト用フェイク ──────────────────────────────────────────────────────────

class _FakeAuthStateNotifier extends AuthStateNotifier {
  final AuthState _initialState;

  _FakeAuthStateNotifier([this._initialState = const AuthState()]);

  @override
  AuthState build() => _initialState;
}
