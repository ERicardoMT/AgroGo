import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../models/landlord_equipment.dart';
import '../models/implement.dart';
import '../data/database_helper.dart';
import 'equipment_form_screen.dart';

class FleetManagementScreen extends StatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> {
  List<LandlordEquipment> equipment = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquipmentFromDB();
  }

  Future<void> _loadEquipmentFromDB() async {
    final dbHelper = DatabaseHelper();
    final allEquipments = await dbHelper.getAll('landlord_equipments');
    
    setState(() {
      equipment = allEquipments.map((map) {
        // Debemos decodificar implements si existe
        List<Implement>? implementsList;
        if (map['implements'] != null) {
          try {
             final List decoded = jsonDecode(map['implements'].toString());
             implementsList = decoded.map((e) => Implement.fromJson(e)).toList();
          } catch(e) {}
        }
        
        List<String>? imgList;
        if (map['imageUrls'] != null) {
           try {
             final List decoded = jsonDecode(map['imageUrls'].toString());
             imgList = List<String>.from(decoded);
           } catch(e) {}
        }
        
        return LandlordEquipment(
          id: map['id'].toString(),
          name: map['name'].toString(),
          brand: map['brand'].toString(),
          model: map['model'].toString(),
          year: map['year'] != null ? map['year'] as int : 2020,
          power: (map['power'] as num?)?.toDouble() ?? 0.0,
          transmission: map['transmission'].toString(),
          traction: map['traction'].toString(),
          usageHours: (map['usageHours'] as num?)?.toDouble() ?? 0.0,
          isActive: map['isActive'] == 1,
          condition: map['condition']?.toString(),
          hourlyRate: (map['hourlyRate'] ?? map['dailyRate'] as num?)?.toDouble(),
          createdAt: DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
          lastMaintenanceDate: map['lastMaintenanceDate'] != null ? DateTime.tryParse(map['lastMaintenanceDate'].toString()) : null,
          imageUrls: imgList,
          implements: implementsList,
        );
      }).toList();
      isLoading = false;
    });
  }

Future<void> _saveEquipmentToDB(LandlordEquipment eq) async {
  final dbHelper = DatabaseHelper();

  final landlordMap = {
    'id': eq.id,
    'name': eq.name,
    'brand': eq.brand,
    'model': eq.model,
    'year': eq.year,
    'power': eq.power,
    'transmission': eq.transmission,
    'traction': eq.traction,
    'usageHours': eq.usageHours,
    'isActive': eq.isActive ? 1 : 0,
    'imageUrls': eq.imageUrls != null ? jsonEncode(eq.imageUrls) : null,
    'condition': eq.condition,
    'implements': eq.implements != null
        ? jsonEncode(eq.implements!.map((i) => i.toJson()).toList())
        : null,
    'dailyRate': eq.hourlyRate,
    'createdAt': eq.createdAt.toIso8601String(),
    'lastMaintenanceDate': eq.lastMaintenanceDate?.toIso8601String(),
  };

  await dbHelper.insert('landlord_equipments', landlordMap);

  // Sincronización con el catálogo público que ve el rentador.
  // Optimización local: reutilizamos el mismo id del tractor para evitar duplicados.
  final publicEquipmentMap = {
    'id': eq.id,
    'name': eq.name,
    'category': 'Tractores',
    'description':
        '${eq.brand} ${eq.model} ${eq.year}. Potencia: ${eq.power.toStringAsFixed(0)} HP. Transmisión: ${eq.transmission}. Tracción: ${eq.traction}.',
    'location': 'Ubicación del arrendador',
    'pricePerDay': eq.hourlyRate ?? 0.0,
    'pricePerWeek': (eq.hourlyRate ?? 0.0) * 7,
    'pricePerMonth': (eq.hourlyRate ?? 0.0) * 30,
    'rating': 4.8,
    'reviewCount': 0,
    'available': eq.isActive ? 1 : 0,
    'ownerId': 'arrendador_local',
    'ownerName': 'Arrendador AgroGo',
    'images': eq.imageUrls != null && eq.imageUrls!.isNotEmpty
        ? eq.imageUrls!.first
        : '',
    'specs': jsonEncode({
      'Marca': eq.brand,
      'Modelo': eq.model,
      'Año': eq.year.toString(),
      'Potencia': '${eq.power.toStringAsFixed(0)} HP',
      'Transmisión': eq.transmission,
      'Tracción': eq.traction,
      'Horas de uso': '${eq.usageHours.toStringAsFixed(0)} h',
      'Condición': eq.condition ?? 'Buena',
    }),
  };

  await dbHelper.insert('equipments', publicEquipmentMap);
}

Future<void> _updateEquipmentInDB(LandlordEquipment eq) async {
  final dbHelper = DatabaseHelper();

  final landlordMap = {
    'id': eq.id,
    'name': eq.name,
    'brand': eq.brand,
    'model': eq.model,
    'year': eq.year,
    'power': eq.power,
    'transmission': eq.transmission,
    'traction': eq.traction,
    'usageHours': eq.usageHours,
    'isActive': eq.isActive ? 1 : 0,
    'imageUrls': eq.imageUrls != null ? jsonEncode(eq.imageUrls) : null,
    'condition': eq.condition,
    'implements': eq.implements != null
        ? jsonEncode(eq.implements!.map((i) => i.toJson()).toList())
        : null,
    'dailyRate': eq.hourlyRate,
    'lastMaintenanceDate': eq.lastMaintenanceDate?.toIso8601String(),
  };

  await dbHelper.update('landlord_equipments', landlordMap, eq.id);

  // Actualiza también el catálogo público para que el rentador vea cambios.
  final publicEquipmentMap = {
    'id': eq.id,
    'name': eq.name,
    'category': 'Tractores',
    'description':
        '${eq.brand} ${eq.model} ${eq.year}. Potencia: ${eq.power.toStringAsFixed(0)} HP. Transmisión: ${eq.transmission}. Tracción: ${eq.traction}.',
    'location': 'Ubicación del arrendador',
    'pricePerDay': eq.hourlyRate ?? 0.0,
    'pricePerWeek': (eq.hourlyRate ?? 0.0) * 7,
    'pricePerMonth': (eq.hourlyRate ?? 0.0) * 30,
    'rating': 4.8,
    'reviewCount': 0,
    'available': eq.isActive ? 1 : 0,
    'ownerId': 'arrendador_local',
    'ownerName': 'Arrendador AgroGo',
    'images': eq.imageUrls != null && eq.imageUrls!.isNotEmpty
        ? eq.imageUrls!.first
        : '',
    'specs': jsonEncode({
      'Marca': eq.brand,
      'Modelo': eq.model,
      'Año': eq.year.toString(),
      'Potencia': '${eq.power.toStringAsFixed(0)} HP',
      'Transmisión': eq.transmission,
      'Tracción': eq.traction,
      'Horas de uso': '${eq.usageHours.toStringAsFixed(0)} h',
      'Condición': eq.condition ?? 'Buena',
    }),
  };

  await dbHelper.insert('equipments', publicEquipmentMap);
}

  Future<void> _toggleEquipmentAvailability(int index) async {
    final updatedEq = equipment[index].copyWith(
      isActive: !equipment[index].isActive,
    );
    setState(() {
      equipment[index] = updatedEq;
    });
    await _updateEquipmentInDB(updatedEq);
  }

  Future<void> _showAddEquipmentDialog() async {
    final result = await Navigator.push<LandlordEquipment>(
      context,
      MaterialPageRoute(builder: (_) => const EquipmentFormScreen()),
    );
    if (result == null || !mounted) return;
    setState(() => equipment.add(result));
    await _saveEquipmentToDB(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          tr('Tractor agregado exitosamente', 'Tractor added successfully'),
        ),
      ),
    );
  }

  Future<void> _showEquipmentDetails(LandlordEquipment eq) async {
    final result = await Navigator.push<LandlordEquipment>(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentFormScreen(equipment: eq),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      final index = equipment.indexWhere((e) => e.id == eq.id);
      if (index != -1) equipment[index] = result;
    });
    await _updateEquipmentInDB(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(tr('Cambios guardados', 'Changes saved')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          tr('Mis Tractores', 'My Tractors'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    tr('Filtros pendiente de implementaciÃ³n',
                        'Filters pending implementation'),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.filter_list_outlined),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : equipment.isEmpty
              ? _buildEmptyState(isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                  ...equipment.asMap().entries.map(
                        (entry) => _buildEquipmentCard(
                          entry.value,
                          entry.key,
                          isDark,
                        ),
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEquipmentDialog,
        icon: const Icon(Icons.add_rounded),
        label: Text(tr('Agregar Tractor', 'Add Tractor')),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tr('Sin tractores registrados', 'No tractors registered'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('Agrega tu primer tractor para comenzar',
                'Add your first tractor to get started'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddEquipmentDialog,
            icon: const Icon(Icons.add_rounded),
            label: Text(tr('Agregar Tractor', 'Add Tractor')),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(
    LandlordEquipment eq,
    int index,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _showEquipmentDetails(eq),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: _buildEquipmentImage(eq, isDark),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eq.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${eq.brand} ${eq.model} (${eq.year})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: eq.isActive
                              ? Colors.green.withOpacity(isDark ? 0.2 : 0.1)
                              : Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          eq.isActive
                              ? tr('Disponible', 'Available')
                              : tr('En Taller', 'In Workshop'),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: eq.isActive ? Colors.green : Colors.orange,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Especificaciones
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildSpecBadge(
                        icon: Icons.speed_rounded,
                        label: '${eq.power.toInt()} HP',
                        isDark: isDark,
                      ),
                      _buildSpecBadge(
                        icon: Icons.settings_rounded,
                        label: eq.transmission,
                        isDark: isDark,
                      ),
                      _buildSpecBadge(
                        icon: Icons.directions_car_rounded,
                        label: eq.traction,
                        isDark: isDark,
                      ),
                      _buildSpecBadge(
                        icon: Icons.schedule_rounded,
                        label: '${eq.usageHours.toInt()}h',
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Implementos y acciones
                  if (eq.implements != null && eq.implements!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Implementos', 'Implements'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: eq.implements!
                              .take(3)
                              .map(
                                (impl) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withOpacity(
                                      isDark ? 0.15 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    impl.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppTheme.accentColor,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (eq.implements!.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              tr('+${eq.implements!.length - 3} mÃ¡s',
                                  '+${eq.implements!.length - 3} more'),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  // Botones de acciÃ³n
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _toggleEquipmentAvailability(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  eq.isActive
                                      ? tr('Marcado como inactivo',
                                          'Marked as inactive')
                                      : tr('Marcado como disponible',
                                          'Marked as available'),
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            eq.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            eq.isActive
                                ? tr('Desactivar', 'Deactivate')
                                : tr('Activar', 'Activate'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEquipmentDetails(eq),
                          icon: const Icon(Icons.edit_rounded),
                          label: Text(tr('Editar', 'Edit')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentImage(LandlordEquipment eq, bool isDark) {
    final imagePath =
        eq.imageUrls != null && eq.imageUrls!.isNotEmpty ? eq.imageUrls!.first : null;

    return Container(
      width: double.infinity,
      height: 160,
      color: AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
      child: imagePath != null
          ? Image.file(
              File(imagePath),
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _equipmentPlaceholder(),
            )
          : _equipmentPlaceholder(),
    );
  }

  Widget _equipmentPlaceholder() {
    return Center(
      child: Icon(
        Icons.agriculture_rounded,
        size: 60,
        color: AppTheme.primaryColor.withOpacity(0.6),
      ),
    );
  }

  Widget _buildSpecBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
