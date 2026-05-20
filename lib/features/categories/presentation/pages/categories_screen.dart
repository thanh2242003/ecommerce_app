import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/basic_app_bar.dart';
import '../../../search/presentation/pages/search_screen.dart';
import '../bloc/categories_cubit.dart';
import '../bloc/categories_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(showBack: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_shopByCategories(), SizedBox(height: 10), _categories()],
        ),
      ),
    );
  }
}

Widget _shopByCategories() {
  return Text('Danh mục sản phẩm', style: AppTextStyle.h2);
}

Widget _categories() {
  return BlocBuilder<CategoriesCubit, CategoriesState>(
    builder: (context, state) {
      if (state is CategoriesLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is CategoriesLoaded) {
        return ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final image = state.categories[index].image;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(
                      initialCategoryId: state.categories[index].categoryId,
                      initialCategoryTitle: state.categories[index].title,
                    ),
                  ),
                );
              },
              child: Container(
                height: 70,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0x12342f3f),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        image: image.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: image.isEmpty
                          ? const Icon(
                              Icons.category_outlined,
                              color: Colors.black54,
                            )
                          : null,
                    ),
                    SizedBox(width: 15),
                    Text(
                      state.categories[index].title,
                      style: AppTextStyle.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: state.categories.length,
        );
      }
      return SizedBox();
    },
  );
}
