import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'globals.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/landlord_main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_ES', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AgroGoApp());
}

class AgroGoApp extends StatelessWidget {
  const AgroGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, currentLang, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: isLoggedInNotifier,
              builder: (context, isLoggedIn, child) {
                return ValueListenableBuilder<String>(
                  valueListenable: userRoleNotifier,
                  builder: (context, userRole, child) {
                    return MaterialApp(
                      key: ValueKey(
                          '$currentLang-$currentMode-$isLoggedIn-$userRole'),
                      title: 'AgroGo',
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: currentMode,
                      home: isLoggedIn
                          ? (userRole == 'arrendador'
                              ? const LandlordMainScreen()
                              : const MainScreen())
                          : const LoginScreen(),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}