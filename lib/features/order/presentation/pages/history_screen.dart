import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:ecommerce_app/features/order/presentation/pages/order_history_detail_screen.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'History',
          style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black87),
        ),
      ),
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
                  label: Text(filter),
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          'No orders in $_selectedFilter',
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
          return _HistoryOrderCard(order: order);
        },
      ),
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({required this.order});

  final OrderResponse order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderHistoryDetailScreen(orderId: order.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.itemCount} items',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodySmall,
                      Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
