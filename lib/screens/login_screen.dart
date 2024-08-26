// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isLoginButtonEnabled = false;
  bool _isPasswordVisible = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkFormCompletion);
    _passwordController.addListener(_checkFormCompletion);
    _checkBiometricOption();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAutoLogout();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkFormCompletion() {
    final isFormComplete =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    setState(() {
      _isLoginButtonEnabled = isFormComplete;
    });
  }

  Future<void> _checkBiometricOption() async {
    final biometryToken = await _storage.read(key: 'biometryToken');
    if (biometryToken != null) {
      setState(() {
        _isBiometricAvailable = true;
      });
    }
  }

  Future<void> _checkAutoLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.autoLoggedOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAutoLogoutDialog();
        authProvider.resetAutoLoggedOutFlag();
      });
    }
  }

  Future<void> _showAutoLogoutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sesión cerrada por inactividad'),
          content: const Text(
              'Tu sesión se cerró automáticamente debido a inactividad. Por favor, vuelve a iniciar sesión.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginWithBiometrics() async {
    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Autentícate para ingresar con biometría.',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (didAuthenticate) {
      final email = await _storage.read(key: 'email');
      final password = await _storage.read(key: 'password');

      if (email != null && password != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success = await authProvider.login(email, password);
        if (success) {
          Navigator.pushReplacementNamed(context, '/user');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falló la autenticación biométrica')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se encontraron credenciales almacenadas')),
        );
      }
    } else {
      print("Autenticación biométrica fallida o cancelada");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor introduzca un email válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50, //altura para todos los botones
                child: ElevatedButton(
                  onPressed: _isLoginButtonEnabled
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await authProvider.login(
                                _emailController.text,
                                _passwordController.text);
                            if (success) {
                              Navigator.pushReplacementNamed(context, '/user');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Credenciales no válidas')),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('Ingreso'),
                ),
              ),
              const SizedBox(height: 10),
              if (_isBiometricAvailable)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loginWithBiometrics,
                    child: const Text('Biometría'),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Registro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
