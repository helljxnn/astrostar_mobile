import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // En web usamos SharedPreferences (secure storage no funciona en web)
  FlutterSecureStorage? get _secureStorage =>
      kIsWeb ? null : const FlutterSecureStorage();
  SharedPreferences? _prefs;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ========== ACCESS TOKEN ==========
  Future<void> saveAccessToken(String token) async {
    if (kIsWeb) {
      await init();
      await _prefs!.setString(_accessTokenKey, token);
    } else {
      await _secureStorage!.write(key: _accessTokenKey, value: token);
    }
  }

  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      await init();
      return _prefs!.getString(_accessTokenKey);
    }
    return await _secureStorage!.read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    if (kIsWeb) {
      await init();
      await _prefs!.remove(_accessTokenKey);
    } else {
      await _secureStorage!.delete(key: _accessTokenKey);
    }
  }

  // ========== REFRESH TOKEN ==========
  Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      await init();
      await _prefs!.setString(_refreshTokenKey, token);
    } else {
      await _secureStorage!.write(key: _refreshTokenKey, value: token);
    }
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      await init();
      return _prefs!.getString(_refreshTokenKey);
    }
    return await _secureStorage!.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    if (kIsWeb) {
      await init();
      await _prefs!.remove(_refreshTokenKey);
    } else {
      await _secureStorage!.delete(key: _refreshTokenKey);
    }
  }

  // ========== USER DATA ==========
  Future<void> saveUser(User user) async {
    await init();
    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
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
    await deleteRefreshToken();
    await deleteUser();
  }

  // ========== HELPERS ==========
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && user != null;
  }
}
