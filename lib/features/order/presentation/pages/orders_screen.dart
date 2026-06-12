import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/order/data/models/address_model.dart';
import 'package:ecommerce_app/features/order/data/sources/discount_api_service.dart';
import 'package:ecommerce_app/features/order/data/sources/address_api_service.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/features/order/presentation/bloc/order_cubit.dart';
import 'package:ecommerce_app/features/order/presentation/pages/discount_code_picker_screen.dart';
import 'package:ecommerce_app/features/order/presentation/pages/sepay_payment_screen.dart';
import 'package:ecommerce_app/features/address/presentation/pages/add_address_screen.dart';
import 'package:ecommerce_app/features/address/presentation/pages/address_screen.dart';
import 'package:ecommerce_app/features/address/presentation/bloc/address_cubit.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
    this.selectedItems = const [],
    this.selectedAddress,
    this.product,
  });

  final List<CartItemEntity> selectedItems;
  final AddressModel? selectedAddress;
  final CartItemEntity? product;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderCubit(
        orderRepository: OrderRepositoryImpl(
          apiService: OrderApiService(tokenStorage: TokenStorage()),
        ),
      ),
      child: _OrdersView(
        selectedItems: selectedItems,
        selectedAddress: selectedAddress,
        product: product,
      ),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView({
    required this.selectedItems,
    required this.selectedAddress,
    required this.product,
  });

  final List<CartItemEntity> selectedItems;
  final AddressModel? selectedAddress;
  final CartItemEntity? product;

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  final _discountApiService = DiscountApiService(tokenStorage: TokenStorage());

  AddressModel? _selectedAddress;
  String? _addressError;
  String? _appliedDiscountCode;
  bool _isLoadingAddress = false;
  bool _isCalculatingDiscount = false;
  int _discountAmount = 0;
  String _selectedPaymentMethod = 'cod';

  static const int _shippingFee = 0;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    setState(() {
      _isLoadingAddress = true;
      _addressError = null;
    });

    try {
      // Note: AddressApiService is now in order feature for backward compatibility
      // In a real app, you might want to move this to use the new address feature
      final apiService = AddressApiService(tokenStorage: TokenStorage());
      final defaultAddress = await apiService.getDefaultAddress();

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedAddress = defaultAddress;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedAddress = null;
        _addressError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  bool get _isBuyNow => widget.product != null;

  List<CartItemEntity> get _displayItems {
    if (_isBuyNow) {
      return [widget.product!];
    }
    return widget.selectedItems;
  }

  int get _subTotal =>
      _displayItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  String? get _commonShopId {
    final shopIds = _displayItems
        .map((item) => item.shopId?.trim())
        .where((shopId) => shopId != null && shopId.isNotEmpty)
        .cast<String>()
        .toSet();

    if (shopIds.length == 1) {
      return shopIds.first;
    }

    return null;
  }

  bool get _hasMixedShopIds {
    final shopIds = _displayItems
        .map((item) => item.shopId?.trim())
        .where((shopId) => shopId != null && shopId.isNotEmpty)
        .toSet();

    return shopIds.length > 1;
  }

  int get _effectiveDiscountAmount {
    final maxDiscount = _subTotal + _shippingFee;
    final discount = _discountAmount;
    if (discount <= 0) {
      return 0;
    }
    return discount > maxDiscount ? maxDiscount : discount;
  }

  int get _totalPayment {
    final total = _subTotal + _shippingFee - _effectiveDiscountAmount;
    return total < 0 ? 0 : total;
  }

  Future<void> _applyDiscount(String code, {bool silent = false}) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      return;
    }

    if (_displayItems.isEmpty) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có sản phẩm để áp mã giảm giá'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_hasMixedShopIds) {
      setState(() {
        _discountAmount = 0;
        _appliedDiscountCode = null;
      });
      return;
    }

    setState(() {
      _isCalculatingDiscount = true;
    });

    try {
      final result = await _discountApiService.calculateDiscount(
        codeId: normalizedCode,
        shopId: _commonShopId,
        products: _displayItems
            .map(
              (item) => <String, dynamic>{
                'productId': item.productId,
                'quantity': item.quantity,
                'price': item.price,
              },
            )
            .toList(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _appliedDiscountCode = normalizedCode.toUpperCase();
        _discountAmount = result.discount;
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Áp mã thành công, giảm ${AppNumberFormat.format(result.discount)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _discountAmount = 0;
        _appliedDiscountCode = null;
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCalculatingDiscount = false;
        });
      }
    }
  }

  Future<void> _openDiscountPicker() async {
    final selectedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => DiscountCodePickerScreen(
          shopId: _commonShopId,
          currentOrderValue: _subTotal + _shippingFee,
        ),
      ),
    );

    if (selectedCode == null || selectedCode.trim().isEmpty) {
      return;
    }

    await _applyDiscount(selectedCode);
  }

  void _goToAddressScreen() {
    Navigator.of(context)
        .push<AddressModel>(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AddressCubit>(),
              child: const AddressScreen(isSelectionMode: true),
            ),
          ),
        )
        .then((selectedAddress) {
          if (selectedAddress != null) {
            setState(() {
              _selectedAddress = selectedAddress;
            });
          }
        });
  }

  void _goToAddAddressScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddAddressScreen()))
        .then((_) {
          // Reload default address when returning from add address screen
          _loadDefaultAddress();
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          context.read<CartCubit>().fetchCart(forceRefresh: true);

          if (_selectedPaymentMethod == 'bank_transfer') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SepayPaymentScreen(order: state.order),
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đặt hàng thành công! Mã đơn: ${state.order.id}'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        if (state is OrderFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is OrderLoading;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.lightBackground,
              appBar: BasicAppbar(titleText: 'Đặt hàng'),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Địa chỉ nhận hàng'),
                    const SizedBox(height: 10),
                    if (_isLoadingAddress)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    else if (_selectedAddress == null)
                      _AddAddressCard(
                        isSaving: false,
                        onTap: _goToAddAddressScreen,
                      )
                    else
                      _AddressCard(
                        address: _selectedAddress!,
                        onTap: _goToAddressScreen,
                      ),
                    if (_addressError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _addressError!,
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodySmall,
                            Colors.red,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: _isBuyNow
                          ? 'Sản phẩm mua ngay'
                          : 'Sản phẩm đã chọn',
                    ),
                    const SizedBox(height: 10),
                    _SelectedItemsCard(items: _displayItems),
                    const SizedBox(height: 18),
                    _SectionTitle(title: 'Mã giảm giá'),
                    const SizedBox(height: 10),
                    _DiscountCodeCard(
                      isLoading: _isCalculatingDiscount,
                      onOpenPicker: _openDiscountPicker,
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(title: 'Phương thức thanh toán'),
                    const SizedBox(height: 10),
                    _PaymentMethodCard(
                      selectedMethod: _selectedPaymentMethod,
                      onChanged: (method) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(title: 'Chi tiết thanh toán'),
                    const SizedBox(height: 10),
                    _PaymentDetailCard(
                      subTotal: _subTotal,
                      shippingFee: _shippingFee,
                      voucherDiscount: _effectiveDiscountAmount,
                      discountCode: _appliedDiscountCode,
                      totalPayment: _totalPayment,
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                  color: AppColors.lightCard,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng phải trả',
                            style: AppTextStyle.withColor(
                              AppTextStyle.bodySmall,
                              Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppNumberFormat.format(_totalPayment),
                            style: AppTextStyle.withColor(
                              AppTextStyle.h3,
                              AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _displayItems.isEmpty ||
                                isLoading ||
                                _isLoadingAddress
                            ? null
                            : () async => _placeOrder(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: AppColors.primaryColor
                              .withValues(alpha: 0.45),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Đặt hàng',
                          style: AppTextStyle.buttonMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black26,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final currentAddress = _selectedAddress;
    if (currentAddress == null || currentAddress.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm địa chỉ nhận hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call the right API payload based on checkout flow type.
    if (_isBuyNow && widget.product != null) {
      context.read<OrderCubit>().createBuyNowOrder(
        currentAddress.id,
        widget.product!.productId,
        widget.product!.quantity,
        widget.product!.variantId,
        _totalPayment,
        paymentMethod: _selectedPaymentMethod,
        discountCode: _appliedDiscountCode,
      );
      return;
    }

    context.read<OrderCubit>().createCartOrder(
      currentAddress.id,
      _totalPayment,
      paymentMethod: _selectedPaymentMethod,
      discountCode: _appliedDiscountCode,
      selectedCartItems: _displayItems
          .where((item) => item.variantId != null && item.variantId!.isNotEmpty)
          .map(
            (item) => <String, String>{
              'productId': item.productId,
              'variantId': item.variantId!,
            },
          )
          .toList(),
    );
  }
}

class _DiscountCodeCard extends StatelessWidget {
  const _DiscountCodeCard({
    required this.isLoading,
    required this.onOpenPicker,
  });

  final bool isLoading;
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn hoặc nhập mã giảm giá trong màn voucher để áp dụng cho đơn hàng.',
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onOpenPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.local_offer_outlined),
              label: const Text('Chọn mã giảm giá'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selectedMethod,
    required this.onChanged,
  });

  final String selectedMethod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _PaymentMethodOption(
            icon: Icons.payments_outlined,
            title: 'Thanh toán khi nhận hàng',
            subtitle: 'Trả tiền mặt sau khi đơn hàng được giao.',
            value: 'cod',
            selectedValue: selectedMethod,
            onChanged: onChanged,
          ),
          const Divider(height: 18, color: Colors.black12),
          _PaymentMethodOption(
            icon: Icons.qr_code_2_outlined,
            title: 'Chuyển khoản QR',
            subtitle: 'Tạo mã SePay và xác nhận tự động sau khi chuyển khoản.',
            value: 'bank_transfer',
            selectedValue: selectedMethod,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.black26,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 10, height: 10),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _AddAddressCard extends StatelessWidget {
  const _AddAddressCard({required this.onTap, required this.isSaving});

  final VoidCallback onTap;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSaving ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_location_alt_outlined,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isSaving ? 'Đang lưu địa chỉ...' : 'Thêm địa chỉ',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Colors.black87,
                ),
              ),
            ),
            if (isSaving)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog({required this.onSubmit});

  final Future<AddressModel> Function(
    String receiverName,
    String receiverPhone,
    String address,
  )
  onSubmit;

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      // Save new address to backend as default before using it for checkout.
      final createdAddress = await widget.onSubmit(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _addressController.text.trim(),
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(createdAddress);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thêm địa chỉ thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm địa chỉ'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Người nhận'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Vui lòng nhập tên người nhận'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Vui lòng nhập số điện thoại'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Vui lòng nhập địa chỉ'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.black87),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onTap});

  final AddressModel address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon location
            const Icon(Icons.location_on_outlined, size: 28),

            const SizedBox(width: 12),

            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên + SĐT
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.receiverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        address.receiverPhone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Địa chỉ
                  Text(
                    address.address,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Icon mũi tên
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _SelectedItemsCard extends StatelessWidget {
  const _SelectedItemsCard({required this.items});

  final List<CartItemEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Chưa có sản phẩm nào được chọn',
          style: AppTextStyle.withColor(
            AppTextStyle.bodyMedium,
            Colors.black54,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Colors.black12, width: 1),
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: _OrderProductImage(image: item.productImage),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName.isNotEmpty
                            ? item.productName
                            : 'Product',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.size != null && item.size!.isNotEmpty
                            ? 'Màu: ${item.color} • Size: ${item.size} x${item.quantity}'
                            : 'Màu: ${item.color} x${item.quantity}',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppNumberFormat.format(item.price * item.quantity),
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonSmall,
                          AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OrderProductImage extends StatelessWidget {
  const _OrderProductImage({this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      image!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.black12,
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.black38),
    );
  }
}

class _PaymentDetailCard extends StatelessWidget {
  const _PaymentDetailCard({
    required this.subTotal,
    required this.shippingFee,
    required this.voucherDiscount,
    required this.discountCode,
    required this.totalPayment,
  });

  final int subTotal;
  final int shippingFee;
  final int voucherDiscount;
  final String? discountCode;
  final int totalPayment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _PaymentRow(label: 'Tong tien hang', value: subTotal),
          const SizedBox(height: 10),
          _PaymentRow(label: 'Phi van chuyen', value: shippingFee),
          const SizedBox(height: 10),
          _PaymentRow(
            label: discountCode != null && discountCode!.isNotEmpty
                ? 'Giam gia ($discountCode)'
                : 'Voucher giam gia',
            value: -voucherDiscount,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.black12),
          ),
          _PaymentRow(
            label: 'Tong thanh toan',
            value: totalPayment,
            valueStyle: AppTextStyle.withColor(
              AppTextStyle.buttonMedium,
              AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final int value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    final displayValue = isNegative
        ? '-${AppNumberFormat.format(value.abs())}'
        : AppNumberFormat.format(value);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black54,
            ),
          ),
        ),
        Text(
          displayValue,
          style:
              valueStyle ??
              AppTextStyle.withColor(AppTextStyle.bodyMedium, Colors.black87),
        ),
      ],
    );
  }
}
