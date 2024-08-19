import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userEmailKey = "userEmail";

  Future<void> createSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    print(
        'Session stored in SharedPreferences for: $email'); // Verifica que la sesión se almacena

    // Imprime todo lo que hay en SharedPreferences
    print('SharedPreferences content after createSession:');
    prefs.getKeys().forEach((key) {
      print('$key: ${prefs.get(key)}');
    });
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    print(
        'Session removed from SharedPreferences'); // Verifica que la sesión fue eliminada de SharedPreferences

    // Imprime todo lo que hay en SharedPreferences
    print('SharedPreferences content after clearSession:');
    prefs.getKeys().forEach((key) {
      print('$key: ${prefs.get(key)}');
    });
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.containsKey(_userEmailKey);
    print(
        'isLoggedIn called, session exists: $exists'); // Verifica si la clave de sesión existe
    return exists;
  }
}
