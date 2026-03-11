import 'package:ecommerce_app/features/product/presentation/pages/top_selling_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../product/presentation/bloc/product_cubit.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/domain/entities/product.dart';

class TopSelling extends StatelessWidget {
  const TopSelling({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductLoaded) {
          return Column(
            children: [
              _seeAll(context),
              SizedBox(height: 20),
              _products(context,state.products),
            ],
          );
        }
        return const SizedBox();
        // return Column(
        //   children: [
        //     _seeAll(context),
        //     SizedBox(height: 20),
        //     _categories(state.categories),
        //   ],
        // );
      },
    );
  }
}

Widget _seeAll(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Top Selling",
        style: AppTextStyle.withColor(AppTextStyle.bodyLarge, Colors.black),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TopSellingScreen()),
          );
        },
        child: Text(
          "See All",
          style: AppTextStyle.withColor(AppTextStyle.bodySmall, Colors.blue),
        ),
      ),
    ],
  );
}

Widget _products(BuildContext context,List<ProductEntity> products) {
  return SizedBox(
    height: 300,
    child: ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index],);
      },
      separatorBuilder: (context, index) => const SizedBox(width: 15),
      itemCount: products.length,
    ),
  );
}
