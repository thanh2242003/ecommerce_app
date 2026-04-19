import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:flutter/material.dart';

class OrderHistoryDetailScreen extends StatefulWidget {
  const OrderHistoryDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderHistoryDetailScreen> createState() =>
      _OrderHistoryDetailScreenState();
}

class _OrderHistoryDetailScreenState extends State<OrderHistoryDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  OrderResponse? _order;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = OrderRepositoryImpl(
        apiService: OrderApiService(tokenStorage: TokenStorage()),
      );
      final order = await repository.getOrderDetail(widget.orderId);
      if (!mounted) {
        return;
      }
      setState(() {
        _order = order;
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
    final orderCode = _order?.id ?? widget.orderId;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Order #$orderCode',
          style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black87),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : _errorMessage != null
          ? Center(
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
                      onPressed: _loadOrderDetail,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
