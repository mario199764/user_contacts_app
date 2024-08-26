import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userEmailKey = "userEmail";
  static const String _expirationKey = "sessionExpiration";

  Future<void> createSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);

    //tiempo de expiracion de 2 minutos
    final expirationTime =
        DateTime.now().add(const Duration(minutes: 2)).toIso8601String();
    await prefs.setString(_expirationKey, expirationTime);

    print('Session stored with expiration for: $email');
  }

  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expirationString = prefs.getString(_expirationKey);

    if (expirationString == null) {
      return true;
    }

    final expirationTime = DateTime.parse(expirationString);
    return DateTime.now().isAfter(expirationTime);
  }

  Future<bool> isLoggedIn() async {
    if (await isSessionExpired()) {
      //limpiar sesion si ha expirado
      await clearSession();
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userEmailKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_expirationKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
}
