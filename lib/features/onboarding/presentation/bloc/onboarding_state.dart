class OnboardingState {
  final int pageIndex;

  const OnboardingState({required this.pageIndex});

  OnboardingState copyWith({int? pageIndex}) {
    return OnboardingState(pageIndex: pageIndex ?? this.pageIndex);
  }
}
