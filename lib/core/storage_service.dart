import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _userKey = 'user_data';

  // Inicializar SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ========== ACCESS TOKEN (Memoria Segura) ==========
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }

  // ========== USER DATA (SharedPreferences) ==========
  Future<void> saveUser(User user) async {
    await init();
    final userJson = jsonEncode(user.toJson());
    await _prefs!.setString(_userKey, userJson);
  }

  Future<User?> getUser() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    await init();
    await _prefs!.remove(_userKey);
  }

  // ========== CLEAR ALL ==========
  Future<void> clearAll() async {
    await deleteAccessToken();
    await deleteUser();
  }

  // ========== HELPERS ==========
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && user != null;
  }
}
