import 'package:flutter/material.dart';

// 1. Controladores globales
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<String> languageNotifier = ValueNotifier('Español');

// 2. Función traductora global (accesible desde cualquier archivo)
String tr(String espanol, String ingles) {
  return languageNotifier.value == 'Español' ? espanol : ingles;
}