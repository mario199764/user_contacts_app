import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/session_manager.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final SessionManager _sessionManager = SessionManager();
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isAuthenticated = false;
  bool _autoLoggedOut = false;
  int? _userId;
  String? _email;
  String? _username;
  String? _avatar;
  String? _password;
  Timer? _sessionTimer;

  AuthProvider(this.navigatorKey);

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;
  String? get email => _email;
  String? get username => _username;
  String? get avatar => _avatar;
  String? get password => _password;
  bool get autoLoggedOut => _autoLoggedOut;

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
      startSessionTimer();
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
    return _isAuthenticated;
  }

  void startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: 2), () {
      _showSessionExpiredDialog();
    });
  }

  void _showSessionExpiredDialog() {
    Timer? autoLogoutTimer;

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        //temporizador de 10 segundos para cierre
        autoLogoutTimer = Timer(const Duration(seconds: 10), () {
          _autoLoggedOut = true;
          Navigator.of(navigatorKey.currentContext!).pushReplacementNamed('/');
          logout();
        });

        return AlertDialog(
          title: const Text('Sesión expirada'),
          content: const Text(
              'Tu sesión está a punto de expirar. ¿Deseas renovarla o cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                autoLogoutTimer?.cancel(); //cancela el temporizador
                Navigator.of(navigatorKey.currentContext!)
                    .pushReplacementNamed('/');
                logout();
              },
              child: const Text('Cerrar sesión'),
            ),
            TextButton(
              onPressed: () {
                autoLogoutTimer?.cancel();
                _autoLoggedOut = false;
                startSessionTimer(); //reinicia el temporizador
                Navigator.of(context).pop();
              },
              child: const Text('Renovar sesión'),
            ),
          ],
        );
      },
    );
  }

  void resetAutoLoggedOutFlag() {
    _autoLoggedOut = false;
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
    _userId = null;
    _email = null;
    _username = null;
    _avatar = null;
    _sessionTimer?.cancel();
    await _sessionManager.clearSession();
    notifyListeners();
  }

  Future<void> checkSession() async {
    _isAuthenticated = await _sessionManager.isLoggedIn();
    if (_isAuthenticated) {
      _email = await _sessionManager.getUserEmail();
      //si hay una sesion activa inicia el temporizador
      startSessionTimer();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
