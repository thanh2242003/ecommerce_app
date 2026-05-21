import '../../data/models/return_request.dart';
import '../../data/models/return_response.dart';

abstract class ReturnRepository {
  Future<ReturnResponse> createReturn(ReturnRequest request);
  Future<List<ReturnResponse>> getReturns({String? status});
  Future<ReturnResponse> getReturnDetail(String id);
  Future<ReturnResponse> markReturned(String id, {String? trackingNumber});
  Future<ReturnResponse> cancelReturn(String id);
}
