import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../globals.dart';
import 'bookings_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  int _currentIndex = 0;
  final Set<String> _favoriteIds = {};
  bool _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final currentUser = currentUserEmailNotifier.value;

    if (currentUser == null) {
      if (!mounted) return;
      setState(() => _loadingFavorites = false);
      return;
    }

    final ids = await _db.getFavoriteIdsForUser(currentUser);

    if (!mounted) return;

    setState(() {
      _favoriteIds
        ..clear()
        ..addAll(ids);
      _loadingFavorites = false;
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final currentUser = currentUserEmailNotifier.value;

    if (currentUser == null) return;

    final updatedFavorites = await _db.toggleFavoriteEquipment(
      userId: currentUser,
      equipmentId: id,
    );

    if (!mounted) return;

    setState(() {
      _favoriteIds
        ..clear()
        ..addAll(updatedFavorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loadingFavorites) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screens = [
      HomeScreen(
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onSearchTap: () => setState(() => _currentIndex = 1),
      ),
      SearchScreen(
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
      ),
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
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
              label: tr('Inicio', 'Home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_outlined),
              activeIcon: const Icon(Icons.search),
              label: tr('Buscar', 'Search'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: tr('Reservas', 'Bookings'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              activeIcon: const Icon(Icons.favorite),
              label: tr('Favoritos', 'Favorites'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: tr('Perfil', 'Profile'),
            ),
          ],
        ),
      ),
    );
  }
}