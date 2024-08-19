import 'package:flutter/material.dart';
import '../services/database_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateUsername(String? value) {
    final usernameRegex = RegExp(r'^[a-zA-Z]+$');
    if (value == null || value.isEmpty) {
      return 'Username is required';
    } else if (value.length < 4 || value.length > 50) {
      return 'Username must be between 4 and 50 characters';
    } else if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (value.length < 6 || value.length > 50) {
      return 'Email must be between 6 and 50 characters';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{10,60}$');
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 10 || value.length > 60) {
      return 'Password must be between 10 and 60 characters';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain upper, lower, number, and special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Crear el usuario como un Map
      Map<String, dynamic> user = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      // Intentar agregar el usuario a la base de datos
      int result = await _databaseService.addUser(user);

      if (result != -1) {
        // Registro exitoso, navegar a la pantalla de login
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // Error al registrar el usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering user. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: validateUsername,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: !_isPasswordVisible,
                validator: validatePassword,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: !_isPasswordVisible,
                validator: validateConfirmPassword,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isPasswordVisible,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPasswordVisible = value!;
                      });
                    },
                  ),
                  const Text('Show Passwords'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
