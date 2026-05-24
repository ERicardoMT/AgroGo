import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import '../globals.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  Map<String, dynamic>? _tracking;

  bool _loading = true;
  bool _autoRunning = false;
  bool _autoPaused = false;

  Timer? _autoTimer;
  DateTime? _autoStartedAt;
  DateTime? _lastDbWrite;

  double _liveProgress = 0.0;
  int _liveStep = 0;
  int _lastPersistedStep = -1;

  static const Duration _simulationDuration = Duration(minutes: 3);
  static const Duration _frameDuration = Duration(milliseconds: 70);
  static const Duration _dbThrottle = Duration(milliseconds: 600);

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

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  Future<void> _prepareTracking() async {
    await _db.createTrackingIfMissing(
      bookingId: widget.booking.id,
      equipmentId: widget.booking.equipmentId,
      destinationAddress: 'Ubicación registrada del rentador',
    );

    final data = await _db.getRentalTrackingByBooking(widget.booking.id);

    if (!mounted) return;

    final progress = ((data?['progress'] as num?) ?? 0).toDouble();
    final step = (data?['currentStep'] as int?) ?? _stepFromProgress(progress);

    setState(() {
      _tracking = data;
      _liveProgress = progress.clamp(0.0, 1.0);
      _liveStep = step.clamp(0, 4);
      _loading = false;
    });
  }

  Future<void> _reloadTracking() async {
    final data = await _db.getRentalTrackingByBooking(widget.booking.id);

    if (!mounted) return;

    final progress = ((data?['progress'] as num?) ?? _liveProgress).toDouble();
    final step = (data?['currentStep'] as int?) ?? _stepFromProgress(progress);

    setState(() {
      _tracking = data;
      _liveProgress = progress.clamp(0.0, 1.0);
      _liveStep = step.clamp(0, 4);
    });
  }

  int _stepFromProgress(double progress) {
    if (progress >= 1.0) return 4;
    if (progress >= 0.86) return 3;
    if (progress >= 0.58) return 2;
    if (progress >= 0.16) return 1;
    return 0;
  }

  int _etaFromProgress(double progress) {
    final remaining = (1.0 - progress).clamp(0.0, 1.0);
    return (remaining * 45).ceil();
  }

  double _latFromProgress(double progress) {
    const startLat = 19.3900;
    const endLat = 19.4150;
    return startLat + ((endLat - startLat) * progress);
  }

  double _lngFromProgress(double progress) {
    const startLng = -99.1200;
    const endLng = -99.1500;
    return startLng + ((endLng - startLng) * progress);
  }

  Future<void> _persistTrackingFrame(
    double progress, {
    bool force = false,
    bool paused = false,
  }) async {
    final now = DateTime.now();
    final step = _stepFromProgress(progress);

    final shouldWriteByTime =
        _lastDbWrite == null || now.difference(_lastDbWrite!) >= _dbThrottle;

    final shouldWriteByStep = step != _lastPersistedStep;

    if (!force && !shouldWriteByTime && !shouldWriteByStep) return;

    _lastDbWrite = now;
    _lastPersistedStep = step;

    final trackingId = 'tracking_${widget.booking.id}';

    await _db.update(
      'rental_tracking',
      {
        'currentStep': step,
        'progress': progress.clamp(0.0, 1.0),
        'etaMinutes': _etaFromProgress(progress),
        'isMoving': paused || progress >= 1.0 ? 0 : 1,
        'currentLatitude': _latFromProgress(progress),
        'currentLongitude': _lngFromProgress(progress),
        'updatedAt': now.toIso8601String(),
      },
      trackingId,
    );

    if (progress >= 1.0) {
      await _db.update(
        'bookings',
        {'status': 'completed'},
        widget.booking.id,
      );
    } else if (progress > 0.0) {
      await _db.update(
        'bookings',
        {'status': 'active'},
        widget.booking.id,
      );
    }
  }

  Future<void> _startAutomaticSimulation() async {
    if (_autoRunning) return;

    if (_liveProgress >= 1.0) {
      await _resetAutomaticSimulation();
    }

    await _db.startTrackingMovement(widget.booking.id);
    await _reloadTracking();

    _resumeFromCurrentProgress();
  }

  void _resumeFromCurrentProgress() {
    final safeProgress = _liveProgress.clamp(0.0, 0.99);
    final elapsedOffset =
        (_simulationDuration.inMilliseconds * safeProgress).round();

    _autoStartedAt = DateTime.now().subtract(
      Duration(milliseconds: elapsedOffset),
    );

    _autoTimer?.cancel();

    setState(() {
      _autoRunning = true;
      _autoPaused = false;
    });

    _autoTimer = Timer.periodic(_frameDuration, (_) {
      _tickAutomaticSimulation();
    });
  }

  Future<void> _pauseAutomaticSimulation() async {
    if (!_autoRunning) return;

    _autoTimer?.cancel();

    await _persistTrackingFrame(
      _liveProgress,
      force: true,
      paused: true,
    );

    if (!mounted) return;

    setState(() {
      _autoRunning = false;
      _autoPaused = true;
    });
  }

  Future<void> _continueAutomaticSimulation() async {
    if (_autoRunning) return;
    if (!_autoPaused) return;
    if (_liveProgress >= 1.0) return;

    await _persistTrackingFrame(
      _liveProgress,
      force: true,
      paused: false,
    );

    _resumeFromCurrentProgress();
  }

  Future<void> _tickAutomaticSimulation() async {
    final startedAt = _autoStartedAt;
    if (startedAt == null) return;

    final elapsed = DateTime.now().difference(startedAt);

    final rawProgress =
        elapsed.inMilliseconds / _simulationDuration.inMilliseconds;

    final clampedRaw = rawProgress.clamp(0.0, 1.0);
    final easedProgress = Curves.easeInOutCubic.transform(clampedRaw);

    final step = _stepFromProgress(easedProgress);

    if (mounted) {
      setState(() {
        _liveProgress = easedProgress;
        _liveStep = step;
      });
    }

    await _persistTrackingFrame(easedProgress);

    if (clampedRaw >= 1.0) {
      _autoTimer?.cancel();

      await _persistTrackingFrame(1.0, force: true);

      if (!mounted) return;

      setState(() {
        _autoRunning = false;
        _autoPaused = false;
        _liveProgress = 1.0;
        _liveStep = 4;
      });

      await _reloadTracking();
    }
  }

  Future<void> _resetAutomaticSimulation() async {
    _autoTimer?.cancel();

    await _db.resetTrackingSimulation(widget.booking.id);
    await _reloadTracking();

    if (!mounted) return;

    setState(() {
      _autoRunning = false;
      _autoPaused = false;
      _autoStartedAt = null;
      _lastDbWrite = null;
      _lastPersistedStep = -1;
      _liveProgress = 0.0;
      _liveStep = 0;
    });
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

    final etaMinutes = _etaFromProgress(_liveProgress);

    final isMoving = _autoRunning || (_liveProgress > 0 && _liveProgress < 1);

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
              _statusHeader(_liveStep, etaMinutes, isMoving),
              const SizedBox(height: 20),
              _tractorMapCard(isDark, _liveProgress, _liveStep),
              const SizedBox(height: 20),
              _autoSimulationPanel(isDark),
              const SizedBox(height: 20),
              _trackingTimeline(_liveStep),
              const SizedBox(height: 20),
              _operatorCard(isDark),
              const SizedBox(height: 20),
              _equipmentCard(isDark),
              const SizedBox(height: 20),
              _periodCard(isDark, formatter),
              const SizedBox(height: 20),
              _paymentCard(isDark),
              const SizedBox(height: 24),
              _mainActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusHeader(int currentStep, int etaMinutes, bool isMoving) {
    final title = tr(_stepsEs[currentStep], _stepsEn[currentStep]);

    String subtitle;

    if (_autoPaused) {
      subtitle = tr(
        'Seguimiento pausado',
        'Tracking paused',
      );
    } else if (etaMinutes > 0) {
      subtitle = tr(
        'Llegada estimada: $etaMinutes min',
        'Estimated arrival: $etaMinutes min',
      );
    } else {
      subtitle = tr(
        'Recorrido completado',
        'Route completed',
      );
    }

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
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _autoPaused
                  ? Icons.pause_circle
                  : isMoving
                      ? Icons.local_shipping
                      : Icons.agriculture,
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
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final safeProgress = progress.clamp(0.0, 1.0);

        final tractorLeft = (mapWidth - 72) * safeProgress;
        final tractorBottom = 55 + (70 * safeProgress);

        return Container(
          height: 230,
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
                    progress: safeProgress,
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
                duration: _autoPaused
                    ? Duration.zero
                    : const Duration(milliseconds: 120),
                curve: Curves.linear,
                left: tractorLeft.clamp(10.0, mapWidth - 68),
                bottom: tractorBottom.clamp(50.0, 150.0),
                child: AnimatedContainer(
                  duration: _autoPaused
                      ? Duration.zero
                      : const Duration(milliseconds: 120),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _autoPaused
                        ? AppTheme.warningColor
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (_autoPaused
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor)
                            .withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _autoPaused ? '⏸️' : '🚜',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: currentStep >= 4
                        ? AppTheme.successColor.withOpacity(0.12)
                        : _autoPaused
                            ? AppTheme.warningColor.withOpacity(0.12)
                            : AppTheme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    currentStep >= 4
                        ? tr('Ruta completada', 'Route completed')
                        : _autoPaused
                            ? tr('Ruta pausada', 'Route paused')
                            : tr(
                                'Ruta automática en vivo',
                                'Live automatic route',
                              ),
                    style: TextStyle(
                      color: _autoPaused
                          ? AppTheme.warningColor
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _autoSimulationPanel(bool isDark) {
    final percentage = (_liveProgress * 100).clamp(0, 100).toStringAsFixed(0);

    String message;

    if (_autoRunning) {
      message = tr(
        'El tractor está avanzando automáticamente...',
        'The tractor is moving automatically...',
      );
    } else if (_autoPaused) {
      message = tr(
        'El recorrido está pausado. Puedes continuarlo desde este punto.',
        'The route is paused. You can continue from this point.',
      );
    } else {
      message = tr(
        'Presiona iniciar para recorrer toda la ruta.',
        'Press start to complete the full route.',
      );
    }

    return Container(
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
          Text(
            tr('Simulación automática', 'Automatic simulation'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _liveProgress.clamp(0.0, 1.0),
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _autoPaused ? AppTheme.warningColor : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _autoRunning
                    ? Icons.play_circle_fill
                    : _autoPaused
                        ? Icons.pause_circle_filled
                        : Icons.route,
                color: _autoPaused
                    ? AppTheme.warningColor
                    : AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: _autoPaused
                      ? AppTheme.warningColor
                      : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
              color: AppTheme.primaryColor.withOpacity(0.1),
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

  Widget _mainActionButton() {
    if (_autoRunning) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pauseAutomaticSimulation,
              icon: const Icon(Icons.pause_rounded),
              label: Text(
                tr('Pausar recorrido', 'Pause route'),
              ),
            ),
          ),
        ],
      );
    }

    if (_autoPaused) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _continueAutomaticSimulation,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                tr('Continuar recorrido', 'Continue route'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetAutomaticSimulation,
              icon: const Icon(Icons.restart_alt),
              label: Text(
                tr('Reiniciar simulación', 'Restart simulation'),
              ),
            ),
          ),
        ],
      );
    }

    if (_liveProgress >= 1.0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _resetAutomaticSimulation,
          icon: const Icon(Icons.restart_alt),
          label: Text(
            tr('Reiniciar simulación', 'Restart simulation'),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startAutomaticSimulation,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              tr(
                'Iniciar recorrido automático',
                'Start automatic route',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_liveProgress > 0)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetAutomaticSimulation,
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
    // Optimización de mirilla: se reutiliza un solo Path para pintar la ruta base
    // y después extraer únicamente la parte activa del recorrido.
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
        size.width * 0.25,
        size.height * 0.82,
        size.width * 0.55,
        size.height * 0.28,
        size.width - 45,
        45,
      );

    canvas.drawPath(path, basePaint);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;

    final activePath = metric.extractPath(
      0,
      metric.length * progress.clamp(0.0, 1.0),
    );

    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}