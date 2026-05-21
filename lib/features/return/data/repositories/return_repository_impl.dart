import 'package:ecommerce_app/features/return/data/models/return_request.dart';
import 'package:ecommerce_app/features/return/data/models/return_response.dart';
import 'package:ecommerce_app/features/return/data/sources/return_api_service.dart';
import 'package:ecommerce_app/features/return/domain/repositories/return_repository.dart';

class ReturnRepositoryImpl implements ReturnRepository {
  ReturnRepositoryImpl({required this.apiService});

  final ReturnApiService apiService;

  @override
  Future<ReturnResponse> createReturn(ReturnRequest request) async {
    return apiService.createReturn(request);
  }

  @override
  Future<List<ReturnResponse>> getReturns({String? status}) async {
    return apiService.getReturns(status: status);
  }

  @override
  Future<ReturnResponse> getReturnDetail(String id) async {
    return apiService.getReturnDetail(id);
  }

  @override
  Future<ReturnResponse> markReturned(
    String id, {
    String? trackingNumber,
  }) async {
    return apiService.markReturned(id, trackingNumber: trackingNumber);
  }

  @override
  Future<ReturnResponse> cancelReturn(String id) async {
    return apiService.cancelReturn(id);
  }
}
