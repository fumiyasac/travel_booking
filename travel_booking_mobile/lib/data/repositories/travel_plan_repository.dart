import '../models/travel_plan.dart';
import '../models/booking.dart';
import '../models/plan_filter.dart';

abstract class TravelPlanRepository {
  Future<(List<TravelPlan>, int, bool, int)> getPlans({
    PlanFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<TravelPlan> getPlan(String id);

  Future<Booking> createBooking({
    required String planId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required int numberOfPeople,
    required DateTime travelDate,
    String? specialRequests,
    String? paymentMethod,
  });

  Future<void> cancelBooking(String bookingId);
}
