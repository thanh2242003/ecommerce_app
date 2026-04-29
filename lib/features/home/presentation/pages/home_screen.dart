import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/basic_app_bar.dart';
import '../bloc/home_cubit.dart';
import '../bloc/recommendation_cubit.dart';
import '../widgets/categories.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_product_tabs.dart';
import '../widgets/home_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  static const List<String> _bannerImages = [
    'assets/images/intro.png',
    'assets/images/intro1.png',
    'assets/images/intro2.png',
  ];

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
      appBar: BasicAppbar(
        titleText: 'Trang chủ',
        showBack: false,
        titleStyle: AppTextStyle.h2.copyWith(color: Colors.black87),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSearchBar(),
          const SizedBox(height: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeBannerCarousel(images: _bannerImages),
                    SizedBox(height: 20),
                    Categories(),
                    SizedBox(height: 20),
                    HomeProductTabs(),
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
