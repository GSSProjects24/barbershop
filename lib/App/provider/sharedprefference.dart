// lib/App/data/provider/shared_pref_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _fullNameKey = 'full_name';
  static const String _emailKey = 'email';
  static const String _isSuperAdminKey = 'is_super_admin';
  static const String _branchNameKey = 'branch_name'; // ✅ NEW
  static const String _branchIdKey = 'branch_id'; // ✅ NEW (optional)

  // Singleton instance
  static final SharedPrefService _instance = SharedPrefService._internal();
  static SharedPrefService get instance => _instance;

  SharedPrefService._internal();

  late SharedPreferences _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ✅ UPDATED: Save login data with branch info
  Future<bool> saveLoginData({
    required String token,
    required int userId,
    String? username,
    String? fullName,
    String? email,
    bool? isSuperAdmin,
    String? branchName, // ✅ NEW
    int? branchId, // ✅ NEW
  }) async {
    try {
      await _prefs.setString(_tokenKey, token);
      await _prefs.setInt(_userIdKey, userId);

      if (username != null) await _prefs.setString(_usernameKey, username);
      if (fullName != null) await _prefs.setString(_fullNameKey, fullName);
      if (email != null) await _prefs.setString(_emailKey, email);
      if (isSuperAdmin != null) await _prefs.setBool(_isSuperAdminKey, isSuperAdmin);

      // ✅ NEW: Save branch data
      if (branchName != null) await _prefs.setString(_branchNameKey, branchName);
      if (branchId != null) await _prefs.setInt(_branchIdKey, branchId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // Get user ID
  int? getUserId() {
    return _prefs.getInt(_userIdKey);
  }

  // Get username
  String? getUsername() {
    return _prefs.getString(_usernameKey);
  }

  // Get full name
  String? getFullName() {
    return _prefs.getString(_fullNameKey);
  }

  // Get email
  String? getEmail() {
    return _prefs.getString(_emailKey);
  }

  // Check if user is super admin
  bool isSuperAdmin() {
    return _prefs.getBool(_isSuperAdminKey) ?? false;
  }

  // ✅ NEW: Get branch name
  String? getBranchName() {
    return _prefs.getString(_branchNameKey);
  }

  // ✅ NEW: Get branch ID
  int? getBranchId() {
    return _prefs.getInt(_branchIdKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getString(_tokenKey) != null;
  }

  // ✅ UPDATED: Include branch info
  Map<String, dynamic> getAllStoredData() {
    return {
      'token': getToken(),
      'user_id': getUserId(),
      'username': getUsername(),
      'full_name': getFullName(),
      'email': getEmail(),
      'is_super_admin': isSuperAdmin(),
      'branch_name': getBranchName(), // ✅ NEW
      'branch_id': getBranchId(), // ✅ NEW
      'is_logged_in': isLoggedIn(),
    };
  }

  // ✅ UPDATED: Clear all data including branch
  Future<bool> clearAll() async {
    try {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userIdKey);
      await _prefs.remove(_usernameKey);
      await _prefs.remove(_fullNameKey);
      await _prefs.remove(_emailKey);
      await _prefs.remove(_isSuperAdminKey);
      await _prefs.remove(_branchNameKey); // ✅ NEW
      await _prefs.remove(_branchIdKey); // ✅ NEW
      return true;
    } catch (e) {
      return false;
    }
  }
}