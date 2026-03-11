import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/features/categories/data/models/category_model.dart';

// abstract class CategoriesRemoteDataSource{
//   Future<List<CategoryModel>> getCategories();
// }
//
// class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource{
//   final String baseUrl = "http:";
//   @override
//   Future<List<CategoryModel>> getCategories() async{
//     final response = await http.get(Uri.parse('$baseUrl/api/categories'));
//     if(response.statusCode == 200){
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((e) => CategoryModel.fromJson(e)).toList();
//     }else{
//       throw Exception('Failed to load categories');
//     }
//   }
// }

// chua ket noi backend
abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {

    await Future.delayed(const Duration(seconds: 1));

    return [
      CategoryModel(categoryId: "1", title: "Clothes", image: "shoe.jpg"),
      CategoryModel(categoryId: "2", title: "Toys", image: "shoe2.jpg"),
      CategoryModel(categoryId: "3", title: "Shoes", image: "shoes2.jpg"),
    ];
  }
}