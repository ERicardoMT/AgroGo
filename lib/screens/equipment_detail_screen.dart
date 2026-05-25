import 'dart:io';
import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_bottom_sheet.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL
import 'chat_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final Equipment equipment;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const EquipmentDetailScreen({
    super.key,
    required this.equipment,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  int _selectedPriceOption = 0;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onToggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final equipment = widget.equipment;
    final isDark = Theme.of(context).brightness == Brightness.dark; // <--- DETECTOR DE TEMA

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? Colors.grey[900] : AppTheme.backgroundColor, // ADAPTACIÓN
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : AppTheme.cardColor, // ADAPTACIÓN
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : AppTheme.cardColor, // ADAPTACIÓN
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: _isFavorite ? Colors.red : (isDark ? Colors.white : AppTheme.textPrimary),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : AppTheme.cardColor, // ADAPTACIÓN
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(Icons.share, color: isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: equipment.images.isNotEmpty && equipment.images.first.isNotEmpty
                  ? Image.file(
                      File(equipment.images.first),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 60),
                                Icon(
                                  Icons.agriculture,
                                  size: 80,
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  equipment.category,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              Icons.agriculture,
                              size: 80,
                              color: AppTheme.primaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              equipment.category,
                              style: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: equipment.available
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.textMuted.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      equipment.available ? tr('Disponible', 'Available') : tr('No disponible', 'Not available'), // TRADUCCIÓN
                      style: TextStyle(
                        color: equipment.available ? AppTheme.successColor : AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name
                  Text(
                    equipment.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  // Rating and Reviews
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        equipment.rating.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tr('(${equipment.reviewCount} reseñas)', '(${equipment.reviewCount} reviews)'), // TRADUCCIÓN
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        equipment.location,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    tr('Descripción', 'Description'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    equipment.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: AppTheme.textSecondary,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Specifications
                  Text(
                    tr('Especificaciones', 'Specifications'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), // ADAPTACIÓN
                    ),
                    child: Column(
                      children: equipment.specs.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                entry.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pricing Options
                  Text(
                    tr('Opciones de renta', 'Rental options'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPriceOption(
                        context,
                        index: 0,
                        label: tr('Por hora', 'Per hour'),
                        price: equipment.pricePerDay,
                      ),
                      const SizedBox(width: 12),
                      _buildPriceOption(
                        context,
                        index: 1,
                        label: tr('Por semana', 'Per week'), // TRADUCCIÓN
                        price: equipment.pricePerWeek,
                      ),
                      const SizedBox(width: 12),
                      _buildPriceOption(
                        context,
                        index: 2,
                        label: tr('Por mes', 'Per month'), // TRADUCCIÓN
                        price: equipment.pricePerMonth,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Owner Info
                  Text(
                    tr('Propietario', 'Owner'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), // ADAPTACIÓN
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Text(
                            equipment.ownerName[0],
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                equipment.ownerName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tr('Verificado', 'Verified'), // TRADUCCIÓN
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  otherUserName: equipment.ownerName,
                                  equipmentName: equipment.name,
                                  otherUserRole: 'arrendador',
                                  otherUserPhone: 'Desconocido', // TODO: Obtener del equipo o backend
                                ),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chat_outlined,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Desde', 'From'), // TRADUCCIÓN
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '\$${equipment.pricePerDay.toStringAsFixed(0)}${tr('/hora', '/hr')}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: equipment.available
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => BookingBottomSheet(equipment: equipment),
                          );
                        }
                      : null,
                  child: Text(tr('Reservar ahora', 'Book now')), // TRADUCCIÓN
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceOption(
    BuildContext context, {
    required int index,
    required String label,
    required double price,
  }) {
    final isSelected = _selectedPriceOption == index;
    final isDark = Theme.of(context).brightness == Brightness.dark; // <--- DETECTOR DE TEMA LOCAL

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriceOption = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : (isDark ? Colors.grey[800] : AppTheme.cardColor), // ADAPTACIÓN
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.grey[700]! : AppTheme.borderColor), // ADAPTACIÓN
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textMuted,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (isDark ? Colors.white : AppTheme.textPrimary), // ADAPTACIÓN
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
