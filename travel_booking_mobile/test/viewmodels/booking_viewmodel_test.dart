import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_booking_mobile/data/models/booking.dart';
import 'package:travel_booking_mobile/data/models/travel_plan.dart';
import 'package:travel_booking_mobile/data/repositories/travel_plan_repository.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/booking_viewmodel.dart';
import 'package:travel_booking_mobile/presentation/viewmodels/plan_list_viewmodel.dart';

import 'booking_viewmodel_test.mocks.dart';

@GenerateMocks([TravelPlanRepository])
void main() {
  late MockTravelPlanRepository mockRepository;
  late ProviderContainer container;

  final mockPlan = TravelPlan(
    id: 'plan-1',
    title: '東京エクスプローラー5日間',
    description: 'Test',
    destination: '東京',
    country: '日本',
    region: 'アジア',
    latitude: 35.6762,
    longitude: 139.6503,
    price: 150000,
    effectivePrice: 135000,
    discountPrice: 135000,
    durationDays: 5,
    maxParticipants: 12,
    currentBookings: 4,
    availableSpots: 8,
    category: 'city',
    difficulty: 'easy',
    rating: 4.7,
    reviewCount: 128,
    isAvailable: true,
    language: '日本語',
    tags: [],
    images: [],
    highlights: [],
    itinerary: [],
    includedItems: [],
    excludedItems: [],
    reviews: [],
    createdAt: DateTime(2024, 1, 1),
  );

  final mockBooking = Booking(
    id: 'booking-123',
    planId: 'plan-1',
    customerName: '山田 太郎',
    customerEmail: 'yamada@test.com',
    customerPhone: '090-1234-5678',
    numberOfPeople: 2,
    travelDate: DateTime(2025, 8, 1),
    totalPrice: 270000,
    status: 'CONFIRMED',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockTravelPlanRepository();
    container = ProviderContainer(
      overrides: [
        travelPlanRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BookingViewModel', () {
    test('initial state has empty fields', () {
      final state = container.read(bookingViewModelProvider);
      expect(state.customerName, isEmpty);
      expect(state.customerEmail, isEmpty);
      expect(state.customerPhone, isEmpty);
      expect(state.numberOfPeople, 1);
      expect(state.travelDate, isNull);
      expect(state.specialRequests, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.error, isNull);
      expect(state.completedBooking, isNull);
    });

    test('updateCustomerName updates state', () {
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerName('山田 太郎');
      expect(container.read(bookingViewModelProvider).customerName, '山田 太郎');
    });

    test('updateCustomerEmail updates state', () {
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerEmail('test@example.com');
      expect(container.read(bookingViewModelProvider).customerEmail,
          'test@example.com');
    });

    test('updateCustomerPhone updates state', () {
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerPhone('090-1234-5678');
      expect(container.read(bookingViewModelProvider).customerPhone,
          '090-1234-5678');
    });

    test('updateNumberOfPeople updates state and rejects invalid values', () {
      container.read(bookingViewModelProvider.notifier).updateNumberOfPeople(3);
      expect(container.read(bookingViewModelProvider).numberOfPeople, 3);

      container.read(bookingViewModelProvider.notifier).updateNumberOfPeople(0);
      expect(container.read(bookingViewModelProvider).numberOfPeople, 3);
    });

    test('updateTravelDate updates state', () {
      final date = DateTime(2025, 8, 1);
      container.read(bookingViewModelProvider.notifier).updateTravelDate(date);
      expect(container.read(bookingViewModelProvider).travelDate, date);
    });

    test('submitBooking validates empty fields and returns false', () async {
      final result = await container
          .read(bookingViewModelProvider.notifier)
          .submitBooking('plan-1', 8);

      expect(result, isFalse);
      final state = container.read(bookingViewModelProvider);
      expect(state.validationErrors['customerName'], isNotNull);
      expect(state.validationErrors['customerEmail'], isNotNull);
      expect(state.validationErrors['customerPhone'], isNotNull);
      expect(state.validationErrors['travelDate'], isNotNull);
    });

    test('submitBooking validates invalid email format', () async {
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerName('山田 太郎');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerEmail('invalid-email');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerPhone('090-1234-5678');
      container
          .read(bookingViewModelProvider.notifier)
          .updateTravelDate(DateTime.now().add(const Duration(days: 30)));

      final result = await container
          .read(bookingViewModelProvider.notifier)
          .submitBooking('plan-1', 8);

      expect(result, isFalse);
      expect(
          container
              .read(bookingViewModelProvider)
              .validationErrors['customerEmail'],
          isNotNull);
    });

    test(
        'submitBooking returns false when numberOfPeople exceeds availableSpots',
        () async {
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerName('山田 太郎');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerEmail('test@example.com');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerPhone('090-1234-5678');
      container
          .read(bookingViewModelProvider.notifier)
          .updateNumberOfPeople(10);
      container
          .read(bookingViewModelProvider.notifier)
          .updateTravelDate(DateTime.now().add(const Duration(days: 30)));

      final result = await container
          .read(bookingViewModelProvider.notifier)
          .submitBooking('plan-1', 5);

      expect(result, isFalse);
      expect(container.read(bookingViewModelProvider).error, isNotNull);
    });

    test('submitBooking succeeds with valid data', () async {
      when(mockRepository.createBooking(
        planId: anyNamed('planId'),
        customerName: anyNamed('customerName'),
        customerEmail: anyNamed('customerEmail'),
        customerPhone: anyNamed('customerPhone'),
        numberOfPeople: anyNamed('numberOfPeople'),
        travelDate: anyNamed('travelDate'),
        specialRequests: anyNamed('specialRequests'),
        paymentMethod: anyNamed('paymentMethod'),
      )).thenAnswer((_) async => mockBooking);

      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerName('山田 太郎');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerEmail('test@example.com');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerPhone('090-1234-5678');
      container.read(bookingViewModelProvider.notifier).updateNumberOfPeople(2);
      container
          .read(bookingViewModelProvider.notifier)
          .updateTravelDate(DateTime.now().add(const Duration(days: 30)));

      final result = await container
          .read(bookingViewModelProvider.notifier)
          .submitBooking('plan-1', 8);

      expect(result, isTrue);
      final state = container.read(bookingViewModelProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.completedBooking, isNotNull);
      expect(state.completedBooking!.id, 'booking-123');
      expect(state.error, isNull);
    });

    test('submitBooking sets error on repository failure', () async {
      when(mockRepository.createBooking(
        planId: anyNamed('planId'),
        customerName: anyNamed('customerName'),
        customerEmail: anyNamed('customerEmail'),
        customerPhone: anyNamed('customerPhone'),
        numberOfPeople: anyNamed('numberOfPeople'),
        travelDate: anyNamed('travelDate'),
        specialRequests: anyNamed('specialRequests'),
        paymentMethod: anyNamed('paymentMethod'),
      )).thenThrow(Exception('予約に失敗しました'));

      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerName('山田 太郎');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerEmail('test@example.com');
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerPhone('090-1234-5678');
      container
          .read(bookingViewModelProvider.notifier)
          .updateTravelDate(DateTime.now().add(const Duration(days: 30)));

      final result = await container
          .read(bookingViewModelProvider.notifier)
          .submitBooking('plan-1', 8);

      expect(result, isFalse);
      final state = container.read(bookingViewModelProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.error, isNotNull);
      expect(state.completedBooking, isNull);
    });

    test('price calculation is correct', () {
      container.read(bookingViewModelProvider.notifier).updateNumberOfPeople(3);
      final state = container.read(bookingViewModelProvider);
      final total = state.calculateTotal(mockPlan);
      expect(total, 135000 * 3);
    });

    test('reset clears all form state', () {
      container
          .read(bookingViewModelProvider.notifier)
          .updateCustomerName('山田 太郎');
      container.read(bookingViewModelProvider.notifier).updateNumberOfPeople(3);
      container.read(bookingViewModelProvider.notifier).reset();

      final state = container.read(bookingViewModelProvider);
      expect(state.customerName, isEmpty);
      expect(state.numberOfPeople, 1);
      expect(state.travelDate, isNull);
    });
  });
}
