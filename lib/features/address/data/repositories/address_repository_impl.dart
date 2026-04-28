import 'package:ecommerce_app/features/address/data/sources/address_remote_data_source.dart';
import 'package:ecommerce_app/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_app/features/address/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AddressEntity> createAddress({
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    final model = await remoteDataSource.createAddress(
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      address: address,
    );
    return model;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await remoteDataSource.deleteAddress(addressId);
  }

  @override
  Future<List<AddressEntity>> getAddresses() async {
    final models = await remoteDataSource.getAddresses();
    return models.cast<AddressEntity>();
  }

  @override
  Future<AddressEntity?> getDefaultAddress() async {
    final model = await remoteDataSource.getDefaultAddress();
    return model;
  }

  @override
  Future<AddressEntity> setDefaultAddress(String addressId) async {
    final model = await remoteDataSource.setDefaultAddress(addressId);
    return model;
  }

  @override
  Future<AddressEntity> updateAddress({
    required String addressId,
    required String receiverName,
    required String receiverPhone,
    required String address,
  }) async {
    final model = await remoteDataSource.updateAddress(
      addressId: addressId,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      address: address,
    );
    return model;
  }
}
