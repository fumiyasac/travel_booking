import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/error/app_error.dart';
import '../../data/models/booking.dart';
import 'plan_list_viewmodel.dart';

part 'booking_history_viewmodel.g.dart';

// Run: dart run build_runner build --delete-conflicting-outputs

class BookingHistoryState {
  final List<Booking> bookings;
  final bool isLoading;
  final AppError? error;

  const BookingHistoryState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingHistoryState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    AppError? error,
    bool clearError = false,
  }) {
    return BookingHistoryState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class BookingHistoryViewModel extends _$BookingHistoryViewModel {
  @override
  BookingHistoryState build() {
    return const BookingHistoryState();
  }

  Future<void> loadBookings(String customerEmail) async {
    if (state.isLoading) return;
    if (customerEmail.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: const ValidationError('メールアドレスが指定されていません'),
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(travelPlanRepositoryProvider);
      final bookings = await repo.fetchBookings(customerEmail.trim());

      state = state.copyWith(
        bookings: bookings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppError ? e : UnknownError(e.toString()),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
