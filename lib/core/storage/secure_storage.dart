import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_environment.dart';

class SecureStorage {
  SecureStorage._() : _storage = const FlutterSecureStorage();

  static final SecureStorage instance = SecureStorage._();
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'ethiofund_jwt_token';
  static const String _userKey = 'ethiofund_user_data';
  static const String _roleKey = 'ethiofund_user_role';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<void> saveUser(String userJson) => _storage.write(key: _userKey, value: userJson);

  Future<String?> getUser() => _storage.read(key: _userKey);

  Future<void> saveRole(String role) => _storage.write(key: _roleKey, value: role);

  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<void> clearAll() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage.instance;
});