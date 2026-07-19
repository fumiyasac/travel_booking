import '../datasources/remote/travel_plan_remote_datasource.dart';
import '../models/travel_plan.dart';
import '../models/booking.dart';
import '../models/plan_filter.dart';
import 'travel_plan_repository.dart';

class TravelPlanRepositoryImpl implements TravelPlanRepository {
  final TravelPlanRemoteDataSource _remoteDataSource;

  const TravelPlanRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<TravelPlan>, int, bool, int)> getPlans({
    PlanFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) {
    return _remoteDataSource.getTravelPlans(
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<TravelPlan> getPlan(String id) {
    return _remoteDataSource.getTravelPlan(id);
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
  }) {
    return _remoteDataSource.createBooking(
      planId: planId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      numberOfPeople: numberOfPeople,
      travelDate: travelDate,
      specialRequests: specialRequests,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return _remoteDataSource.cancelBooking(bookingId);
  }

  @override
  Future<List<Booking>> fetchBookings(String customerEmail) {
    return _remoteDataSource.fetchBookings(customerEmail);
  }
}
