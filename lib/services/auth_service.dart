import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kLoggedIn = 'is_logged_in';
  static const _kUsername = 'username';
  static const _kEmail = 'email';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, value);
  }

  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, username);
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsername) ?? 'Kullanıcı';
  }

  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, email);
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail) ?? 'user@example.com';
  }

  Future<void> logout() async {
    await setLoggedIn(false);
  }
}
