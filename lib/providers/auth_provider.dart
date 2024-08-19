import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final SessionManager _sessionManager = SessionManager();
  bool _isAuthenticated = false;
  String? _username;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get email => _email;

  Future<bool> login(String email, String password) async {
    final user = await _databaseService.validateUser(email, password);
    if (user != null) {
      _isAuthenticated = true;
      _email = user['email'];
      _username = user['username'];
      await _sessionManager.createSession(email); // Crear sesión
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _email = null;
    _username = null;
    await _sessionManager.clearSession(); // Borrar sesión
    notifyListeners();
  }

  Future<void> checkSession() async {
    _isAuthenticated = await _sessionManager.isLoggedIn();
    if (_isAuthenticated) {
      _email = await _sessionManager.getUserEmail();
      // También podrías querer recuperar el username si lo almacenas en sessionManager
    }
    notifyListeners();
  }
}
