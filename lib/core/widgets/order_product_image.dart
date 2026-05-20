import 'package:flutter/material.dart';

class OrderProductImage extends StatelessWidget {
  const OrderProductImage({
    this.image,
    this.width = 84,
    this.height = 84,
    super.key,
  });

  final String? image;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.trim().isEmpty) {
      return _placeholder();
    }

    return Image.network(
      image!.trim(),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF2F2F2),
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.black38),
    );
  }
}
