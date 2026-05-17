import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:ecommerce_app/features/order/presentation/widgets/history_order_card.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  OrderResponse? _order;
  bool _isCancelling = false;

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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const BasicAppbar(showBack: true, titleText: 'Chi tiết đơn hàng'),
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
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : _order != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HistoryOrderCard(order: _order!),
                  const SizedBox(height: 12),
                  if (_order != null &&
                      (_order!.status.toLowerCase() == 'pending' ||
                          _order!.status.toLowerCase() == 'confirmed'))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: _isCancelling
                            ? null
                            : () => _showCancelDialog(),
                        child: _isCancelling
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Hủy đơn hàng'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text('Thông tin đơn hàng', style: AppTextStyle.h3),
                  const SizedBox(height: 8),
                  _buildOrderInfo(_order!),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // (removed unused _buildAddress) Order info rendered by `_buildOrderInfo`

  Widget _buildOrderInfo(OrderResponse order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Tên người nhận', order.receiverName ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Số điện thoại', order.receiverPhone ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Địa chỉ', order.address ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Trạng thái', _translateStatus(order.status)),
          const Divider(height: 16, thickness: 1),
          _buildInfoRow(
            'Tổng tiền phải trả',
            AppNumberFormat.format(order.totalPrice),
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.withColor(
            AppTextStyle.bodyMedium,
            Colors.black54,
          ),
        ),
        Text(
          value,
          style: AppTextStyle.withColor(
            isHighlight ? AppTextStyle.h3 : AppTextStyle.bodyMedium,
            isHighlight ? AppColors.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      case 'returned':
        return 'Đã trả hàng';
      default:
        return status;
    }
  }

  void _showCancelDialog() {
    final TextEditingController reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy đơn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn có chắc muốn hủy đơn hàng này?'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lý do (tùy chọn)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelOrder(
                  reasonCtrl.text.trim().isEmpty
                      ? null
                      : reasonCtrl.text.trim(),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOrder(String? reason) async {
    setState(() {
      _isCancelling = true;
    });

    try {
      final repository = OrderRepositoryImpl(
        apiService: OrderApiService(tokenStorage: TokenStorage()),
      );
      final updated = await repository.cancelOrder(
        widget.orderId,
        cancelReason: reason,
      );
      if (!mounted) return;
      setState(() {
        _order = updated;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hủy đơn thành công')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi hủy đơn: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }
}
