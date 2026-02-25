import 'package:ecommerce_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState(pageIndex: 0));

  void changePage(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void nextPage() {
    emit(state.copyWith(pageIndex: state.pageIndex + 1));
  }

  void previousPage() {
    if (state.pageIndex > 0) {
      emit(state.copyWith(pageIndex: state.pageIndex - 1));
    }
  }
}
