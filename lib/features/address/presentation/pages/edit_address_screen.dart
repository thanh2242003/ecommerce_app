import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_text_styles.dart';
import 'package:ecommerce_app/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_app/features/address/presentation/bloc/address_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key, required this.address});

  final AddressEntity address;

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _submitting = false;
  bool _settingDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.receiverName);
    _phoneController = TextEditingController(
      text: widget.address.receiverPhone,
    );
    _addressController = TextEditingController(text: widget.address.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _submitting || _settingDefault) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await context.read<AddressCubit>().updateAddress(
        addressId: widget.address.id,
        receiverName: _nameController.text.trim(),
        receiverPhone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cap nhat dia chi thanh cong'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _setDefault() async {
    if (widget.address.isDefault || _settingDefault || _submitting) {
      return;
    }

    setState(() {
      _settingDefault = true;
    });

    try {
      await context.read<AddressCubit>().setDefaultAddress(widget.address.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Da dat dia chi mac dinh'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _settingDefault = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.lightBackground,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Sua dia chi',
          style: AppTextStyle.withColor(AppTextStyle.h3, Colors.black87),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nguoi nhan'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui long nhap ten nguoi nhan';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'So dien thoai'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui long nhap so dien thoai';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Dia chi'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui long nhap dia chi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.lightCard,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            if (!widget.address.isDefault)
              Expanded(
                child: OutlinedButton(
                  onPressed: _settingDefault || _submitting
                      ? null
                      : _setDefault,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    foregroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _settingDefault
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Chon lam mac dinh'),
                ),
              ),
            if (!widget.address.isDefault) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitting || _settingDefault ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Luu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
