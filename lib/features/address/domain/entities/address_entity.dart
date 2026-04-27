class AddressEntity {
  final String id;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.isDefault,
  });

  AddressEntity copyWith({
    String? id,
    String? receiverName,
    String? receiverPhone,
    String? address,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
