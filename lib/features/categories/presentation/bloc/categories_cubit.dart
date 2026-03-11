import 'package:ecommerce_app/features/categories/domain/entities/category.dart';
import 'package:ecommerce_app/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase getCategories;
  CategoriesCubit(this.getCategories) : super(CategoriesInitial()){
    loadCategories();
  }

  Future<void> loadCategories() async {
    try{
      emit(CategoriesLoading());
      final categories = await getCategories();
      emit(CategoriesLoaded(categories));
    }catch(e){
      emit(CategoriesError(e.toString()));
    }
  }
}
