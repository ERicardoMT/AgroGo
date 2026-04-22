import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/equipment_card.dart';
import 'equipment_detail_screen.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL

class FavoritesScreen extends StatelessWidget {
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteEquipment = MockData.equipmentList
        .where((e) => favoriteIds.contains(e.id))
        .toList();
        
    final isDark = Theme.of(context).brightness == Brightness.dark; // <--- DETECCIÓN DE TEMA

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
                  tr('Favoritos', 'Favorites'), // TRADUCCIÓN
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  tr('${favoriteEquipment.length} equipos guardados', '${favoriteEquipment.length} saved equipment'), // TRADUCCIÓN
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: favoriteEquipment.isEmpty
                ? _buildEmptyState(context)
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: favoriteEquipment.length,
                    itemBuilder: (context, index) {
                      final equipment = favoriteEquipment[index];
                      return EquipmentCard(
                        equipment: equipment,
                        isFavorite: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EquipmentDetailScreen(
                                equipment: equipment,
                                isFavorite: true,
                                onToggleFavorite: () =>
                                    onToggleFavorite(equipment.id),
                              ),
                            ),
                          );
                        },
                        onFavoriteTap: () => onToggleFavorite(equipment.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
            tr('Sin favoritos aún', 'No favorites yet'), // TRADUCCIÓN
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              tr('Guarda tus equipos favoritos para acceder rápidamente', 'Save your favorite equipment to access quickly'), // TRADUCCIÓN
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
