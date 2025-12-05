import 'package:shared_preferences/shared_preferences.dart';

// Kimlik doğrulama ve kullanıcı bilgilerini yönet
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Depolama anahtarları
  static const _kLoggedIn = 'is_logged_in';
  static const _kUsername = 'username';
  static const _kEmail = 'email';

  // Kullanıcı giriş yapıp yapmadığını kontrol et
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  // Giriş durumunu ayarla
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, value);
  }

  // Kullanıcı adını kaydet
  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, username);
  }

  // Kullanıcı adını getir
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsername) ?? 'Kullanıcı';
  }

  // E-posta kaydet
  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, email);
  }

  // E-posta getir
  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail) ?? 'user@example.com';
  }

  // Çıkış yap
  Future<void> logout() async {
    await setLoggedIn(false);
  }
}
