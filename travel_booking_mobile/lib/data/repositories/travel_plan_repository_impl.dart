import 'dart:io';

import '../../core/error/app_error.dart';
import '../datasources/remote/travel_plan_remote_datasource.dart';
import '../models/booking.dart';
import '../models/plan_filter.dart';
import '../models/travel_plan.dart';
import 'travel_plan_repository.dart';

class TravelPlanRepositoryImpl implements TravelPlanRepository {
  final TravelPlanRemoteDataSource _remoteDataSource;

  const TravelPlanRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<TravelPlan>, int, bool, int)> getPlans({
    PlanFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _remoteDataSource.getTravelPlans(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
    } on SocketException {
      throw const NetworkError();
    } on HttpException catch (e) {
      throw NetworkError(e.message.isNotEmpty ? e.message : '通信エラーが発生しました');
    } on AppError {
      rethrow;
    } catch (e) {
      throw GraphQLError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<TravelPlan> getPlan(String id) async {
    try {
      return await _remoteDataSource.getTravelPlan(id);
    } on SocketException {
      throw const NetworkError();
    } on HttpException catch (e) {
      throw NetworkError(e.message.isNotEmpty ? e.message : '通信エラーが発生しました');
    } on AppError {
      rethrow;
    } catch (e) {
      throw GraphQLError(e.toString().replaceAll('Exception: ', ''));
    }
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
    try {
      return await _remoteDataSource.createBooking(
        planId: planId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        numberOfPeople: numberOfPeople,
        travelDate: travelDate,
        specialRequests: specialRequests,
        paymentMethod: paymentMethod,
      );
    } on SocketException {
      throw const NetworkError();
    } on HttpException catch (e) {
      throw NetworkError(e.message.isNotEmpty ? e.message : '通信エラーが発生しました');
    } on AppError {
      rethrow;
    } catch (e) {
      throw GraphQLError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      return await _remoteDataSource.cancelBooking(bookingId);
    } on SocketException {
      throw const NetworkError();
    } on HttpException catch (e) {
      throw NetworkError(e.message.isNotEmpty ? e.message : '通信エラーが発生しました');
    } on AppError {
      rethrow;
    } catch (e) {
      throw GraphQLError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<List<Booking>> fetchBookings(String customerEmail) async {
    try {
      return await _remoteDataSource.fetchBookings(customerEmail);
    } on SocketException {
      throw const NetworkError();
    } on HttpException catch (e) {
      throw NetworkError(e.message.isNotEmpty ? e.message : '通信エラーが発生しました');
    } on AppError {
      rethrow;
    } catch (e) {
      throw GraphQLError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
