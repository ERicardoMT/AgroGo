import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/equipment_card.dart';
import '../widgets/category_chip.dart';
import 'equipment_detail_screen.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL

class HomeScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const HomeScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredEquipment = selectedCategory == null
        ? MockData.equipmentList
        : MockData.equipmentList
            .where((e) => e.category == selectedCategory)
            .toList();
            
    final isDark = Theme.of(context).brightness == Brightness.dark; // <--- DETECTOR DE TEMA

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Hola, ${MockData.currentUser.name.split(' ')[0]}', 'Hello, ${MockData.currentUser.name.split(' ')[0]}'), // TRADUCCIÓN
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              MockData.currentUser.location,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), // ADAPTACIÓN
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: isDark ? Colors.white : AppTheme.textPrimary, // ADAPTACIÓN
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  // Navigate to search
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), // ADAPTACIÓN
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tr('Buscar equipo agrícola...', 'Search agricultural equipment...'), // TRADUCCIÓN
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Categories
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    tr('Categorías', 'Categories'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: MockData.categories.length,
                    itemBuilder: (context, index) {
                      final category = MockData.categories[index];
                      final isSelected = selectedCategory == category.name;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CategoryChip(
                          category: category,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedCategory =
                                  isSelected ? null : category.name;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Equipment List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory ?? tr('Equipo Disponible', 'Available Equipment'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    tr('${filteredEquipment.length} equipos', '${filteredEquipment.length} equipment'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Equipment Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final equipment = filteredEquipment[index];
                  return EquipmentCard(
                    equipment: equipment,
                    isFavorite: widget.favoriteIds.contains(equipment.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentDetailScreen(
                            equipment: equipment,
                            isFavorite:
                                widget.favoriteIds.contains(equipment.id),
                            onToggleFavorite: () =>
                                widget.onToggleFavorite(equipment.id),
                          ),
                        ),
                      );
                    },
                    onFavoriteTap: () => widget.onToggleFavorite(equipment.id),
                  );
                },
                childCount: filteredEquipment.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
