import 'package:flutter/material.dart';

// Control global de tema.
// Optimización local: ValueNotifier evita meter un gestor de estado grande
// para un proyecto que todavía maneja cambios sencillos de UI.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Control global de idioma.
final ValueNotifier<String> languageNotifier = ValueNotifier('Español');

// Control simple de sesión.
// Optimización de flujo: con este notifier no recreamos toda la arquitectura;
// solo cambiamos entre LoginScreen y MainScreen desde main.dart.
final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);

// Control del rol del usuario.
// 'rentador' para usuarios que rentan, 'arrendador' para propietarios.
final ValueNotifier<String> userRoleNotifier = ValueNotifier('rentador');

// ID o Email del usuario que tiene la sesión activa.
final ValueNotifier<String?> currentUserEmailNotifier = ValueNotifier(null);

final ValueNotifier<bool> notificationsNotifier = ValueNotifier(true);


// Traductor global usado por las pantallas actuales.
String tr(String espanol, String ingles) {
  return languageNotifier.value == 'Español' ? espanol : ingles;
}