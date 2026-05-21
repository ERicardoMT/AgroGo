import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // DETECCIÓN DE TEMA

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), // ADAPTACIÓN
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03), // ADAPTACIÓN
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : AppTheme.primaryColor.withOpacity(0.08), // ADAPTACIÓN
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.agriculture,
                        size: 48,
                        color: AppTheme.primaryColor.withOpacity(0.4),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: equipment.available
                            ? AppTheme.primaryColor.withOpacity(0.9)
                            : AppTheme.textMuted.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        equipment.available 
                            ? tr('Disponible', 'Available') 
                            : tr('No disponible', 'Unavailable'), // TRADUCCIÓN
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900]!.withOpacity(0.9) : AppTheme.cardColor.withOpacity(0.9), // ADAPTACIÓN
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          size: 18,
                          color: isFavorite ? Colors.red : (isDark ? Colors.grey[400] : AppTheme.textSecondary), // ADAPTACIÓN
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : null, // ADAPTACIÓN
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          equipment.rating.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[300] : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            equipment.location.split(',')[0],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textMuted,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${equipment.pricePerDay.toStringAsFixed(0)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          tr('/hora', '/hr'),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
