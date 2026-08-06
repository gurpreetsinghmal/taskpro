import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskpro/services/storage_keys.dart';

class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(),
  );



  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await read(StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }
  Future<String?> getAccessToken() async{
    final token = await read(StorageKeys.accessToken);
    return token;
  }
}