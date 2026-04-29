import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/home_cubit.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/home_state.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/recommendation_cubit.dart';
import 'package:ecommerce_app/features/home/presentation/pages/home_tab_products_screen.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeProductTabs extends StatelessWidget {
  const HomeProductTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Sản phẩm nổi bật',
            //   style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black),
            // ),
            // const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primaryColor,
                labelStyle: AppTextStyle.buttonSmall,
                tabs: const [
                  Tab(text: 'Bán chạy'),
                  Tab(text: 'Hàng mới'),
                  Tab(text: 'Đề xuất'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 720,
              child: TabBarView(
                children: [
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is HomeError) {
                        return Center(child: Text(state.message));
                      }

                      final loaded = state as HomeLoaded;
                      return _TabContent(
                        title: 'Bán chạy',
                        products: loaded.topSellingProducts,
                        onSeeMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomeTabProductsScreen(
                                title: 'Bán chạy',
                                products: loaded.topSellingProducts,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is HomeError) {
                        return Center(child: Text(state.message));
                      }

                      final loaded = state as HomeLoaded;
                      return _TabContent(
                        title: 'Hàng mới',
                        products: loaded.latestProducts,
                        onSeeMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomeTabProductsScreen(
                                title: 'Hàng mới',
                                products: loaded.latestProducts,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  BlocBuilder<RecommendationCubit, RecommendationState>(
                    builder: (context, state) {
                      if (state is RecommendationLoading ||
                          state is RecommendationInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is RecommendationError) {
                        return const Center(child: Text('Không có đề xuất'));
                      }

                      if (state is RecommendationLoaded) {
                        return _TabContent(
                          title: 'Đề xuất',
                          products: state.products,
                          onSeeMore: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeTabProductsScreen(
                                  title: 'Đề xuất',
                                  products: state.products,
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.title,
    required this.products,
    required this.onSeeMore,
  });

  final String title;
  final List<ProductEntity> products;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('Không có sản phẩm'));
    }

    final visibleProducts = products.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black),
            ),
            TextButton(onPressed: onSeeMore, child: const Text('Xem thêm')),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: visibleProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) {
            return ProductCard(productEntity: visibleProducts[index]);
          },
        ),
      ],
    );
  }
}
