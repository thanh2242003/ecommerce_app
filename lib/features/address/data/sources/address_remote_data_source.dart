import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/address/data/models/address_model.dart';
import 'package:http/http.dart' as http;

class AddressRemoteDataSource {
  AddressRemoteDataSource({required this.tokenStorage});

  final TokenStorage tokenStorage;

  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.getAccessToken();
    final userId = await tokenStorage.getUserId();

    if (token == null || token.isEmpty) {
      throw Exception('Unauthenticated: Access token not found');
    }
    if (userId == null || userId.isEmpty) {
      throw Exception('Unauthenticated: User id not found');
    }

    return {
      'Content-Type': 'application/json',
      'x-client-id': userId,
      'authorization': token,
    };
  }

  Future<AddressModel> createAddress({
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/address'),
      headers: await _headers(),
      body: jsonEncode({
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'address': address,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractAddressMap(body);
      if (data != null) {
        return AddressModel.fromJson(data);
      }

      throw Exception(
        'Create address succeeded but response has no address payload',
      );
    }

    String message = 'Failed to create address';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        message = (body['message'] ?? body['error'] ?? message).toString();
      }
    } catch (_) {
      message = '$message: ${response.body}';
    }

    throw Exception('$message (status: ${response.statusCode})');
  }

  Future<List<AddressModel>> getAddresses() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/address'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final dynamic metadata = body is Map<String, dynamic>
          ? body['metadata']
          : null;

      if (metadata is List) {
        return metadata
            .whereType<Map<String, dynamic>>()
            .map(AddressModel.fromJson)
            .toList();
      }

      return const <AddressModel>[];
    }

    throw Exception('Failed to load addresses: ${response.body}');
  }

  Future<AddressModel?> getDefaultAddress() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/address/default'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractAddressMap(body);
      if (data != null) {
        return AddressModel.fromJson(data);
      }
      return null;
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception('Failed to load default address: ${response.body}');
  }

  Future<AddressModel> setDefaultAddress(String addressId) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/address/set-default/$addressId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractAddressMap(body);
      if (data != null) {
        return AddressModel.fromJson(data);
      }

      throw Exception(
        'Set default address succeeded but response has no address payload',
      );
    }

    throw Exception('Failed to set default address: ${response.body}');
  }

  Future<AddressModel> updateAddress({
    required String addressId,
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/address/$addressId'),
      headers: await _headers(),
      body: jsonEncode({
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractAddressMap(body);
      if (data != null) {
        return AddressModel.fromJson(data);
      }

      throw Exception(
        'Update address succeeded but response has no address payload',
      );
    }

    throw Exception('Failed to update address: ${response.body}');
  }

  Future<void> deleteAddress(String addressId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/address/$addressId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception('Failed to delete address: ${response.body}');
  }

  Map<String, dynamic>? _extractAddressMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic metadata = body['metadata'];
      if (metadata is Map<String, dynamic>) {
        return metadata;
      }
      return body;
    }
    return null;
  }
}
