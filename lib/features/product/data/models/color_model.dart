import '../../domain/entities/color.dart';

class ProductColorModel {
  final String title;
  final List<int> rgb;

  ProductColorModel({
    required this.title,
    required this.rgb,
  });

  /// Convert model -> json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'rgb': rgb,
    };
  }

  /// Parse từ JSON (API trả về đúng format có rgb)
  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      title: json['title'] ?? '',
      rgb: json['rgb'] != null
          ? List<int>.from(json['rgb'])
          : [],
    );
  }

  /// Dùng khi backend CHỈ trả "color": "Xanh"
  factory ProductColorModel.fromAttribute(String color) {
    return ProductColorModel(
      title: color,
      rgb: _mapColorToRgb(color),
    );
  }

  /// Map tạm từ tên màu -> RGB (bạn có thể customize)
  static List<int> _mapColorToRgb(String color) {
    switch (color.toLowerCase()) {
      case 'đỏ':
      case 'do':
        return [255, 0, 0];
      case 'xanh':
        return [0, 0, 255];
      case 'đen':
        return [0, 0, 0];
      case 'trắng':
      case 'trang':
        return [255, 255, 255];
      default:
        return [200, 200, 200]; // fallback
    }
  }
}

/// Model -> Entity
extension ProductColorXModel on ProductColorModel {
  ProductColorEntity toEntity() {
    return ProductColorEntity(
      title: title,
      rgb: rgb,
    );
  }
}

/// Entity -> Model (optional)
extension ProductColorXEntity on ProductColorEntity {
  ProductColorModel toModel() {
    return ProductColorModel(
      title: title,
      rgb: rgb,
    );
  }
}
