import 'package:ecommerce_app/features/categories/domain/entities/category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesInitial());

  Future<void> loadCategories() async {}
}
