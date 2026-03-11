import '../../data/datasources/categories_remote_data_source.dart';
import '../entities/category.dart';
import 'categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await remoteDataSource.getCategories();
  }
}
