import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductEntity>> getTopSellingProducts() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      ProductEntity(
        productId: '1',
        title: 'Nike Air Max',
        price: 120,
        discountedPrice: 90,
        images: ['shoe.jpg'],
        salesNumber: 100,
        categoryId: '',
        colors: [],
        gender: 1,
        sizes: [],
      ),
      ProductEntity(
        productId: '2',
        title: 'Adidas Ultraboost',
        price: 150,
        discountedPrice: 0,
        images: ['shoe2.jpg'],
        salesNumber: 200,
        categoryId: '',
        colors: [],
        gender: 1,
        sizes: [],
      ),
    ];
  }

  @override
  Future<List<ProductEntity>> getProductsDetail(String productId) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      ProductEntity(
        productId: productId,
        title: 'Nike Air Max',
        price: 120,
        discountedPrice: 90,
        images: ['shoe.jpg'],
        salesNumber: 100,
        categoryId: '',
        colors: [],
        gender: 1,
        sizes: [],
      ),
      ProductEntity(
        productId: '2',
        title: 'Adidas Ultraboost',
        price: 150,
        discountedPrice: 0,
        images: ['shoe2.jpg'],
        salesNumber: 200,
        categoryId: '',
        colors: [],
        gender: 1,
        sizes: [],
      ),
    ];
  }
}
