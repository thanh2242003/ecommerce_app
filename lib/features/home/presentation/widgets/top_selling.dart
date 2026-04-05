import 'package:ecommerce_app/features/product/presentation/pages/top_selling_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../product/presentation/bloc/product_cubit.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/domain/entities/product.dart';

class TopSelling extends StatefulWidget {
  const TopSelling({super.key});

  @override
  State<TopSelling> createState() => _TopSellingState();
}

class _TopSellingState extends State<TopSelling> {

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
              _products(context,state.products.take(3).toList()),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}

Widget _seeAll(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Bán chạy",
          style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TopSellingScreen()),
            );
          },
          child: Text(
            "Xem thêm",
            style: AppTextStyle.withColor(AppTextStyle.bodySmall, Colors.blue),
          ),
        ),
      ],
    ),
  );
}
Widget _products(BuildContext context, List<ProductEntity> products) {
  // Nếu không có sản phẩm nào, có thể hiện thông báo hoặc ẩn đi
  if (products.isEmpty) {
    return const SizedBox(
      height: 200,
      child: Center(child: Text("No products available")),
    );
  }

  return SizedBox(
    height: 300, // Đảm bảo chiều cao này đủ chứa ProductCard
    child: ListView.separated(
      // Thêm padding để căn chỉnh đều với tiêu đề "Top Selling"
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        // Đảm bảo ProductCard bên trong có chiều rộng (width) cố định
        return ProductCard(
          productEntity: products[index],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 15),
      itemCount: products.length,
    ),
  );
}

// Widget _products(BuildContext context,List<ProductEntity> products) {
//   return SizedBox(
//     height: 300,
//     child: ListView.separated(
//       shrinkWrap: true,
//       scrollDirection: Axis.horizontal,
//       itemBuilder: (context, index) {
//         return ProductCard(productEntity: products[index],);
//       },
//       separatorBuilder: (context, index) => const SizedBox(width: 15),
//       itemCount: products.length,
//     ),
//   );
// }
