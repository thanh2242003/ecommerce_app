import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUserUseCase getUserUseCase;

  UserCubit(this.getUserUseCase) : super(UserLoading());

  void getUser({
    required String token,
    required String userId,
  }) async {
    try {
      emit(UserLoading());
      final user = await getUserUseCase.call(
        token: token,
        userId: userId,
      );
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}