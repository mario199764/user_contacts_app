import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.username != null
              ? 'Name: ${authProvider.username}'
              : 'User',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showImageSourceActionSheet(context, authProvider);
              },
              child: Text('Edit Image'),
            ),
            SizedBox(height: 20),
            if (authProvider.username != null)
              Text(
                'Welcome, ${authProvider.username}',
                style: TextStyle(fontSize: 24),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showLogoutConfirmationDialog(context, authProvider);
              },
              child: Text('Logout'),
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
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
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
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
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
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
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
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
