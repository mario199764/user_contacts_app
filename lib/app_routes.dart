import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_screen.dart';
import 'screens/contacts_screen.dart';

class AppRoutes {
  static const String initialRoute = '/';
  static const String register = '/register';
  static const String user = '/user';
  static const String contacts = '/contacts';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initialRoute: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      user: (context) => UserScreen(),
      contacts: (context) => ContactsScreen(),
    };
  }
}
