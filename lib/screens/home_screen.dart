import 'package:flutter/material.dart';
import '../data/mock_data.dart'; // Solo para las categorías
import '../theme/app_theme.dart';
import '../widgets/equipment_card.dart';
import '../widgets/category_chip.dart';
import 'equipment_detail_screen.dart';
import '../globals.dart'; 
import '../data/database_helper.dart'; 
import '../models/equipment.dart';

class HomeScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;
  final VoidCallback onSearchTap; 

  const HomeScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onSearchTap, 
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  
  String _userName = 'Cargando...';
  String _userLocation = '...';
  List<Map<String, dynamic>> _equipmentList = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserHeader();
    _fetchEquipments();
  }

  Future<void> _loadUserHeader() async {
    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getAll('users');
    final currentEmail = currentUserEmailNotifier.value;

    if (users.isNotEmpty && currentEmail != null) {
      try {
        final miUsuario = users.firstWhere((user) => user['email'] == currentEmail);
        if (mounted) {
          setState(() {
            _userName = miUsuario['name']?.toString() ?? 'Usuario'; 
            _userLocation = miUsuario['location']?.toString() ?? 'Sin definir';
          });
        }
      } catch (e) { /* Manejo de error */ }
    }
  }

  Future<void> _fetchEquipments() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAll('equipments'); 
    if (mounted) {
      setState(() {
        _equipmentList = data;
        _isLoading = false;
      });
    }
  }

  void _mostrarNotificaciones(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!notificationsNotifier.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Las notificaciones están desactivadas', 'Notifications are disabled')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('Notificaciones', 'Notifications'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: const Icon(Icons.check_circle, color: AppTheme.primaryColor)),
                title: Text(tr('Reserva confirmada', 'Booking confirmed')),
                subtitle: Text(tr('Tu equipo está listo para ser recogido.', 'Your equipment is ready for pickup.')),
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: const Icon(Icons.warning, color: Colors.orange)),
                title: Text(tr('Recordatorio', 'Reminder')),
                subtitle: Text(tr('Tienes maquinaria por devolver mañana.', 'You have machinery to return tomorrow.')),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEquipment = selectedCategory == null
        ? _equipmentList
        : _equipmentList
            .where((e) => e['category'] == selectedCategory)
            .toList();
            
    final isDark = Theme.of(context).brightness == Brightness.dark; 

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserHeader();
          await _fetchEquipments();
        },
        color: AppTheme.primaryColor,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // --- 1. HEADER (Siempre visible) ---
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
                                  tr('Hola, $_userName', 'Hello, $_userName'),
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
                                      _userLocation, 
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          GestureDetector(
                            onTap: () => _mostrarNotificaciones(context),
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[900] : AppTheme.cardColor, 
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), 
                                  ),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: isDark ? Colors.white : AppTheme.textPrimary, 
                                  ),
                                ),
                                ValueListenableBuilder<bool>(
                                  valueListenable: notificationsNotifier,
                                  builder: (context, isEnabled, child) {
                                    if (!isEnabled) return const SizedBox.shrink();
                                    return Positioned(
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
                                    );
                                  }
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 2. BARRA DE BÚSQUEDA (Siempre visible) ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: widget.onSearchTap, 
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : AppTheme.cardColor, 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), 
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                tr('Buscar equipo agrícola...', 'Search agricultural equipment...'), 
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

                  // --- 3. CATEGORÍAS (Siempre visible) ---
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            tr('Categorías', 'Categories'), 
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 115, 
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

                  // --- 4. TÍTULO DE EQUIPOS (Siempre visible) ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCategory ?? tr('Equipo Disponible', 'Available Equipment'), 
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            tr('${filteredEquipment.length} equipos', '${filteredEquipment.length} equipment'), 
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // --- 5. CUADRÍCULA O ESTADO VACÍO (Dinámico) ---
                  filteredEquipment.isEmpty 
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.agriculture, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                tr('Aún no hay equipos disponibles', 'No equipment available yet'),
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
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
                            final eqData = filteredEquipment[index];
                            
                            final equipment = Equipment(
                              id: eqData['id']?.toString() ?? '',
                              name: eqData['name']?.toString() ?? 'Sin nombre',
                              category: eqData['category']?.toString() ?? 'General',
                              description: eqData['description']?.toString() ?? '',
                              location: eqData['location']?.toString() ?? 'Sin definir',
                              pricePerDay: (eqData['pricePerDay'] ?? 0).toDouble(),
                              pricePerWeek: (eqData['pricePerWeek'] ?? 0).toDouble(),
                              pricePerMonth: (eqData['pricePerMonth'] ?? 0).toDouble(),
                              rating: (eqData['rating'] ?? 0).toDouble(),
                              reviewCount: (eqData['reviewCount'] ?? 0).toInt(),
                              available: (eqData['available'] ?? 1) == 1,
                              ownerId: eqData['ownerId']?.toString() ?? '',
                              ownerName: eqData['ownerName']?.toString() ?? '',
                              images: eqData['images'] != null ? [eqData['images'].toString()] : [],
                              specs: {}, 
                            );

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
                                      onToggleFavorite: () => widget.onToggleFavorite(equipment.id),
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
            ),
      ),
    );
  }
}
