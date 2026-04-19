import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_cubit.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final keyword = value.trim();
    if (keyword.isEmpty) {
      context.read<SearchCubit>().loadCategories();
      return;
    }
    context.read<SearchCubit>().searchProducts(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: textEditingController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<SearchCubit>().loadCategories();
          }
        },
        onSubmitted: _submitSearch,
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
