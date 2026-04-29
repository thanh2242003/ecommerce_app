import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:flutter/material.dart';
import '../widgets/history_order_card.dart';
import 'order_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const List<String> _filters = [
    'pending',
    'confirmed',
    'shipping',
    'delivered',
    'cancelled',
  ];

  String _selectedFilter = _filters.first;
  bool _isLoading = true;
  String? _errorMessage;
  List<OrderResponse> _orders = const [];

  @override
  void initState() {
    super.initState();
    final initialFilter = widget.initialFilter?.toLowerCase();
    if (initialFilter != null && _filters.contains(initialFilter)) {
      _selectedFilter = initialFilter;
    }
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = OrderRepositoryImpl(
        apiService: OrderApiService(tokenStorage: TokenStorage()),
      );
      final orders = await repository.getOrders();

      if (!mounted) {
        return;
      }

      setState(() {
        _orders = orders;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders
        .where((order) => order.status.toLowerCase() == _selectedFilter)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: BasicAppbar(titleText: 'Lịch sử đơn hàng'),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return ChoiceChip(
                  label: Text(_filterLabel(filter)),
                  selected: isSelected,
                  labelStyle: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    isSelected ? Colors.white : Colors.black87,
                  ),
                  selectedColor: AppColors.primaryColor,
                  backgroundColor: const Color(0xFFF4F4F4),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _filters.length,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody(filteredOrders)),
        ],
      ),
    );
  }

  Widget _buildBody(List<OrderResponse> filteredOrders) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyle.withColor(
                  AppTextStyle.bodySmall,
                  Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadOrders,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          'Không có đơn hàng ở trạng thái ${_filterLabel(_selectedFilter).toLowerCase()}',
          style: AppTextStyle.withColor(
            AppTextStyle.bodyMedium,
            Colors.black54,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: filteredOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final order = filteredOrders[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: order.id),
                ),
              );
            },
            child: HistoryOrderCard(order: order),
          );
        },
      ),
    );
  }
}

String _filterLabel(String filter) {
  switch (filter.toLowerCase()) {
    case 'pending':
      return 'Chờ xác nhận';
    case 'confirmed':
      return 'Chờ lấy hàng';
    case 'shipping':
      return 'Chờ giao hàng';
    case 'delivered':
      return 'Đã giao';
    case 'cancelled':
      return 'Đã hủy';
    default:
      return filter;
  }
}
