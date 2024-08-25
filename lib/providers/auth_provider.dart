import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final SessionManager _sessionManager = SessionManager();
  bool _isAuthenticated = false;
  int? _userId;
  String? _email;
  String? _username;
  String? _avatar;
  String? _password;

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;
  String? get email => _email;
  String? get username => _username;
  String? get avatar => _avatar;
  String? get password => _password;

  Future<bool> login(String email, String password) async {
    final user = await _databaseService.validateUser(email, password);
    if (user != null) {
      _isAuthenticated = true;
      _userId = user['id'];
      _email = user['email'];
      _username = user['username'];
      _avatar = user['avatar'];
      _password = user['password'];
      await _sessionManager.createSession(email);
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> updateAvatar(String newPath) async {
    if (_email != null) {
      await _databaseService.updateAvatar(_email!, newPath);
      _avatar = newPath;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _email = null;
    _username = null;
    _avatar = null;
    await _sessionManager.clearSession();
    notifyListeners();
  }

  Future<void> checkSession() async {
    _isAuthenticated = await _sessionManager.isLoggedIn();
    if (_isAuthenticated) {
      _email = await _sessionManager.getUserEmail();
    }
    notifyListeners();
  }
}
