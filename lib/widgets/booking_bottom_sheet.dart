import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL

class BookingBottomSheet extends StatefulWidget {
  final Equipment equipment;

  const BookingBottomSheet({super.key, required this.equipment});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isSuccess = false;

  int get _daysCount {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double get _totalPrice {
    if (_daysCount <= 0) return 0;
    if (_daysCount >= 30) {
      return widget.equipment.pricePerMonth * (_daysCount / 30);
    } else if (_daysCount >= 7) {
      return widget.equipment.pricePerWeek * (_daysCount / 7);
    } else {
      return widget.equipment.pricePerDay * _daysCount;
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now.add(const Duration(days: 1)));
    final firstDate = isStart ? now : (_startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _confirmBooking() async {
    if (_startDate == null || _endDate == null) return;
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
    // Close after showing success
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es_ES');
    final isDark = Theme.of(context).brightness == Brightness.dark; // DETECCIÓN DE TEMA

    if (_isSuccess) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              tr('Reserva Confirmada', 'Booking Confirmed'), // TRADUCCIÓN
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              tr('Tu reserva ha sido procesada exitosamente', 'Your booking has been processed successfully'), // TRADUCCIÓN
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : AppTheme.borderColor, // ADAPTACIÓN
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            tr('Reservar Equipo', 'Book Equipment'), // TRADUCCIÓN
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          Text(
            widget.equipment.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),

          const SizedBox(height: 24),

          // Date Selection
          Text(
            tr('Selecciona las fechas', 'Select dates'), // TRADUCCIÓN
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: tr('Fecha inicio', 'Start date'), // TRADUCCIÓN
                  date: _startDate,
                  onTap: () => _selectDate(true),
                  dateFormat: dateFormat,
                  isDark: isDark, // PASAMOS EL TEMA
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: tr('Fecha fin', 'End date'), // TRADUCCIÓN
                  date: _endDate,
                  onTap: () => _selectDate(false),
                  dateFormat: dateFormat,
                  enabled: _startDate != null,
                  isDark: isDark, // PASAMOS EL TEMA
                ),
              ),
            ],
          ),

          if (_daysCount > 0) ...[
            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : AppTheme.backgroundColor, // ADAPTACIÓN
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    tr('Duración', 'Duration'), // TRADUCCIÓN
                    tr('$_daysCount días', '$_daysCount days'), // TRADUCCIÓN
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    tr('Precio base', 'Base price'), // TRADUCCIÓN
                    '\$${widget.equipment.pricePerDay.toStringAsFixed(0)}${tr('/día', '/day')}', // TRADUCCIÓN
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    tr('Total', 'Total'), // TRADUCCIÓN
                    '\$${_totalPrice.toStringAsFixed(0)} MXN',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startDate != null && _endDate != null && !_isLoading
                  ? _confirmBooking
                  : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(tr('Confirmar Reserva', 'Confirm Booking')), // TRADUCCIÓN
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }

  // Agregamos isDark como parámetro para colorear esta cajita
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required DateFormat dateFormat,
    bool enabled = true,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled 
              ? (isDark ? Colors.grey[800] : AppTheme.cardColor) // ADAPTACIÓN
              : (isDark ? Colors.grey[900] : AppTheme.backgroundColor), // ADAPTACIÓN
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? AppTheme.primaryColor : (isDark ? Colors.grey[700]! : AppTheme.borderColor), // ADAPTACIÓN
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null
                      ? AppTheme.primaryColor
                      : AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null ? dateFormat.format(date) : tr('Seleccionar', 'Select'), // TRADUCCIÓN
                  style: TextStyle(
                    color: date != null
                        ? (isDark ? Colors.white : AppTheme.textPrimary) // ADAPTACIÓN
                        : AppTheme.textMuted,
                    fontWeight:
                        date != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal 
                ? (isDark ? Colors.white : AppTheme.textPrimary) // ADAPTACIÓN
                : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppTheme.primaryColor : (isDark ? Colors.white : AppTheme.textPrimary), // ADAPTACIÓN
          ),
        ),
      ],
    );
  }
}
