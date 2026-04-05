import '../../domain/entities/user.dart';

class UserModel {
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? avatar;
  final String status;
  final bool verify;
  final List<String> roles;

  UserModel({
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.avatar,
    required this.status,
    required this.verify,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar'],
      status: json['status'] ?? '',
      verify: json['verify'] ?? false,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : [],
    );
  }
}

/// Model -> Entity
extension UserXModel on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      name: name,
      email: email,
      phone: phone,
      address: address,
      avatar: avatar,
      status: status,
      verify: verify,
      roles: roles,
    );
  }
}
