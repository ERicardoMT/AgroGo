import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../globals.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../widgets/equipment_card.dart';
import 'equipment_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;
  const FavoritesScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  bool _isLoading = true;
  List<Equipment> _favoriteEquipment = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // --- CORRECCIÓN: Actualiza los favoritos al entrar a la pestaña ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteIds.length != widget.favoriteIds.length ||
        oldWidget.favoriteIds.difference(widget.favoriteIds).isNotEmpty ||
        widget.favoriteIds.difference(oldWidget.favoriteIds).isNotEmpty) {
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    final userId = currentUserEmailNotifier.value;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _favoriteEquipment = [];
        _isLoading = false;
      });
      return;
    }

    final rows = await _db.getFavoriteEquipmentsForUser(userId);
    final parsed = rows.map(_equipmentFromDb).toList();

    if (!mounted) return;
    setState(() {
      _favoriteEquipment = parsed;
      _isLoading = false;
    });
  }

  Equipment _equipmentFromDb(Map<String, dynamic> row) {
    Map<String, String> parsedSpecs = {};
    final rawSpecs = row['specs']?.toString();
    if (rawSpecs != null && rawSpecs.trim().isNotEmpty) {
      try {
        parsedSpecs = Map<String, String>.from(jsonDecode(rawSpecs));
      } catch (_) {
        parsedSpecs = {};
      }
    }

    final image = row['images']?.toString() ?? '';
    return Equipment(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? 'Sin nombre',
      category: row['category']?.toString() ?? 'General',
      description: row['description']?.toString() ?? '',
      location: row['location']?.toString() ?? 'Sin ubicación',
      pricePerDay: (row['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      pricePerWeek: (row['pricePerWeek'] as num?)?.toDouble() ?? 0.0,
      pricePerMonth: (row['pricePerMonth'] as num?)?.toDouble() ?? 0.0,
      rating: (row['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (row['reviewCount'] as int?) ?? 0,
      available: row['available'] == 1,
      ownerId: row['ownerId']?.toString() ?? '',
      ownerName: row['ownerName']?.toString() ?? 'Arrendador',
      images: image.isNotEmpty ? [image] : [],
      specs: parsedSpecs,
    );
  }

  Future<void> _handleFavoriteTap(String equipmentId) async {
    await widget.onToggleFavorite(equipmentId);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    // --- MAGIA AQUÍ: Envuelve todo en el escuchador de idioma ---
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, idioma, child) {
        if (_isLoading) {
          return const SafeArea(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('Favoritos', 'Favorites'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        '${_favoriteEquipment.length} equipos guardados',
                        '${_favoriteEquipment.length} saved equipment',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _favoriteEquipment.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(), // Asegura que siempre se pueda deslizar hacia abajo
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: _favoriteEquipment.length,
                          itemBuilder: (context, index) {
                            final equipment = _favoriteEquipment[index];
                            return EquipmentCard(
                              equipment: equipment,
                              isFavorite: widget.favoriteIds.contains(equipment.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EquipmentDetailScreen(
                                      equipment: equipment,
                                      isFavorite: widget.favoriteIds.contains(equipment.id),
                                      onToggleFavorite: () {
                                        _handleFavoriteTap(equipment.id);
                                      },
                                    ),
                                  ),
                                );
                              },
                              onFavoriteTap: () {
                                _handleFavoriteTap(equipment.id);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  tr('Sin favoritos aún', 'No favorites yet'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    tr(
                      'Guarda tus equipos favoritos para acceder rápidamente',
                      'Save your favorite equipment to access quickly',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}