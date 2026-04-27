import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_cubit.dart';
import '../bloc/recommendation_cubit.dart';

import '../widgets/categories.dart';
import '../widgets/header.dart';
import '../widgets/new_product.dart';
import '../widgets/recommendations.dart';
import '../widgets/top_selling.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<HomeCubit>().loadHomeIfNeeded(forceRefresh: true),
      context.read<RecommendationCubit>().loadRecommendationsIfNeeded(
        forceRefresh: true,
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().loadHomeIfNeeded();
      context.read<RecommendationCubit>().loadRecommendationsIfNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                key: const PageStorageKey<String>('home_scroll_view'),
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: const Column(
                  children: [
                    Categories(),
                    TopSelling(),
                    NewProduct(),
                    Recommendations(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
