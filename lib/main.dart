import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'app_routes.dart';

void main() {
  // Inicialización condicional de sqflite para plataformas no móviles
  if (kIsWeb ||
      (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS))) {
    // No se necesita ninguna inicialización especial para Android o iOS
  } else {
    // Inicialización necesaria para plataformas de escritorio o tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //GlobalKey NavigatorState global
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(MyApp.navigatorKey)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'User Contacts App',
            theme:
                themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            navigatorKey: navigatorKey,
            initialRoute: AppRoutes.initialRoute,
            routes: AppRoutes.getRoutes(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
