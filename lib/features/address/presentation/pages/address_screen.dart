import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_app/features/address/presentation/bloc/address_cubit.dart';
import 'package:ecommerce_app/features/address/presentation/pages/add_address_screen.dart';
import 'package:ecommerce_app/features/address/presentation/pages/edit_address_screen.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AddressView();
  }
}

class _AddressView extends StatefulWidget {
  const _AddressView();

  @override
  State<_AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<_AddressView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFEBF4F1),
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF4F5F6)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
            splashRadius: 20,
          ),
        ),
        title: Text(
          'Dia chi nhan hang',
          style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black),
        ),
        centerTitle: true,
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
                    'Loi tai danh sach dia chi',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AddressCubit>().getAddresses(),
                    child: const Text('Thu lai'),
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
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Container(
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
            'Them dia chi moi',
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
              'Chua co dia chi nao',
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
            'Dia chi mac dinh',
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
              onEdit: () => _showEditAddressDialog(context, defaultAddress),
              onDelete: () => _showDeleteConfirmDialog(context, defaultAddress),
            )
          else
            const _EmptySectionCard(message: 'Chua co dia chi mac dinh'),
          if (otherAddresses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Dia chi khac',
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
                  onEdit: () => _showEditAddressDialog(context, address),
                  onDelete: () => _showDeleteConfirmDialog(context, address),
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
        title: const Text('Xac nhan xoa'),
        content: const Text('Ban co chac chan muon xoa dia chi nay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huy'),
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
                  content: Text('Xoa dia chi thanh cong'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoa'),
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
  });

  final AddressEntity address;
  final bool showDefaultBadge;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                              'Mac dinh',
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
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFD9D9D9), height: 1, thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Sua',
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
                  'Xoa',
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
      ),
    );
  }
}
