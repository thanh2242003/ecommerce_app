import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponseModel extends Equatable {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['shop'] ?? json['user']),
      accessToken: json['tokens']['accessToken'],
      refreshToken: json['tokens']['refreshToken'],
    );
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}