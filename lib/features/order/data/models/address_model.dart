class AddressModel {
  final String id;
  final String receiverName;
  final String receiverPhone;
  final String address;

  const AddressModel({
    required this.id,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      receiverName: (json['receiverName'] ?? '').toString(),
      receiverPhone: (json['receiverPhone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'address': address,
    };
  }

  AddressModel copyWith({
    String? id,
    String? receiverName,
    String? receiverPhone,
    String? address,
  }) {
    return AddressModel(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      address: address ?? this.address,
    );
  }
}
