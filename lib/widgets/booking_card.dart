import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL
import '../screens/chat_screen.dart';
import '../screens/booking_detail_screen.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  const BookingCard({super.key, required this.booking});

  Color _getStatusColor() {
    switch (booking.status) {
      case BookingStatus.pending:
        return AppTheme.warningColor;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.active:
        return AppTheme.primaryColor;
      case BookingStatus.completed:
        return AppTheme.textMuted;
      case BookingStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  IconData _getStatusIcon() {
    switch (booking.status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.active:
        return Icons.play_circle_outline;
      case BookingStatus.completed:
        return Icons.task_alt;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'es_ES');
    final statusColor = _getStatusColor();
    final isDark = Theme.of(context).brightness == Brightness.dark; // DETECCIÓN DE TEMA

    // TRADUCCIÓN DEL ESTADO (Usando la variable booking.statusText como base)
    String translatedStatus;
    switch (booking.statusText.toLowerCase()) {
      case 'confirmada': translatedStatus = tr('Confirmada', 'Confirmed'); break;
      case 'activa': translatedStatus = tr('Activa', 'Active'); break;
      case 'completada': translatedStatus = tr('Completada', 'Completed'); break;
      case 'cancelada': translatedStatus = tr('Cancelada', 'Cancelled'); break;
      default: translatedStatus = tr('Pendiente', 'Pending');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), // ADAPTACIÓN
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Equipment Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.equipmentName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.equipmentCategory,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      translatedStatus, // TEXTO TRADUCIDO
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: isDark ? Colors.grey[800] : null), // ADAPTACIÓN
          const SizedBox(height: 16),

          // Details Row
          Row(
            children: [
              // Dates
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Days
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : AppTheme.backgroundColor, // ADAPTACIÓN
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tr('${booking.daysCount} días', '${booking.daysCount} days'), // TRADUCCIÓN
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('Total', 'Total'), // TRADUCCIÓN
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(0)} MXN',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          // Actions for active bookings
          if (booking.status == BookingStatus.active ||
              booking.status == BookingStatus.confirmed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            otherUserName: 'Propietario', // Podríamos obtenerlo del equipo
                            equipmentName: booking.equipmentName,
                            otherUserRole: 'arrendador',
                            otherUserPhone: '+52 55 1234 5678', // Dato simulado
                          ),
                        ),
                      );
                    },
                    child: Text(tr('Contactar', 'Contact')), // TRADUCCIÓN
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailScreen(booking: booking),
                        ),
                      );
                    },
                    child: Text(tr('Ver detalles', 'View details')), // TRADUCCIÓN
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
