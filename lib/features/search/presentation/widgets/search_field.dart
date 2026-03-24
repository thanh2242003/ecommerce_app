import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_cubit.dart';

class SearchField extends StatelessWidget {
  SearchField({super.key});

  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: textEditingController,
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<SearchCubit>().loadCategories();
          } else {
            context.read<SearchCubit>().searchProducts(value);
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            //borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search),
          hintText: 'search',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
