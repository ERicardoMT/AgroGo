import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import '../globals.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../utils/rental_calculation.dart';

class BookingBottomSheet extends StatefulWidget {
  final Equipment equipment;

  const BookingBottomSheet({
    super.key,
    required this.equipment,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;
  bool _isSuccess = false;

  int get _hoursCount {
    if (_startDate == null || _endDate == null) return 0;

    // Optimización local: el cálculo se centraliza y se evita repetir lógica
    // de fechas dentro del build.
    return RentalCalculation.hoursBetween(_startDate!, _endDate!);
  }

  double get _totalPrice {
    if (_hoursCount <= 0) return 0;

    // En este proyecto pricePerDay realmente se está usando como tarifa por hora.
    return widget.equipment.pricePerDay * _hoursCount;
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
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppTheme.primaryColor,
                    surface: Color(0xFF1E1E1E),
                  )
                : const ColorScheme.light(
                    primary: AppTheme.primaryColor,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

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

  Future<void> _confirmBooking() async {
    if (_startDate == null || _endDate == null) return;

    if (_hoursCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.warningColor,
          content: Text(
            tr(
              'Selecciona un periodo válido para la reserva.',
              'Select a valid booking period.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final currentEmail = currentUserEmailNotifier.value;
      final renterName = currentEmail?.split('@').first ?? 'Rentador';

      final requestMap = {
        'id': id,
        'rentalId': 'R-$id',
        'equipmentName': widget.equipment.name,
        'renterName': renterName,
        'renterPhone': '1234567890',
        'renterLocation': 'Ubicación de $renterName',
        'requestDate': DateTime.now().toIso8601String(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'status': 'pending',
        'dailyRate': widget.equipment.pricePerDay,
        'notes': 'Reserva solicitada desde la App',
      };

      await dbHelper.insert('rental_requests', requestMap);

      final bookingMap = {
        'id': id,
        'equipmentId': widget.equipment.id,
        'equipmentName': widget.equipment.name,
        'equipmentCategory': widget.equipment.category,
        'userId': currentEmail ?? 'rentador_demo@agrogo.com',
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'totalPrice': _totalPrice,
        'status': 'confirmed',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await dbHelper.insert('bookings', bookingMap);

      await dbHelper.createTrackingIfMissing(
        bookingId: id,
        equipmentId: widget.equipment.id,
        destinationAddress: 'Ubicación registrada del rentador',
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.errorColor,
          content: Text('Error al reservar: $e'),
        ),
      );

      debugPrint('ERROR AL RESERVAR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es_ES');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSuccess) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : AppTheme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
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
              tr('Reserva Confirmada', 'Booking Confirmed'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'Tu reserva ha sido procesada exitosamente',
                'Your booking has been processed successfully',
              ),
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
        color: isDark ? Colors.grey[900] : AppTheme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr('Reservar Equipo', 'Book Equipment'),
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
          Text(
            tr('Selecciona las fechas', 'Select dates'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: tr('Fecha inicio', 'Start date'),
                  date: _startDate,
                  onTap: () => _selectDate(true),
                  dateFormat: dateFormat,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: tr('Fecha fin', 'End date'),
                  date: _endDate,
                  onTap: () => _selectDate(false),
                  dateFormat: dateFormat,
                  enabled: _startDate != null,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (_hoursCount > 0) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    tr('Duración', 'Duration'),
                    tr('$_hoursCount horas', '$_hoursCount hours'),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    tr('Precio base', 'Base price'),
                    '\$${widget.equipment.pricePerDay.toStringAsFixed(0)}${tr('/hora', '/hr')}',
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    tr('Total', 'Total'),
                    '\$${_totalPrice.toStringAsFixed(0)} MXN',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
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
                  : Text(tr('Confirmar Reserva', 'Confirm Booking')),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }

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
              ? (isDark ? Colors.grey[800] : AppTheme.cardColor)
              : (isDark ? Colors.grey[900] : AppTheme.backgroundColor),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryColor
                : (isDark ? Colors.grey[700]! : AppTheme.borderColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
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
                Expanded(
                  child: Text(
                    date != null
                        ? dateFormat.format(date)
                        : tr('Seleccionar', 'Select'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: date != null
                          ? (isDark ? Colors.white : AppTheme.textPrimary)
                          : AppTheme.textMuted,
                      fontWeight:
                          date != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
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
                ? (isDark ? Colors.white : AppTheme.textPrimary)
                : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? AppTheme.primaryColor
                : (isDark ? Colors.white : AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}