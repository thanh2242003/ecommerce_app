
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/basic_app_bar.dart';
import '../../../product/presentation/pages/top_selling_screen.dart';
import '../bloc/categories_cubit.dart';
import '../bloc/categories_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(hideBack: false,),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shopByCategories(),
            SizedBox(height: 10),
            _categories(),
          ],
        ),
      ),
    );
  }
}

Widget _shopByCategories() {
  return Text('Shop by Categories', style: AppTextStyle.h2);
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
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //product list
                    builder: (_) => TopSellingScreen(),
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
                        image: DecorationImage(
                          //thay bang anh backend
                          image: AssetImage("assets/images/${state.categories[index].image}"),
                          fit: BoxFit.cover,
                        ),
                      ),
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
