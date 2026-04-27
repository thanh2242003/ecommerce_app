import 'package:ecommerce_app/features/address/domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> createAddress({
    required String receiverName,
    required String receiverPhone,
    required String address,
  });
  Future<AddressEntity> updateAddress({
    required String addressId,
    required String receiverName,
    required String receiverPhone,
    required String address,
  });
  Future<AddressEntity> setDefaultAddress(String addressId);
  Future<void> deleteAddress(String addressId);
  Future<AddressEntity?> getDefaultAddress();
}
