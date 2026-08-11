import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/error/app_error.dart';
import '../../data/models/booking.dart';
import '../../data/models/travel_plan.dart';
import 'plan_list_viewmodel.dart';

part 'booking_viewmodel.g.dart';

// Run: dart run build_runner build --delete-conflicting-outputs

class BookingFormState {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final int numberOfPeople;
  final DateTime? travelDate;
  final String specialRequests;
  final bool isSubmitting;
  final AppError? error;
  final Booking? completedBooking;
  final Map<String, String> validationErrors;

  const BookingFormState({
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    this.numberOfPeople = 1,
    this.travelDate,
    this.specialRequests = '',
    this.isSubmitting = false,
    this.error,
    this.completedBooking,
    this.validationErrors = const {},
  });

  bool get isValid =>
      customerName.trim().isNotEmpty &&
      customerEmail.trim().isNotEmpty &&
      customerEmail.contains('@') &&
      customerPhone.trim().isNotEmpty &&
      numberOfPeople >= 1 &&
      travelDate != null;

  double calculateTotal(TravelPlan plan) {
    return plan.effectivePrice * numberOfPeople;
  }

  BookingFormState copyWith({
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    int? numberOfPeople,
    DateTime? travelDate,
    String? specialRequests,
    bool? isSubmitting,
    AppError? error,
    Booking? completedBooking,
    Map<String, String>? validationErrors,
    bool clearError = false,
    bool clearBooking = false,
  }) {
    return BookingFormState(
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      travelDate: travelDate ?? this.travelDate,
      specialRequests: specialRequests ?? this.specialRequests,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      completedBooking:
          clearBooking ? null : (completedBooking ?? this.completedBooking),
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

@riverpod
class BookingViewModel extends _$BookingViewModel {
  @override
  BookingFormState build() {
    return const BookingFormState();
  }

  void updateCustomerName(String value) {
    state = state.copyWith(
      customerName: value,
      validationErrors: _removeError('customerName'),
    );
  }

  void updateCustomerEmail(String value) {
    state = state.copyWith(
      customerEmail: value,
      validationErrors: _removeError('customerEmail'),
    );
  }

  void updateCustomerPhone(String value) {
    state = state.copyWith(
      customerPhone: value,
      validationErrors: _removeError('customerPhone'),
    );
  }

  void updateNumberOfPeople(int value) {
    if (value < 1) return;
    state = state.copyWith(
      numberOfPeople: value,
      validationErrors: _removeError('numberOfPeople'),
    );
  }

  void updateTravelDate(DateTime value) {
    state = state.copyWith(
      travelDate: value,
      validationErrors: _removeError('travelDate'),
    );
  }

  void updateSpecialRequests(String value) {
    state = state.copyWith(specialRequests: value);
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.customerName.trim().isEmpty) {
      errors['customerName'] = 'お名前を入力してください';
    }
    if (state.customerEmail.trim().isEmpty) {
      errors['customerEmail'] = 'メールアドレスを入力してください';
    } else if (!state.customerEmail.contains('@')) {
      errors['customerEmail'] = '有効なメールアドレスを入力してください';
    }
    if (state.customerPhone.trim().isEmpty) {
      errors['customerPhone'] = '電話番号を入力してください';
    }
    if (state.numberOfPeople < 1) {
      errors['numberOfPeople'] = '参加人数は1名以上を指定してください';
    }
    if (state.travelDate == null) {
      errors['travelDate'] = '旅行日を選択してください';
    } else if (state.travelDate!.isBefore(DateTime.now())) {
      errors['travelDate'] = '旅行日は本日以降の日付を選択してください';
    }
    return errors;
  }

  Map<String, String> _removeError(String key) {
    final errors = Map<String, String>.from(state.validationErrors);
    errors.remove(key);
    return errors;
  }

  Future<bool> submitBooking(String planId, int availableSpots) async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(validationErrors: errors);
      return false;
    }

    if (state.numberOfPeople > availableSpots) {
      state = state.copyWith(
        error: ValidationError('空き枠が不足しています。残り$availableSpots名まで予約可能です'),
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(travelPlanRepositoryProvider);
      final booking = await repo.createBooking(
        planId: planId,
        customerName: state.customerName.trim(),
        customerEmail: state.customerEmail.trim(),
        customerPhone: state.customerPhone.trim(),
        numberOfPeople: state.numberOfPeople,
        travelDate: state.travelDate!,
        specialRequests: state.specialRequests.trim().isEmpty
            ? null
            : state.specialRequests.trim(),
      );

      state = state.copyWith(
        isSubmitting: false,
        completedBooking: booking,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e is AppError ? e : UnknownError(e.toString()),
      );
      return false;
    }
  }

  void reset() {
    state = const BookingFormState();
  }
}
