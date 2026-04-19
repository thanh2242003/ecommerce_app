import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/home/data/repositories/recommendation_repository_impl.dart';
import 'package:ecommerce_app/features/home/data/sources/recommendation_api_service.dart';
import 'package:ecommerce_app/features/home/domain/usecases/get_recommendations_usecase.dart';
import 'package:ecommerce_app/features/home/presentation/bloc/recommendation_cubit.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationCubit, RecommendationState>(
      builder: (context, state) {
        if (state is RecommendationLoading || state is RecommendationInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is RecommendationError) {
          return const SizedBox.shrink();
        }

        if (state is RecommendationLoaded) {
          if (state.products.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              _sectionHeader(),
              const SizedBox(height: 20),
              _products(context, state.products.take(6).toList()),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _sectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Đề xuất',
            style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black),
          ),
          Text(
            'Xem thêm',
            style: AppTextStyle.withColor(AppTextStyle.bodySmall, Colors.blue),
          ),
        ],
      ),
    );
  }

  // Widget _products(List<ProductEntity> products) {
  //   return SizedBox(
  //     height: 300,
  //     child: ListView.separated(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (context, index) {
  //         return ProductCard(productEntity: products[index]);
  //       },
  //       separatorBuilder: (context, index) => const SizedBox(width: 10),
  //       itemCount: products.length,
  //     ),
  //   );
  // }
  Widget _products(BuildContext context, List<ProductEntity> products) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return ProductCard(productEntity: products[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: products.length,
      ),
    );
  }

  static BlocProvider<RecommendationCubit> provider({required Widget child}) {
    return BlocProvider(
      create: (_) => RecommendationCubit(
        getRecommendationsUseCase: GetRecommendationsUseCase(
          repository: RecommendationRepositoryImpl(
            apiService: RecommendationApiService(tokenStorage: TokenStorage()),
          ),
        ),
      )..loadRecommendations(),
      child: child,
    );
  }
}
