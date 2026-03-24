import 'package:ecommerce_app/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:ecommerce_app/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/basic_app_bar.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/data/repositories/product_repository_impl.dart';
import '../../../product/presentation/pages/top_selling_screen.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import '../widgets/search_field.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(
        productRepository: ProductRepositoryImpl(),
        categoryRepository: CategoriesRepositoryImpl(
          CategoriesRemoteDataSourceImpl(),
        ),
      )..loadCategories(),
      child: Scaffold(
        appBar: BasicAppbar(
          height: 80,
          title: SearchField(),
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SearchCategoriesLoaded) {
              return _categories(state.categories);
            }
            if (state is SearchProductsLoaded) {
              return state.products.isEmpty
                  ? _notFound()
                  : _products(state.products);
            }
            if (state is SearchError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _categories(List<CategoryEntity> categories) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TopSellingScreen(),
              ),
            );
          },
          child: Container(
            height: 70,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: AssetImage("assets/images/${categories[index].image}"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  categories[index].title,
                  style: AppTextStyle.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: categories.length,
    );
  }

  Widget _products(List<ProductEntity> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(productEntity: product);
      },
    );
  }

  Widget _notFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("No products found", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}