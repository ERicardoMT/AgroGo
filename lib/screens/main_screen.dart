import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'bookings_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final Set<String> _favoriteIds = {};

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // DETECCIÓN DE TEMA

    final screens = [
      HomeScreen(
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
      ),
      const SearchScreen(),
      const BookingsScreen(),
      FavoritesScreen(
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05), // ADAPTACIÓN
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: tr('Inicio', 'Home'), // TRADUCCIÓN
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_outlined),
              activeIcon: const Icon(Icons.search),
              label: tr('Buscar', 'Search'), // TRADUCCIÓN
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: tr('Reservas', 'Bookings'), // TRADUCCIÓN
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              activeIcon: const Icon(Icons.favorite),
              label: tr('Favoritos', 'Favorites'), // TRADUCCIÓN
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: tr('Perfil', 'Profile'), // TRADUCCIÓN
            ),
          ],
        ),
      ),
    );
  }
}
