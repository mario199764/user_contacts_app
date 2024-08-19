// ignore_for_file: use_build_context_synchronously

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
      return 'El nombre de usuario es obligatorio';
    } else if (value.length < 4 || value.length > 50) {
      return 'El nombre de usuario debe tener entre 4 y 50 caracteres';
    } else if (!usernameRegex.hasMatch(value)) {
      return 'El nombre de usuario solo puede contener letras';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (value == null || value.isEmpty) {
      return 'Email es requerido';
    } else if (value.length < 6 || value.length > 50) {
      return 'Email debe tener entre 6 y 50 caracteres';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Introduzca email válida';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{10,60}$');
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    } else if (value.length < 10 || value.length > 60) {
      return 'La contraseña debe tener entre 10 y 60 caracteres';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'La contraseña debe contener caracteres superiores, inferiores, numéricos y especiales';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirme su contraseña';
    } else if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> user = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      int result = await _databaseService.addUser(user);

      if (result != -1) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error al registrar usuario. Por favor inténtalo de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de usuario'),
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
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: !_isPasswordVisible,
                validator: validatePassword,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirmar Contraseña'),
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
                  const Text('Mostrar contraseñas'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
