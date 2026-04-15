import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../widgets/equipment_card.dart';
import 'equipment_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Equipment> _results = [];
  bool _hasSearched = false;
  final Set<String> _favorites = {};

  final List<String> _recentSearches = [
    'Tractor John Deere',
    'Sistema de riego',
    'Cosechadora',
  ];

  final List<String> _popularSearches = [
    'Tractores 4WD',
    'Drones fumigación',
    'Cosechadoras maíz',
    'Pivotes riego',
  ];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _results = MockData.equipmentList
          .where((e) =>
              e.name.toLowerCase().contains(query.toLowerCase()) ||
              e.category.toLowerCase().contains(query.toLowerCase()) ||
              e.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buscar',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: _performSearch,
                  decoration: InputDecoration(
                    hintText: 'Buscar equipo agrícola...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _hasSearched ? _buildResults() : _buildSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Búsquedas recientes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    // Clear recent searches
                  },
                  child: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return ActionChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(search),
                  onPressed: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Searches
          Text(
            'Búsquedas populares',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return ActionChip(
                avatar: const Icon(Icons.trending_up, size: 18),
                label: Text(search),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Categories
          Text(
            'Explorar por categoría',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...MockData.categories.map((category) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              title: Text(category.name),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.count}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              onTap: () {
                _searchController.text = category.name;
                _performSearch(category.name);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros términos de búsqueda',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final equipment = _results[index];
        return EquipmentCard(
          equipment: equipment,
          isFavorite: _favorites.contains(equipment.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EquipmentDetailScreen(
                  equipment: equipment,
                  isFavorite: _favorites.contains(equipment.id),
                  onToggleFavorite: () {
                    setState(() {
                      if (_favorites.contains(equipment.id)) {
                        _favorites.remove(equipment.id);
                      } else {
                        _favorites.add(equipment.id);
                      }
                    });
                  },
                ),
              ),
            );
          },
          onFavoriteTap: () {
            setState(() {
              if (_favorites.contains(equipment.id)) {
                _favorites.remove(equipment.id);
              } else {
                _favorites.add(equipment.id);
              }
            });
          },
        );
      },
    );
  }
}
