import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/basic_app_bar.dart';
import '../../domain/entities/product.dart';
import '../product_detail/bloc/product_color_selection_cubit.dart';
import '../product_detail/bloc/product_quantity_cubit.dart';
import '../product_detail/bloc/product_size_selection_cubit.dart';
import '../product_detail/widgets/add_to_cart.dart';
import '../product_detail/widgets/favorite_button.dart';
import '../product_detail/widgets/product_description.dart';
import '../product_detail/widgets/product_images.dart';
import '../product_detail/widgets/product_price.dart';
import '../product_detail/widgets/product_quantity.dart';
import '../product_detail/widgets/product_ratings.dart';
import '../product_detail/widgets/product_reviews.dart';
import '../product_detail/widgets/product_title.dart';
import '../product_detail/widgets/selected_color.dart';
import '../product_detail/widgets/selected_size.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductEntity productEntity;
  const ProductDetailScreen({required this.productEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductQuantityCubit()),
        BlocProvider(create: (context) => ProductColorSelectionCubit()),
        BlocProvider(create: (context) => ProductSizeSelectionCubit()),
        //BlocProvider(create: (context) => ButtonStateCubit()),
        //BlocProvider(create: (context) => FavoriteIconCubit()..isFavorite(productEntity.productId))
      ],
      child: Scaffold(
        appBar: BasicAppbar(showBack: true, action: FavoriteButton()),
        bottomNavigationBar: AddToCart(productEntity: productEntity),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImages(productEntity: productEntity),
              const SizedBox(height: 10),
              ProductTitle(productEntity: productEntity),
              const SizedBox(height: 10),
              ProductPrice(productEntity: productEntity),
              const SizedBox(height: 10),
              SelectedSize(productEntity: productEntity),
              const SizedBox(height: 15),
              SelectedColor(productEntity: productEntity),
              const SizedBox(height: 15),
              ProductQuantity(productEntity: productEntity),
              const SizedBox(height: 20),
              ProductRatings(productEntity: productEntity),
              const SizedBox(height: 20),
              ProductReviews(productEntity: productEntity),
              const SizedBox(height: 20),
              ProductDescription(productEntity: productEntity),
            ],
          ),
        ),
      ),
    );
  }
}
