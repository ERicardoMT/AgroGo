import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../globals.dart';
import '../data/database_helper.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  Map<String, dynamic>? _tracking;
  bool _loading = true;

  final List<String> _stepsEs = const [
    'Pedido confirmado',
    'Tractor en camino',
    'Cerca del punto',
    'Tractor entregado',
    'Renta finalizada',
  ];

  final List<String> _stepsEn = const [
    'Order confirmed',
    'Tractor on the way',
    'Near the destination',
    'Tractor delivered',
    'Rental finished',
  ];

  @override
  void initState() {
    super.initState();
    _prepareTracking();
  }

  Future<void> _prepareTracking() async {
    await _db.createTrackingIfMissing(
      bookingId: widget.booking.id,
      equipmentId: widget.booking.equipmentId,
      destinationAddress: 'Ubicación registrada del rentador',
    );

    final data = await _db.getRentalTrackingByBooking(widget.booking.id);

    if (!mounted) return;

    setState(() {
      _tracking = data;
      _loading = false;
    });
  }

  Future<void> _reloadTracking() async {
    final data = await _db.getRentalTrackingByBooking(widget.booking.id);

    if (!mounted) return;

    setState(() {
      _tracking = data;
    });
  }

  Future<void> _startMovement() async {
    await _db.startTrackingMovement(widget.booking.id);
    await _reloadTracking();
  }

  Future<void> _advanceStep() async {
    await _db.advanceTrackingStep(widget.booking.id);
    await _reloadTracking();
  }

  Future<void> _resetSimulation() async {
    await _db.resetTrackingSimulation(widget.booking.id);
    await _reloadTracking();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = DateFormat('dd MMM yyyy', 'es_ES');

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(tr('Detalles de la Reserva', 'Booking Details')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tracking = _tracking;
    final currentStep = (tracking?['currentStep'] as int?) ?? 0;
    final progress = ((tracking?['progress'] as num?) ?? 0).toDouble();
    final etaMinutes = (tracking?['etaMinutes'] as int?) ?? 45;
    final isMoving = ((tracking?['isMoving'] as int?) ?? 0) == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Detalles de la Reserva', 'Booking Details')),
      ),
      body: RefreshIndicator(
        onRefresh: _reloadTracking,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusHeader(currentStep, etaMinutes, isMoving),
              const SizedBox(height: 20),
              _tractorMapCard(isDark, progress, currentStep),
              const SizedBox(height: 20),
              _trackingTimeline(currentStep),
              const SizedBox(height: 20),
              _operatorCard(isDark),
              const SizedBox(height: 20),
              _equipmentCard(isDark),
              const SizedBox(height: 20),
              _periodCard(isDark, formatter),
              const SizedBox(height: 20),
              _paymentCard(isDark),
              const SizedBox(height: 24),
              _simulationButtons(currentStep),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusHeader(int currentStep, int etaMinutes, bool isMoving) {
    final title = tr(_stepsEs[currentStep], _stepsEn[currentStep]);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isMoving ? Icons.local_shipping : Icons.agriculture,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  etaMinutes > 0
                      ? tr(
                          'Llegada estimada: $etaMinutes min',
                          'Estimated arrival: $etaMinutes min',
                        )
                      : tr('Sin tiempo pendiente', 'No remaining time'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tractorMapCard(bool isDark, double progress, int currentStep) {
    final leftPosition = 18 + (220 * progress.clamp(0.0, 1.0));

    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePainter(
                isDark: isDark,
                progress: progress,
              ),
            ),
          ),
          const Positioned(
            left: 8,
            bottom: 22,
            child: _MapPin(
              icon: Icons.store_mall_directory,
              label: 'Origen',
            ),
          ),
          const Positioned(
            right: 8,
            top: 18,
            child: _MapPin(
              icon: Icons.location_on,
              label: 'Destino',
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            left: leftPosition.clamp(18.0, 238.0),
            bottom: 68 + (58 * progress),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🚜', style: TextStyle(fontSize: 28)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: currentStep >= 4
                    ? AppTheme.successColor.withValues(alpha: 0.12)
                    : AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                currentStep >= 4
                    ? tr('Ruta completada', 'Route completed')
                    : tr('Ruta simulada en vivo', 'Live simulated route'),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingTimeline(int currentStep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Seguimiento del tractor', 'Tractor tracking'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_stepsEs.length, (index) {
          final completed = index < currentStep;
          final active = index == currentStep;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: completed || active
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        completed ? Icons.check : Icons.circle,
                        size: completed ? 18 : 10,
                        color: completed || active
                            ? Colors.white
                            : AppTheme.textMuted,
                      ),
                    ),
                    if (index < _stepsEs.length - 1)
                      Container(
                        width: 2,
                        height: 28,
                        color: completed
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      tr(_stepsEs[index], _stepsEn[index]),
                      style: TextStyle(
                        fontWeight: active ? FontWeight.bold : FontWeight.w500,
                        color: completed || active
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _operatorCard(bool isDark) {
    final tracking = _tracking;

    return _sectionCard(
      isDark: isDark,
      title: tr('Operador asignado', 'Assigned operator'),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tracking?['driverName']?.toString() ?? 'Operador AgroGo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  tracking?['driverPhone']?.toString() ?? '+52 55 1234 5678',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _equipmentCard(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: tr('Equipo rentado', 'Rented equipment'),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🚜', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.equipmentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.booking.equipmentCategory,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodCard(bool isDark, DateFormat formatter) {
    return _sectionCard(
      isDark: isDark,
      title: tr('Período de renta', 'Rental period'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _dateBlock(
            tr('Inicio', 'Start'),
            formatter.format(widget.booking.startDate),
          ),
          const Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
          _dateBlock(
            tr('Fin', 'End'),
            formatter.format(widget.booking.endDate),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      title: tr('Resumen de pago', 'Payment summary'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Total pagado', 'Total paid')),
          Text(
            '\$${widget.booking.totalPrice.toStringAsFixed(0)} MXN',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _simulationButtons(int currentStep) {
    return Column(
      children: [
        if (currentStep == 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startMovement,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                tr(
                  'Iniciar movimiento del tractor',
                  'Start tractor movement',
                ),
              ),
            ),
          )
        else if (currentStep < 4)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _advanceStep,
              icon: const Icon(Icons.navigation),
              label: Text(
                tr('Avanzar simulación', 'Advance simulation'),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetSimulation,
              icon: const Icon(Icons.restart_alt),
              label: Text(
                tr('Reiniciar simulación', 'Restart simulation'),
              ),
            ),
          ),
        const SizedBox(height: 10),
        if (currentStep > 0 && currentStep < 4)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetSimulation,
              icon: const Icon(Icons.restore),
              label: Text(
                tr('Reiniciar seguimiento', 'Reset tracking'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _dateBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MapPin({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryDark, size: 28),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: AppTheme.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final bool isDark;
  final double progress;

  _RoutePainter({
    required this.isDark,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Optimización de mirilla: un solo Path dibuja ruta base y ruta activa.
    final basePaint = Paint()
      ..color = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(35, size.height - 45)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.75,
        size.width * 0.48,
        size.height * 0.38,
        size.width - 45,
        45,
      );

    canvas.drawPath(path, basePaint);

    final metric = path.computeMetrics().first;
    final extractPath = metric.extractPath(
      0,
      metric.length * progress.clamp(0.0, 1.0),
    );

    canvas.drawPath(extractPath, activePaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}