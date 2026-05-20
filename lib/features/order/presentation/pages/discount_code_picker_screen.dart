import 'dart:async';

import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/features/order/data/models/discount_code_model.dart';
import 'package:ecommerce_app/features/order/data/sources/discount_list_api_service.dart';
import 'package:flutter/material.dart';

class DiscountCodePickerScreen extends StatefulWidget {
  const DiscountCodePickerScreen({
    super.key,
    this.shopId,
    required this.currentOrderValue,
  });

  final String? shopId;
  final int currentOrderValue;

  @override
  State<DiscountCodePickerScreen> createState() =>
      _DiscountCodePickerScreenState();
}

class _DiscountCodePickerScreenState extends State<DiscountCodePickerScreen> {
  final _searchController = TextEditingController();
  final _manualController = TextEditingController();
  final _discountListApiService = DiscountListApiService(
    tokenStorage: TokenStorage(),
  );

  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  List<DiscountCodeModel> _codes = const [];

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _loadCodes({String? code}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _discountListApiService.getDiscountCodes(
        shopId: widget.shopId,
        code: code,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _codes = result;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _codes = const [];
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

  void _submitManualCode() {
    final code = _manualController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã giảm giá'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop(code);
  }

  void _selectCode(DiscountCodeModel code) {
    Navigator.of(context).pop(code.code.trim().toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const BasicAppbar(titleText: 'Mã giảm giá'),
      body: RefreshIndicator(
        onRefresh: _loadCodes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ManualEntryCard(
              controller: _manualController,
              onSubmit: _submitManualCode,
            ),
            const SizedBox(height: 16),
            Text(
              'Mã có thể dùng',
              style: AppTextStyle.withColor(
                AppTextStyle.buttonMedium,
                Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else if (_errorMessage != null)
              _EmptyState(
                title: 'Không tải được mã giảm giá',
                subtitle: _errorMessage!,
                actionLabel: 'Thử lại',
                onAction: () => _loadCodes(
                  code: _searchController.text.trim().isEmpty
                      ? null
                      : _searchController.text.trim(),
                ),
              )
            else if (_codes.isEmpty)
              const _EmptyState(
                title: 'Chưa có mã phù hợp',
                subtitle: 'Bạn có thể nhập mã trực tiếp ở trên để áp dụng.',
              )
            else
              ..._codes.map((code) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DiscountCodeTile(
                    code: code,
                    currentOrderValue: widget.currentOrderValue,
                    onTap: () => _selectCode(code),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ManualEntryCard extends StatelessWidget {
  const _ManualEntryCard({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhập mã thủ công',
            style: AppTextStyle.withColor(
              AppTextStyle.buttonMedium,
              Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'VD: SPRING50',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: const Text('Dùng mã'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscountCodeTile extends StatelessWidget {
  const _DiscountCodeTile({
    required this.code,
    required this.currentOrderValue,
    required this.onTap,
  });

  final DiscountCodeModel code;
  final int currentOrderValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final minOrderValue = (code.minOrderValue ?? 0).toInt();
    final canUse = currentOrderValue >= minOrderValue;
    final expiry = code.expiryDate;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canUse
                ? AppColors.primaryColor.withValues(alpha: 0.2)
                : Colors.black12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    code.code,
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.black87,
                    ),
                  ),
                ),
                if (canUse)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Dùng được',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        AppColors.primaryColor,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Chưa đủ điều kiện',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              code.description.isNotEmpty ? code.description : 'Mã giảm giá',
              style: AppTextStyle.withColor(
                AppTextStyle.bodySmall,
                Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              code.type == 'percentage'
                  ? 'Giảm ${code.value.toString()}%'
                  : 'Giảm ${AppNumberFormat.format(code.value.toInt())}',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                AppColors.primaryColor,
              ),
            ),
            if (minOrderValue > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Đơn tối thiểu ${AppNumberFormat.format(minOrderValue)}',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodySmall,
                  Colors.black45,
                ),
              ),
            ],
            if (expiry != null) ...[
              const SizedBox(height: 4),
              Text(
                'Hết hạn: ${expiry.toLocal().toIso8601String().split('T').first}',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodySmall,
                  Colors.black45,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: canUse ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Chọn mã'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 42,
            color: Colors.black38,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.withColor(
              AppTextStyle.buttonMedium,
              Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyle.withColor(
              AppTextStyle.bodySmall,
              Colors.black54,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
