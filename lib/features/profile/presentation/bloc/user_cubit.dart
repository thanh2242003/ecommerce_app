import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user.dart';
import '../../domain/usecases/update_user.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUserUseCase getUserUseCase;
  final UpdateUserUseCase updateUserUseCase;

  UserCubit({required this.getUserUseCase, required this.updateUserUseCase})
    : super(UserInitial());

  Future<void> getUser({
    required String token,
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      if (state is UserLoading) {
        return;
      }

      if (state is UserLoaded) {
        return;
      }
    }

    try {
      emit(UserLoading());
      final user = await getUserUseCase(token: token, userId: userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<UserEntity?> updateUser({
    required String token,
    required String userId,
    required String name,
    required String phone,
    required String address,
    String? avatar,
    String? avatarFilePath,
  }) async {
    try {
      final user = await updateUserUseCase(
        token: token,
        userId: userId,
        name: name,
        phone: phone,
        address: address,
        avatar: avatar,
        avatarFilePath: avatarFilePath,
      );
      emit(UserLoaded(user));
      return user;
    } catch (e) {
      emit(UserError(e.toString()));
      return null;
    }
  }
}
