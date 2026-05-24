import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../globals.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../widgets/equipment_card.dart';
import 'equipment_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const SearchScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Equipment> _allEquipments = [];
  List<Equipment> _results = [];
  List<String> _recentSearches = [];
  Map<String, int> _categoryCounts = {};

  bool _isLoading = true;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadInitialSearchData();
  }

  Future<void> _loadInitialSearchData() async {
    final userId = currentUserEmailNotifier.value;

    final equipmentRows = await _db.getAvailableEquipments();
    final categoryCounts = await _db.getEquipmentCategoryCounts();

    final recent = userId == null ? <String>[] : await _db.getRecentSearches(userId);

    if (!mounted) return;

    setState(() {
      _allEquipments = equipmentRows.map(_equipmentFromDb).toList();
      _categoryCounts = categoryCounts;
      _recentSearches = recent;
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

  Future<void> _performSearch(String query, {bool saveHistory = false}) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    final lowerQuery = cleanQuery.toLowerCase();

    final filtered = _allEquipments.where((equipment) {
      return equipment.name.toLowerCase().contains(lowerQuery) ||
          equipment.category.toLowerCase().contains(lowerQuery) ||
          equipment.description.toLowerCase().contains(lowerQuery) ||
          equipment.location.toLowerCase().contains(lowerQuery) ||
          equipment.ownerName.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _results = filtered;
      _hasSearched = true;
    });

    if (saveHistory) {
      final userId = currentUserEmailNotifier.value;

      if (userId != null) {
        await _db.addSearchTerm(
          userId: userId,
          query: cleanQuery,
        );

        final recent = await _db.getRecentSearches(userId);

        if (!mounted) return;

        setState(() {
          _recentSearches = recent;
        });
      }
    }
  }

  Future<void> _clearRecentSearches() async {
    final userId = currentUserEmailNotifier.value;

    if (userId == null) return;

    await _db.clearSearchHistory(userId);

    if (!mounted) return;

    setState(() {
      _recentSearches = [];
    });
  }

  Future<void> _toggleFavorite(String id) async {
    await widget.onToggleFavorite(id);

    if (!mounted) return;

    setState(() {});
  }

  String _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tractores':
        return '🚜';
      case 'riego':
        return '💧';
      case 'cosechadoras':
        return '🌾';
      case 'sembradoras':
        return '🌱';
      default:
        return '⚙️';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Buscar', 'Search'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (value) => _performSearch(value),
                  onSubmitted: (value) => _performSearch(
                    value,
                    saveHistory: true,
                  ),
                  decoration: InputDecoration(
                    hintText: tr(
                      'Buscar equipo agrícola...',
                      'Search agricultural equipment...',
                    ),
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
          Expanded(
            child: _hasSearched ? _buildResults() : _buildSuggestions(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(bool isDark) {
    final popularSearches = _categoryCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadInitialSearchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('Búsquedas recientes', 'Recent searches'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: Text(tr('Limpiar', 'Clear')),
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
                    backgroundColor: isDark ? Colors.grey[800] : null,
                    onPressed: () {
                      _searchController.text = search;
                      _performSearch(search, saveHistory: true);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              tr('Búsquedas populares', 'Popular searches'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (popularSearches.isEmpty)
              Text(
                tr(
                  'Aún no hay equipos publicados para sugerir búsquedas.',
                  'There is no published equipment yet to suggest searches.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: popularSearches.map((search) {
                  return ActionChip(
                    avatar: const Icon(Icons.trending_up, size: 18),
                    label: Text(search),
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : AppTheme.primaryColor.withOpacity(0.1),
                    onPressed: () {
                      _searchController.text = search;
                      _performSearch(search, saveHistory: true);
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            Text(
              tr('Explorar por categoría', 'Explore by category'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_categoryCounts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.agriculture,
                        size: 56,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(
                          'No hay equipos disponibles todavía',
                          'No equipment available yet',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._categoryCounts.entries.map((entry) {
                final category = entry.key;
                final count = entry.value;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _iconForCategory(category),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(category),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey[800] : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  onTap: () {
                    _searchController.text = category;
                    _performSearch(category, saveHistory: true);
                  },
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return _results.isEmpty
        ? Center(
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
                  tr('No se encontraron resultados', 'No results found'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'Intenta con otros términos de búsqueda',
                    'Try other search terms',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        : GridView.builder(
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
                isFavorite: widget.favoriteIds.contains(equipment.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EquipmentDetailScreen(
                        equipment: equipment,
                        isFavorite: widget.favoriteIds.contains(equipment.id),
                        onToggleFavorite: () {
                          _toggleFavorite(equipment.id);
                        },
                      ),
                    ),
                  );
                },
                onFavoriteTap: () {
                  _toggleFavorite(equipment.id);
                },
              );
            },
          );
  }
}