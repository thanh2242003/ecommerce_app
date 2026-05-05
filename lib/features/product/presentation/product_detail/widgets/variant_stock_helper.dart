import '../../../domain/entities/product.dart';
import '../../../domain/entities/variant.dart';

class VariantStockHelper {
  static ProductVariantEntity? resolveVariant(
    ProductEntity product,
    String color,
    String? size,
  ) {
    final normalizedColor = color.trim().toLowerCase();
    final normalizedSize = size?.trim().toLowerCase();

    for (final variant in product.variants) {
      if (variant.color.trim().toLowerCase() != normalizedColor) {
        continue;
      }

      if (normalizedSize != null && normalizedSize.isNotEmpty) {
        if (variant.size.trim().toLowerCase() != normalizedSize) {
          continue;
        }
      }

      return variant;
    }

    return null;
  }

  static int getVariantStock(
    ProductEntity product,
    String color,
    String? size,
  ) {
    return resolveVariant(product, color, size)?.stock ?? 0;
  }

  static int getColorStock(
    ProductEntity product,
    String color,
    String? selectedSize,
  ) {
    final normalizedColor = color.trim().toLowerCase();
    final normalizedSize = selectedSize?.trim().toLowerCase();

    final matchedVariants = product.variants.where((variant) {
      if (variant.color.trim().toLowerCase() != normalizedColor) {
        return false;
      }

      if (normalizedSize != null && normalizedSize.isNotEmpty) {
        return variant.size.trim().toLowerCase() == normalizedSize;
      }

      return true;
    }).toList();

    if (matchedVariants.isEmpty) {
      return 0;
    }

    if (normalizedSize != null && normalizedSize.isNotEmpty) {
      return matchedVariants.first.stock;
    }

    return matchedVariants.fold<int>(
      0,
      (maxStock, variant) =>
          variant.stock > maxStock ? variant.stock : maxStock,
    );
  }

  static int getSizeStock(
    ProductEntity product,
    String size,
    String? selectedColor,
  ) {
    final normalizedColor = selectedColor?.trim().toLowerCase();
    final normalizedSize = size.trim().toLowerCase();

    final matchedVariants = product.variants.where((variant) {
      if (variant.size.trim().toLowerCase() != normalizedSize) {
        return false;
      }

      if (normalizedColor != null && normalizedColor.isNotEmpty) {
        return variant.color.trim().toLowerCase() == normalizedColor;
      }

      return true;
    }).toList();

    if (matchedVariants.isEmpty) {
      return 0;
    }

    if (normalizedColor != null && normalizedColor.isNotEmpty) {
      return matchedVariants.first.stock;
    }

    return matchedVariants.fold<int>(
      0,
      (maxStock, variant) =>
          variant.stock > maxStock ? variant.stock : maxStock,
    );
  }
}
