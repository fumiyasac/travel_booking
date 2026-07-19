import '../../../core/config/graphql_config.dart';
import '../../models/travel_plan.dart';
import '../../models/booking.dart';
import '../../models/plan_filter.dart';

class TravelPlanRemoteDataSource {
  final GraphQLHttpClient _client;

  TravelPlanRemoteDataSource(this._client);

  static const _getPlansQuery = r'''
    query GetTravelPlans($filter: PlanFilterInput, $page: Int, $pageSize: Int) {
      travelPlans(filter: $filter, page: $page, pageSize: $pageSize) {
        plans {
          id title description destination country region
          latitude longitude price discountPrice effectivePrice
          durationDays maxParticipants currentBookings availableSpots
          category difficulty rating reviewCount isAvailable
          availableFrom availableTo language tags createdAt
          images { id url caption isPrimary displayOrder }
          highlights { id text }
        }
        totalCount hasNextPage currentPage totalPages
      }
    }
  ''';

  static const _getPlanQuery = r'''
    query GetTravelPlan($id: ID!) {
      travelPlan(id: $id) {
        id title description destination country region
        latitude longitude price discountPrice effectivePrice
        durationDays maxParticipants currentBookings availableSpots
        category difficulty rating reviewCount isAvailable
        availableFrom availableTo language meetingPoint
        cancellationPolicy minimumAge tags createdAt updatedAt
        images { id url caption isPrimary displayOrder }
        highlights { id text }
        itinerary {
          id dayNumber title description accommodation meals
          activities { id name startTime duration description location }
        }
        includedItems { id item }
        excludedItems { id item }
        reviews { id reviewerName rating comment travelDate createdAt }
      }
    }
  ''';

  static const _createBookingMutation = r'''
    mutation CreateBooking($input: CreateBookingInput!) {
      createBooking(input: $input) {
        success message
        booking {
          id planId customerName customerEmail customerPhone
          numberOfPeople travelDate specialRequests totalPrice
          status paymentMethod createdAt updatedAt
        }
      }
    }
  ''';

  static const _cancelBookingMutation = r'''
    mutation CancelBooking($id: ID!) {
      cancelBooking(id: $id) {
        success message
        booking { id status updatedAt }
      }
    }
  ''';

  static const _getBookingsQuery = r'''
    query GetBookings($customerEmail: String) {
      bookings(customerEmail: $customerEmail) {
        id planId customerName customerEmail customerPhone
        numberOfPeople travelDate specialRequests totalPrice
        status paymentMethod createdAt updatedAt
        plan {
          id title destination
          images { id url isPrimary displayOrder }
        }
      }
    }
  ''';

  Future<(List<TravelPlan>, int, bool, int)> getTravelPlans({
    PlanFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    final data = await _client.query(
      document: _getPlansQuery,
      variables: {
        'filter': filter?.toGraphQLVariables(),
        'page': page,
        'pageSize': pageSize,
      },
    );

    final result = data['travelPlans'] as Map<String, dynamic>?;
    if (result == null) throw Exception('データの取得に失敗しました');

    final plans = (result['plans'] as List<dynamic>)
        .map((p) => TravelPlan.fromJson(p as Map<String, dynamic>))
        .toList();

    return (
      plans,
      result['totalCount'] as int,
      result['hasNextPage'] as bool,
      result['totalPages'] as int,
    );
  }

  Future<TravelPlan> getTravelPlan(String id) async {
    final data = await _client.query(
      document: _getPlanQuery,
      variables: {'id': id},
    );

    final result = data['travelPlan'] as Map<String, dynamic>?;
    if (result == null) throw Exception('プランが見つかりません');

    return TravelPlan.fromJson(result);
  }

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
    final data = await _client.mutate(
      document: _createBookingMutation,
      variables: {
        'input': {
          'planId': planId,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'customerPhone': customerPhone,
          'numberOfPeople': numberOfPeople,
          'travelDate': travelDate.toIso8601String(),
          if (specialRequests != null && specialRequests.isNotEmpty)
            'specialRequests': specialRequests,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        },
      },
    );

    final result = data['createBooking'] as Map<String, dynamic>?;
    if (result == null) throw Exception('予約処理に失敗しました');

    final success = result['success'] as bool;
    if (!success) {
      throw Exception(result['message'] as String? ?? '予約に失敗しました');
    }

    return Booking.fromJson(result['booking'] as Map<String, dynamic>);
  }

  Future<List<Booking>> fetchBookings(String customerEmail) async {
    final data = await _client.query(
      document: _getBookingsQuery,
      variables: {'customerEmail': customerEmail},
    );

    final list = data['bookings'] as List<dynamic>?;
    if (list == null) throw Exception('予約履歴の取得に失敗しました');

    return list
        .map((b) => Booking.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    final data = await _client.mutate(
      document: _cancelBookingMutation,
      variables: {'id': bookingId},
    );

    final result = data['cancelBooking'] as Map<String, dynamic>?;
    final success = result?['success'] as bool? ?? false;
    if (!success) {
      throw Exception(result?['message'] as String? ?? 'キャンセルに失敗しました');
    }
  }
}
