import 'package:equatable/equatable.dart';

abstract class AppStartState extends Equatable{
  const AppStartState();

  @override
  List<Object> get props => [];
}

class AppStartLoading extends AppStartState {}

class AppStartOnboarding extends AppStartState {}

class AppStartAuthenticated extends AppStartState {}

class AppStartUnauthenticated extends AppStartState {}