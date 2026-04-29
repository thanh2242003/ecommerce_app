import 'dart:convert';

import 'package:ecommerce_app/core/config/api_config.dart';
import 'package:ecommerce_app/features/categories/data/models/category_model.dart';
import 'package:http/http.dart' as http;

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  static const String _baseUrl = '${ApiConfig.baseUrl}/category';

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final metadata = decoded['metadata'] as List<dynamic>? ?? [];

      return metadata
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList()
          .reversed
          .toList();
    }

    throw Exception('Failed to load categories: ${response.body}');
  }
}
