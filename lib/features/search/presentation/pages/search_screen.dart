import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:ecommerce_app/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/basic_app_bar.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../product/data/sources/product_api_service.dart';
import '../../../product/data/repositories/product_repository_impl.dart';
import '../../../product/presentation/widgets/product_gridview.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import '../widgets/search_field.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialCategoryTitle;

  const SearchScreen({
    super.key,
    this.initialCategoryId,
    this.initialCategoryTitle,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

const List<ProductAgeRangeOption> _fallbackAgeRanges = [
  ProductAgeRangeOption(value: '0-1', label: '0-1'),
  ProductAgeRangeOption(value: '1-3', label: '1-3'),
  ProductAgeRangeOption(value: '3-6', label: '3-6'),
  ProductAgeRangeOption(value: '6+', label: '6+'),
];

class _SearchScreenState extends State<SearchScreen> {
  late final SearchCubit _searchCubit;
  late final TextEditingController _searchController;
  late final GetCategoriesUseCase _getCategoriesUseCase;

  List<CategoryEntity> _categories = [];
  List<ProductAgeRangeOption> _ageRanges = const [];
  bool _isCategoriesLoading = false;

  String? _selectedCategoryId;
  String? _selectedCategoryTitle;
  int? _selectedMinPrice;
  int? _selectedMaxPrice;
  int? _selectedGender;
  String? _selectedAgeRange;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _searchCubit = SearchCubit(productRepository: ProductRepositoryImpl());
    _searchController = TextEditingController();
    _getCategoriesUseCase = GetCategoriesUseCase(
      CategoriesRepositoryImpl(CategoriesRemoteDataSourceImpl()),
    );

    _selectedCategoryId = widget.initialCategoryId;
    _selectedCategoryTitle = widget.initialCategoryTitle;

    _loadCategories();
    _loadAgeRanges();

    if (_hasActiveFilters) {
      Future.microtask(_applyFilters);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchCubit.close();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedCategoryId != null ||
        _selectedMinPrice != null ||
        _selectedMaxPrice != null ||
        _selectedGender != null ||
        _selectedAgeRange != null ||
        _selectedSort != null;
  }

  Future<void> _loadCategories() async {
    setState(() => _isCategoriesLoading = true);
    try {
      final categories = await _getCategoriesUseCase();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = [];
        _isCategoriesLoading = false;
      });
    }
  }

  Future<void> _loadAgeRanges() async {
    try {
      final ageRanges = await ProductApiService.getAgeRanges();
      if (!mounted) return;
      setState(() {
        _ageRanges = ageRanges.isEmpty ? _fallbackAgeRanges : ageRanges;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _ageRanges = _fallbackAgeRanges);
    }
  }

  Future<void> _applyFilters() async {
    await _searchCubit.searchProducts(
      keyword: _searchController.text,
      categoryId: _selectedCategoryId,
      minPrice: _selectedMinPrice,
      maxPrice: _selectedMaxPrice,
      gender: _selectedGender,
      ageRange: _selectedAgeRange,
      sort: _selectedSort,
    );
  }

  Future<void> _handleSearch(String value) async {
    setState(() {
      _searchController.text = value;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });

    if (!_hasActiveFilters) {
      _searchCubit.resetResults();
      return;
    }

    await _applyFilters();
  }

  Future<void> _selectCategory(CategoryEntity category) async {
    setState(() {
      _selectedCategoryId = category.categoryId;
      _selectedCategoryTitle = category.title;
    });
    await _applyFilters();
  }

  Future<void> _clearCategory() async {
    setState(() {
      _selectedCategoryId = null;
      _selectedCategoryTitle = null;
    });
    await _applyFilters();
  }

  Future<void> _selectPriceRange(
    BuildContext sheetContext,
    int? minPrice,
    int? maxPrice,
  ) async {
    setState(() {
      _selectedMinPrice = minPrice;
      _selectedMaxPrice = maxPrice;
    });
    Navigator.pop(sheetContext);
    await _applyFilters();
  }

  Future<void> _selectGender(BuildContext sheetContext, int? gender) async {
    setState(() {
      _selectedGender = gender;
    });
    Navigator.pop(sheetContext);
    await _applyFilters();
  }

  Future<void> _selectAgeRange(
    BuildContext sheetContext,
    String? ageRange,
  ) async {
    setState(() {
      _selectedAgeRange = ageRange;
    });
    Navigator.pop(sheetContext);
    await _applyFilters();
  }

  Future<void> _selectSort(BuildContext sheetContext, String? sort) async {
    setState(() {
      _selectedSort = sort;
    });
    Navigator.pop(sheetContext);
    await _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchCubit,
      child: Scaffold(
        appBar: BasicAppbar(
          height: 80,
          titleWidget: SearchField(
            controller: _searchController,
            onSubmitted: _handleSearch,
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading ||
                      (state is SearchInitial && _hasActiveFilters)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SearchProductsLoaded) {
                    return state.products.isEmpty
                        ? _notFound()
                        : ProductGridView(products: state.products);
                  }

                  if (state is SearchError) {
                    return Center(child: Text(state.message));
                  }

                  return _buildCategoryBrowser();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: _selectedCategoryTitle ?? 'Danh mục',
                  selected: _selectedCategoryId != null,
                  onTap: _showCategorySelector,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _priceLabel(),
                  selected:
                      _selectedMinPrice != null || _selectedMaxPrice != null,
                  onTap: _showPriceSelector,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _genderLabel(),
                  selected: _selectedGender != null,
                  onTap: _showGenderSelector,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _ageRangeLabel(),
                  selected: _selectedAgeRange != null,
                  onTap: _showAgeRangeSelector,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _sortLabel(),
                  selected: _selectedSort != null,
                  onTap: _showSortSelector,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryColor : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.bodySmall.copyWith(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBrowser() {
    if (_isCategoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('Không có danh mục để hiển thị'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final image = category.image;
        return GestureDetector(
          onTap: () => _selectCategory(category),
          child: Container(
            height: 70,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedCategoryId == category.categoryId
                    ? AppColors.primaryColor
                    : Colors.transparent,
              ),
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
                const SizedBox(width: 15),
                Expanded(
                  child: Text(category.title, style: AppTextStyle.bodyLarge),
                ),
                const Icon(Icons.chevron_right, color: Colors.black45),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: _categories.length,
    );
  }

  String _priceLabel() {
    if (_selectedMinPrice == null && _selectedMaxPrice == null) {
      return 'Khoảng giá';
    }
    if (_selectedMinPrice != null && _selectedMaxPrice != null) {
      return '${AppNumberFormat.format(_selectedMinPrice!)} - ${AppNumberFormat.format(_selectedMaxPrice!)}';
    }
    if (_selectedMinPrice != null) {
      return 'Từ ${AppNumberFormat.format(_selectedMinPrice!)}';
    }
    return 'Đến ${AppNumberFormat.format(_selectedMaxPrice ?? 0)}';
  }

  String _genderLabel() {
    switch (_selectedGender) {
      case 1:
        return 'Nam';
      case 2:
        return 'Nữ';
      case 3:
        return 'Unisex';
      default:
        return 'Giới tính';
    }
  }

  String _ageRangeLabel() {
    if (_selectedAgeRange == null) {
      return 'Do tuoi';
    }

    return _ageRanges
        .firstWhere(
          (ageRange) => ageRange.value == _selectedAgeRange,
          orElse: () => ProductAgeRangeOption(
            value: _selectedAgeRange!,
            label: _selectedAgeRange!,
          ),
        )
        .label;
  }

  String _sortLabel() {
    switch (_selectedSort) {
      case 'newest':
        return 'Mới nhất';
      case 'price_asc':
        return 'Giá tăng';
      case 'price_desc':
        return 'Giá giảm';
      default:
        return 'Sắp xếp';
    }
  }

  Future<void> _showCategorySelector() async {
    if (_categories.isEmpty) {
      return;
    }

    final selectedCategory = await showModalBottomSheet<CategoryEntity>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.all_inclusive)),
                  title: const Text('Tất cả'),
                  trailing: _selectedCategoryId == null
                      ? const Icon(Icons.check, color: AppColors.primaryColor)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, null),
                );
              }

              final category = _categories[index - 1];
              final isSelected = category.categoryId == _selectedCategoryId;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: category.image.isNotEmpty
                      ? NetworkImage(category.image)
                      : null,
                  child: category.image.isEmpty
                      ? const Icon(Icons.category_outlined)
                      : null,
                ),
                title: Text(category.title),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primaryColor)
                    : null,
                onTap: () => Navigator.pop(sheetContext, category),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemCount: _categories.length + 1,
          ),
        );
      },
    );

    if (selectedCategory != null) {
      await _selectCategory(selectedCategory);
    } else {
      await _clearCategory();
    }
  }

  Future<void> _showPriceSelector() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Tất cả'),
                onTap: () => _selectPriceRange(sheetContext, null, null),
              ),
              ListTile(
                title: const Text('Dưới 200.000đ'),
                onTap: () => _selectPriceRange(sheetContext, null, 200000),
              ),
              ListTile(
                title: const Text('200.000đ - 500.000đ'),
                onTap: () => _selectPriceRange(sheetContext, 200000, 500000),
              ),
              ListTile(
                title: const Text('500.000đ - 1.000.000đ'),
                onTap: () => _selectPriceRange(sheetContext, 500000, 1000000),
              ),
              ListTile(
                title: const Text('Trên 1.000.000đ'),
                onTap: () => _selectPriceRange(sheetContext, 1000000, null),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showGenderSelector() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Tất cả'),
                onTap: () => _selectGender(sheetContext, null),
              ),
              ListTile(
                title: const Text('Nam'),
                onTap: () => _selectGender(sheetContext, 1),
              ),
              ListTile(
                title: const Text('Nữ'),
                onTap: () => _selectGender(sheetContext, 2),
              ),
              ListTile(
                title: const Text('Unisex'),
                onTap: () => _selectGender(sheetContext, 3),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAgeRangeSelector() async {
    final ageRanges = _ageRanges.isEmpty ? _fallbackAgeRanges : _ageRanges;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('Tat ca'),
                  trailing: _selectedAgeRange == null
                      ? const Icon(Icons.check, color: AppColors.primaryColor)
                      : null,
                  onTap: () => _selectAgeRange(sheetContext, null),
                );
              }

              final ageRange = ageRanges[index - 1];
              final isSelected = ageRange.value == _selectedAgeRange;
              return ListTile(
                title: Text(ageRange.label),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primaryColor)
                    : null,
                onTap: () => _selectAgeRange(sheetContext, ageRange.value),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemCount: ageRanges.length + 1,
          ),
        );
      },
    );
  }

  Future<void> _showSortSelector() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Tất cả'),
                onTap: () => _selectSort(sheetContext, null),
              ),
              ListTile(
                title: const Text('Mới nhất'),
                onTap: () => _selectSort(sheetContext, 'newest'),
              ),
              ListTile(
                title: const Text('Giá tăng dần'),
                onTap: () => _selectSort(sheetContext, 'price_asc'),
              ),
              ListTile(
                title: const Text('Giá giảm dần'),
                onTap: () => _selectSort(sheetContext, 'price_desc'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _notFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm nào',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
