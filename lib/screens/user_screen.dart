// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print(
        'valor de authProvider (USER SCREEN): isAuthenticated: ${authProvider.isAuthenticated}, userId: ${authProvider.userId}, email: ${authProvider.email}, username: ${authProvider.username}, avatar: ${authProvider.avatar}');

    final db = await DatabaseService().database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [authProvider.userId],
      limit: 1,
    );

    if (result.isNotEmpty && result.first['biometry'] == null) {
      //mostrar el dialogo si la biometría no esta asociada
      await _checkBiometricEnrollment();
    }
  }

  Future<void> _checkBiometricEnrollment() async {
    final isBiometricAvailable = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();

    if (isBiometricAvailable && isDeviceSupported) {
      await _showBiometricDialog();
    }
  }

  Future<void> _showBiometricDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Asociar credenciales a la biometría'),
          content: const Text(
              '¿Desea asociar sus credenciales con la biometría de este dispositivo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _authenticateAndSaveCredentials();
    }
  }

  Future<void> _authenticateAndSaveCredentials() async {
    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Por favor autentícate para guardar tus credenciales.',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (didAuthenticate) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final bytes = utf8.encode(authProvider.email!);
      final biometryToken = sha256.convert(bytes).toString();

      await _storage.write(key: 'biometryToken', value: biometryToken);

      if (authProvider.password != null && authProvider.password!.isNotEmpty) {
        print('Guardando password: ${authProvider.password}');
        await _storage.write(key: 'password', value: authProvider.password);
      } else {
        print('Error: authProvider.password es null o vacío');
      }

      await _storage.write(key: 'email', value: authProvider.email);

      final db = await DatabaseService().database;
      await db.update(
        'users',
        {'biometry': biometryToken},
        where: 'id = ?',
        whereArgs: [authProvider.userId],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.username != null
              ? 'Nombre: ${authProvider.username}'
              : 'Usuario',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context, authProvider);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authProvider.avatar != null && authProvider.avatar!.isNotEmpty)
              CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(authProvider.avatar!)),
              )
            else
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showImageSourceActionSheet(context, authProvider);
              },
              child: const Text('Editar imagen'),
            ),
            const SizedBox(height: 20),
            if (authProvider.username != null)
              Text(
                'Bienvenido, ${authProvider.username}',
                style: const TextStyle(fontSize: 24),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showLogoutConfirmationDialog(context, authProvider);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/user');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/contacts');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contactos',
          ),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(
      BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar una foto'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);

                  if (pickedFile != null) {
                    await authProvider.updateAvatar(pickedFile.path);
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    await authProvider.updateAvatar(pickedFile.path);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(
      BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }
}
