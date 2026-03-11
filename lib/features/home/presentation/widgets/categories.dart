import 'package:ecommerce_app/features/categories/presentation/pages/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/bloc/categories_cubit.dart';
import '../../../categories/presentation/bloc/categories_state.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CategoriesLoaded) {
          return Column(
            children: [
              _seeAll(context),
              SizedBox(height: 20),
              _categories(context,state.categories),
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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Categories",
          style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoriesScreen()),
            );
          },
          child: Text(
            "See All",
            style: AppTextStyle.withColor(AppTextStyle.bodySmall, Colors.blue),
          ),
        ),
      ],
    ),
  );
}

Widget _categories(BuildContext context,List<CategoryEntity> categories) {
  return SizedBox(
    height: 100,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  //sua thanh anh trong backend
                  image: NetworkImage(categories[index].image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              categories[index].title,
              style: AppTextStyle.withColor(
                AppTextStyle.bodySmall,
                Colors.black,
              ),
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 15),
      itemCount: categories.length,
    ),
  );
}
