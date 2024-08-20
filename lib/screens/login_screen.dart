// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _isLoginButtonEnabled = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkFormCompletion);
    _passwordController.addListener(_checkFormCompletion);
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
              ElevatedButton(
                onPressed: _isLoginButtonEnabled
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          bool success = await authProvider.login(
                            _emailController.text,
                            _passwordController.text,
                          );
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
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
