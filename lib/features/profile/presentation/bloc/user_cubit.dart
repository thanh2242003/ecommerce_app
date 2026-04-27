import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUserUseCase getUserUseCase;

  UserCubit(this.getUserUseCase) : super(UserInitial());

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
}
