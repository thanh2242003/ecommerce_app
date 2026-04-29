import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/core/widgets/basic_app_bar.dart';
import 'package:ecommerce_app/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_app/features/address/presentation/bloc/address_cubit.dart';
import 'package:ecommerce_app/features/address/presentation/pages/add_address_screen.dart';
import 'package:ecommerce_app/features/address/presentation/pages/edit_address_screen.dart';
import 'package:ecommerce_app/features/order/data/models/address_model.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key, this.isSelectionMode = false});

  final bool isSelectionMode;

  @override
  Widget build(BuildContext context) {
    return _AddressView(isSelectionMode: isSelectionMode);
  }
}

class _AddressView extends StatefulWidget {
  const _AddressView({this.isSelectionMode = false});

  final bool isSelectionMode;

  @override
  State<_AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<_AddressView> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().getAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: BasicAppbar(
        titleText: widget.isSelectionMode
            ? 'Chọn địa chỉ nhận hàng'
            : 'Địa chỉ nhận hàng',
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is AddressFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi tải danh sách địa chỉ',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AddressCubit>().getAddresses(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is AddressLoaded) {
            return _buildAddressList(
              context,
              state.defaultAddress,
              state.addresses,
              widget.isSelectionMode,
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: widget.isSelectionMode
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFEBF4F1)),
              child: ElevatedButton(
                onPressed: () => _goToAddAddressScreen(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF379570),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Thêm địa chỉ mới',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
    );
  }

  Widget _buildAddressList(
    BuildContext context,
    AddressEntity? defaultAddress,
    List<AddressEntity> addresses,
    bool isSelectionMode,
  ) {
    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có địa chỉ nào',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                Colors.grey[600]!,
              ),
            ),
          ],
        ),
      );
    }

    final otherAddresses = addresses
        .where((address) => address.id != defaultAddress?.id)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Địa chỉ mặc định',
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (defaultAddress != null)
            _AddressItemCard(
              address: defaultAddress,
              showDefaultBadge: true,
              isSelectionMode: isSelectionMode,
              onEdit: () => _showEditAddressDialog(context, defaultAddress),
              onDelete: () => _showDeleteConfirmDialog(context, defaultAddress),
              onSelect: isSelectionMode
                  ? () => _selectAndReturn(context, defaultAddress)
                  : null,
            )
          else
            const _EmptySectionCard(message: 'Chưa có địa chỉ mặc định'),
          if (otherAddresses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Địa chỉ khác',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: otherAddresses.length,
              itemBuilder: (context, index) {
                final address = otherAddresses[index];
                return _AddressItemCard(
                  address: address,
                  showDefaultBadge: false,
                  isSelectionMode: isSelectionMode,
                  onEdit: () => _showEditAddressDialog(context, address),
                  onDelete: () => _showDeleteConfirmDialog(context, address),
                  onSelect: isSelectionMode
                      ? () => _selectAndReturn(context, address)
                      : null,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _goToAddAddressScreen(BuildContext context) {
    final cubit = context.read<AddressCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const AddAddressScreen()),
      ),
    );
  }

  void _selectAndReturn(BuildContext context, AddressEntity address) {
    final addressModel = AddressModel(
      id: address.id,
      receiverName: address.receiverName,
      receiverPhone: address.receiverPhone,
      address: address.address,
    );
    Navigator.pop(context, addressModel);
  }

  void _showEditAddressDialog(BuildContext context, AddressEntity address) {
    final cubit = context.read<AddressCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditAddressScreen(address: address),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AddressEntity address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AddressCubit>().deleteAddress(address.id);
              if (!context.mounted) {
                return;
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa địa chỉ thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: AppTextStyle.withColor(
          AppTextStyle.bodyMedium,
          Colors.grey[600]!,
        ),
      ),
    );
  }
}

class _AddressItemCard extends StatelessWidget {
  const _AddressItemCard({
    required this.address,
    required this.showDefaultBadge,
    required this.onEdit,
    required this.onDelete,
    this.isSelectionMode = false,
    this.onSelect,
  });

  final AddressEntity address;
  final bool showDefaultBadge;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectionMode ? onSelect : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 24,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: address.receiverName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' | ${address.receiverPhone}',
                                    style: const TextStyle(
                                      color: Color(0xFFA0A0A0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (showDefaultBadge) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF379570,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'Mặc định',
                                style: TextStyle(
                                  color: Color(0xFF379570),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address.address,
                        style: const TextStyle(
                          color: Color(0xFF404040),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isSelectionMode) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFD9D9D9), height: 1, thickness: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Text(
                      'Sửa',
                      style: TextStyle(
                        color: Color(0xFF379570),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Text(
                      'Xóa',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
