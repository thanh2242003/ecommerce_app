import 'package:ecommerce_app/features/address/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required String id,
    required String receiverName,
    required String receiverPhone,
    required String address,
    required bool isDefault,
  }) : super(
         id: id,
         receiverName: receiverName,
         receiverPhone: receiverPhone,
         address: address,
         isDefault: isDefault,
       );

  static bool _parseIsDefault(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      receiverName: (json['receiverName'] ?? '').toString(),
      receiverPhone: (json['receiverPhone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      isDefault: _parseIsDefault(json['isDefault']),
    );
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      receiverName: entity.receiverName,
      receiverPhone: entity.receiverPhone,
      address: entity.address,
      isDefault: entity.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'address': address,
      'isDefault': isDefault,
    };
  }

  @override
  AddressModel copyWith({
    String? id,
    String? receiverName,
    String? receiverPhone,
    String? address,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
