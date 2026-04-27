import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_app/features/address/domain/repositories/address_repository.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;

  AddressCubit({required this.repository}) : super(AddressInitial());

  Future<void> getAddresses() async {
    emit(AddressLoading());
    try {
      final addresses = await repository.getAddresses();
      AddressEntity? defaultAddress;
      for (final address in addresses) {
        if (address.isDefault) {
          defaultAddress = address;
          break;
        }
      }

      emit(AddressLoaded(defaultAddress: defaultAddress, addresses: addresses));
    } catch (e) {
      emit(AddressFailure(message: e.toString()));
    }
  }

  Future<void> createAddress({
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    try {
      await repository.createAddress(
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        address: address,
      );

      // Reload addresses after creating
      await getAddresses();
    } catch (e) {
      emit(AddressFailure(message: e.toString()));
    }
  }

  Future<void> updateAddress({
    required String addressId,
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    try {
      await repository.updateAddress(
        addressId: addressId,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        address: address,
      );

      // Reload addresses after updating
      await getAddresses();
    } catch (e) {
      emit(AddressFailure(message: e.toString()));
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      await repository.setDefaultAddress(addressId);

      // Reload addresses after setting default.
      await getAddresses();
    } catch (e) {
      emit(AddressFailure(message: e.toString()));
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await repository.deleteAddress(addressId);

      // Reload addresses after deleting
      await getAddresses();
    } catch (e) {
      emit(AddressFailure(message: e.toString()));
    }
  }
}
