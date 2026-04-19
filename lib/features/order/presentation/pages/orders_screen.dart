import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/utils/app_number_format.dart';
import 'package:ecommerce_app/core/storage/token_storage.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/order/data/models/address_model.dart';
import 'package:ecommerce_app/features/order/data/sources/address_api_service.dart';
import 'package:ecommerce_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:ecommerce_app/features/order/data/sources/order_api_service.dart';
import 'package:ecommerce_app/features/order/presentation/bloc/order_cubit.dart';

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
  AddressModel? _selectedAddress;
  String? _addressError;
  bool _isLoadingAddress = false;
  bool _isSavingAddress = false;

  static const int _shippingFee = 30000;
  static const int _voucherDiscount = 20000;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    setState(() {
      _isLoadingAddress = true;
      _addressError = null;
    });

    try {
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

  int get _totalPayment {
    final total = _subTotal + _shippingFee - _voucherDiscount;
    return total < 0 ? 0 : total;
  }

  Future<void> _handleAddAddress() async {
    if (_isSavingAddress) {
      return;
    }

    final createdAddress = await showDialog<AddressModel>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AddAddressDialog(
        onSubmit: (receiverName, receiverPhone, address) async {
          setState(() {
            _isSavingAddress = true;
          });
          try {
            final tokenStorage = TokenStorage();
            final apiService = AddressApiService(tokenStorage: tokenStorage);
            final created = await apiService.createAddress(
              receiverName: receiverName,
              receiverPhone: receiverPhone,
              address: address,
            );
            final defaultAddress = await apiService.getDefaultAddress();
            return defaultAddress ?? created;
          } finally {
            if (mounted) {
              setState(() {
                _isSavingAddress = false;
              });
            }
          }
        },
      ),
    );

    if (!mounted || createdAddress == null) {
      return;
    }

    setState(() {
      _selectedAddress = createdAddress;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Them dia chi thanh cong'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dat hang thanh cong! Ma don: ${state.order.id}'),
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
              appBar: AppBar(
                elevation: 0,
                backgroundColor: AppColors.lightBackground,
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Text(
                  'Order',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h3,
                    Colors.black87,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Dia chi nhan hang'),
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
                        isSaving: _isSavingAddress,
                        onTap: _handleAddAddress,
                      )
                    else
                      _AddressCard(address: _selectedAddress!),
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
                          ? 'San pham mua ngay'
                          : 'San pham da chon',
                    ),
                    const SizedBox(height: 10),
                    _SelectedItemsCard(items: _displayItems),
                    const SizedBox(height: 18),
                    _SectionTitle(title: 'Chi tiet thanh toan'),
                    const SizedBox(height: 10),
                    _PaymentDetailCard(
                      subTotal: _subTotal,
                      shippingFee: _shippingFee,
                      voucherDiscount: _voucherDiscount,
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
                            'Tong phai tra',
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
                                _isLoadingAddress ||
                                _isSavingAddress
                            ? null
                            : () => _placeOrder(context),
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
                          'Dat hang',
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

  void _placeOrder(BuildContext context) {
    final currentAddress = _selectedAddress;
    if (currentAddress == null || currentAddress.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui long them dia chi nhan hang'),
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
        widget.product!.color,
      );
      return;
    }

    context.read<OrderCubit>().createCartOrder(currentAddress.id);
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
                isSaving ? 'Dang luu dia chi...' : 'Them dia chi',
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
          content: Text('Them dia chi that bai: $e'),
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
      title: const Text('Them dia chi'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nguoi nhan'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Vui long nhap ten nguoi nhan'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'So dien thoai'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Vui long nhap so dien thoai'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Dia chi'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Vui long nhap dia chi'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Huy'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Luu'),
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
  const _AddressCard({required this.address});

  final AddressModel address;

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
            address.receiverName,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyLarge,
              Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            address.receiverPhone,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            address.address,
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
          'Chua co san pham nao duoc chon',
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
                        'Mau: ${item.color} x${item.quantity}',
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

    final value = image!;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    final assetPath = value.startsWith('assets/')
        ? value
        : 'assets/images/$value';

    return Image.asset(
      assetPath,
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
    required this.totalPayment,
  });

  final int subTotal;
  final int shippingFee;
  final int voucherDiscount;
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
          _PaymentRow(label: 'Voucher giam gia', value: -voucherDiscount),
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
