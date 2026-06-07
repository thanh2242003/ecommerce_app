import 'dart:async';

import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/features/order/data/models/order_response.dart';
import 'package:ecommerce_app/features/order/data/models/payment_response.dart';
import 'package:ecommerce_app/features/order/data/sources/payment_api_service.dart';
import 'package:flutter/material.dart';

class SepayPaymentScreen extends StatefulWidget {
  const SepayPaymentScreen({super.key, required this.order});

  final OrderResponse order;

  @override
  State<SepayPaymentScreen> createState() => _SepayPaymentScreenState();
}

class _SepayPaymentScreenState extends State<SepayPaymentScreen> {
  late final PaymentApiService _paymentApiService;
  Timer? _pollTimer;
  PaymentResponse? _payment;
  bool _isLoading = true;
  bool _isChecking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _paymentApiService = PaymentApiService(tokenStorage: TokenStorage());
    _createPayment();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _createPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payment = await _paymentApiService.createSepayPayment(
        widget.order.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _payment = payment;
      });
      if (!_isTerminal(payment.status)) {
        _startPolling();
      }
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

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkStatus(silent: true);
    });
  }

  Future<void> _checkStatus({bool silent = false}) async {
    final paymentId = _payment?.id;
    if (paymentId == null || paymentId.isEmpty || _isChecking) {
      return;
    }

    if (!silent) {
      setState(() {
        _errorMessage = null;
        _isChecking = true;
      });
    } else {
      _isChecking = true;
    }

    try {
      final payment = await _paymentApiService.getPaymentStatus(paymentId);
      if (!mounted) {
        return;
      }
      setState(() {
        _payment = _mergePayment(payment);
      });

      if (_isTerminal(payment.status)) {
        _pollTimer?.cancel();
      }
    } catch (e) {
      if (!mounted || silent) {
        return;
      }
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted && !silent) {
        setState(() {
          _isChecking = false;
        });
      } else {
        _isChecking = false;
      }
    }
  }

  bool _isTerminal(String status) {
    final normalized = status.toUpperCase();
    return normalized == 'SUCCESS' ||
        normalized == 'FAILED' ||
        normalized == 'EXPIRED';
  }

  PaymentResponse _mergePayment(PaymentResponse latest) {
    final current = _payment;
    if (current == null || latest.qrData != null) {
      return latest;
    }
    return PaymentResponse(
      id: latest.id,
      orderId: latest.orderId,
      amount: latest.amount > 0 ? latest.amount : current.amount,
      status: latest.status,
      transactionId: latest.transactionId ?? current.transactionId,
      userId: latest.userId ?? current.userId,
      paymentMethod: latest.paymentMethod ?? current.paymentMethod,
      expiredAt: latest.expiredAt ?? current.expiredAt,
      paidAt: latest.paidAt ?? current.paidAt,
      qrData: current.qrData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = _payment;
    final status = payment?.status.toUpperCase() ?? 'PENDING';
    final isSuccess = status == 'SUCCESS';
    final isFailed = status == 'FAILED' || status == 'EXPIRED';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const BasicAppbar(titleText: 'Thanh toán chuyển khoản'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusCard(status: status),
                  const SizedBox(height: 14),
                  if (_errorMessage != null)
                    _ErrorCard(
                      message: _errorMessage!,
                      onRetry: _createPayment,
                    ),
                  if (_errorMessage != null) const SizedBox(height: 14),
                  if (payment != null) _PaymentQrCard(payment: payment),
                  const SizedBox(height: 14),
                  if (payment != null) _PaymentInfoCard(payment: payment),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSuccess || isFailed
                          ? () => Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst)
                          : () => _checkStatus(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isSuccess || isFailed
                            ? 'Hoàn tất'
                            : _isChecking
                            ? 'Đang kiểm tra...'
                            : 'Kiểm tra thanh toán',
                        style: AppTextStyle.buttonMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'SUCCESS';
    final isFailed = status == 'FAILED' || status == 'EXPIRED';
    final color = isSuccess
        ? AppColors.primaryColor
        : isFailed
        ? Colors.redAccent
        : Colors.orangeAccent;
    final icon = isSuccess
        ? Icons.check_circle_outline
        : isFailed
        ? Icons.error_outline
        : Icons.schedule_outlined;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusText(status),
              style: AppTextStyle.withColor(AppTextStyle.buttonMedium, color),
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'SUCCESS':
        return 'Thanh toán thành công';
      case 'FAILED':
        return 'Thanh toán thất bại';
      case 'EXPIRED':
        return 'Thanh toán đã hết hạn';
      case 'PROCESSING':
        return 'Đang xử lý giao dịch';
      default:
        return 'Đang chờ chuyển khoản';
    }
  }
}

class _PaymentQrCard extends StatelessWidget {
  const _PaymentQrCard({required this.payment});

  final PaymentResponse payment;

  @override
  Widget build(BuildContext context) {
    final qrText = payment.qrData?.qrText ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: 230,
            height: 230,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: qrText.isEmpty
                ? const Center(child: Icon(Icons.qr_code_2, size: 90))
                : Image.network(
                    qrText,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.qr_code_2, size: 90)),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quét QR hoặc chuyển khoản theo thông tin bên dưới',
            textAlign: TextAlign.center,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard({required this.payment});

  final PaymentResponse payment;

  @override
  Widget build(BuildContext context) {
    final qrData = payment.qrData;
    final amount = payment.amount > 0 ? payment.amount : qrData?.amount ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Ngân hàng', value: qrData?.bankName ?? 'N/A'),
          const SizedBox(height: 10),
          _InfoRow(label: 'Số tài khoản', value: qrData?.bankAccount ?? 'N/A'),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Số tiền',
            value: AppNumberFormat.format(amount),
            highlight: true,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Nội dung',
            value: qrData?.transferContent ?? qrData?.paymentCode ?? 'N/A',
            highlight: true,
          ),
          if (payment.expiredAt != null) ...[
            const SizedBox(height: 10),
            _InfoRow(label: 'Hết hạn', value: _formatDate(payment.expiredAt!)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)} ${two(local.day)}/${two(local.month)}/${local.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyle.withColor(
              highlight ? AppTextStyle.buttonMedium : AppTextStyle.bodyMedium,
              highlight ? AppColors.primaryColor : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
