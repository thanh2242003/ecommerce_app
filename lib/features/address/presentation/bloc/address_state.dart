part of 'address_cubit.dart';

sealed class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final AddressEntity? defaultAddress;
  final List<AddressEntity> addresses;

  AddressLoaded({required this.defaultAddress, required this.addresses});
}

class AddressFailure extends AddressState {
  final String message;

  AddressFailure({required this.message});
}
