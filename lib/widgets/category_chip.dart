import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../globals.dart'; 

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; 

    // Pequeño traductor para los nombres de las categorías
    String translatedName = category.name;
    if (languageNotifier.value == 'Inglés') {
      switch (category.name) {
        case 'Tractores': translatedName = 'Tractors'; break;
        case 'Cosechadoras': translatedName = 'Harvesters'; break;
        case 'Riego': translatedName = 'Irrigation'; break;
        case 'Sembradoras': translatedName = 'Seeders'; break;
        case 'Fumigación': translatedName = 'Fumigation'; break;
        case 'Transporte': translatedName = 'Transport'; break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : (isDark ? Colors.grey[900] : AppTheme.cardColor), 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : (isDark ? Colors.grey[800]! : AppTheme.borderColor), 
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.15)
                    : (isDark ? Colors.grey[800] : AppTheme.backgroundColor), 
                shape: BoxShape.circle,
              ),
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translatedName, // NOMBRE TRADUCIDO
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : (isDark ? Colors.white : AppTheme.textPrimary), 
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
