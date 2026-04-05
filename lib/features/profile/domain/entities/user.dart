class UserEntity {
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? avatar;
  final String status;
  final bool verify;
  final List<String> roles;

  UserEntity({
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.avatar,
    required this.status,
    required this.verify,
    required this.roles,
  });
}
