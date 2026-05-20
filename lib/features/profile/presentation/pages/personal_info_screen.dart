import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/basic_app_bar.dart';
import '../../domain/entities/user.dart';
import '../bloc/user_cubit.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserEntity user;
  final String token;
  final String userId;

  const PersonalInfoScreen({
    super.key,
    required this.user,
    required this.token,
    required this.userId,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _avatarController;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedAvatarFile;

  late final FocusNode _nameFocusNode;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _addressFocusNode;

  bool _editName = false;
  bool _editPhone = false;
  bool _editAddress = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _avatarController = TextEditingController(text: widget.user.avatar ?? '');

    _nameFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _avatarController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _toggleEditing(String field) {
    setState(() {
      switch (field) {
        case 'name':
          _editName = !_editName;
          if (_editName) {
            Future.microtask(() => _nameFocusNode.requestFocus());
          }
          break;
        case 'phone':
          _editPhone = !_editPhone;
          if (_editPhone) {
            Future.microtask(() => _phoneFocusNode.requestFocus());
          }
          break;
        case 'address':
          _editAddress = !_editAddress;
          if (_editAddress) {
            Future.microtask(() => _addressFocusNode.requestFocus());
          }
          break;
      }
    });
  }

  Future<void> _saveChanges() async {
    final trimmedName = _nameController.text.trim();
    final trimmedPhone = _phoneController.text.trim();
    final trimmedAddress = _addressController.text.trim();
    final trimmedAvatar = _avatarController.text.trim();

    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ và tên')));
      return;
    }

    setState(() => _isSaving = true);
    final updatedUser = await context.read<UserCubit>().updateUser(
      token: widget.token,
      userId: widget.userId,
      name: trimmedName,
      phone: trimmedPhone,
      address: trimmedAddress,
      avatar: trimmedAvatar,
      avatarFilePath: _pickedAvatarFile?.path,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (updatedUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickAvatarImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _pickedAvatarFile = pickedFile;
      _avatarController.text = 'Đã chọn ảnh mới';
    });
  }

  ImageProvider? _avatarImageProvider() {
    if (_pickedAvatarFile != null) {
      return FileImage(File(_pickedAvatarFile!.path));
    }

    final avatarUrl = _avatarController.text.trim();
    if (avatarUrl.isNotEmpty && avatarUrl != 'Đã chọn ảnh mới') {
      return NetworkImage(avatarUrl);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(showBack: true, titleText: 'Thông tin cá nhân'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickAvatarImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _avatarImageProvider(),
                    child: _avatarImageProvider() == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(widget.user.name, style: AppTextStyle.h3)),
          const SizedBox(height: 24),
          _EditableField(
            label: 'Họ và tên',
            controller: _nameController,
            focusNode: _nameFocusNode,
            readOnly: !_editName,
            onEditTap: () => _toggleEditing('name'),
            suffixIcon: Icons.edit_outlined,
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(label: 'Email', value: _emailController.text),
          const SizedBox(height: 12),
          _EditableField(
            label: 'Số điện thoại',
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            readOnly: !_editPhone,
            keyboardType: TextInputType.phone,
            onEditTap: () => _toggleEditing('phone'),
            suffixIcon: Icons.edit_outlined,
          ),
          const SizedBox(height: 12),
          _EditableField(
            label: 'Địa chỉ',
            controller: _addressController,
            focusNode: _addressFocusNode,
            readOnly: !_editAddress,
            onEditTap: () => _toggleEditing('address'),
            suffixIcon: Icons.edit_outlined,
          ),
          const SizedBox(height: 16),
          _MetaTile(label: 'Trạng thái', value: widget.user.status),
          _MetaTile(
            label: 'Xác thực',
            value: widget.user.verify ? 'Đã xác thực' : 'Chưa xác thực',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu thay đổi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool readOnly;
  final VoidCallback onEditTap;
  final IconData suffixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.readOnly,
    required this.onEditTap,
    required this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(suffixIcon, color: AppColors.primaryColor),
          onPressed: onEditTap,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetaTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.bodyMedium.copyWith(color: Colors.grey[700]),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.end,
              style: AppTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
