import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../models/rental_request.dart';
import '../models/fleet_status.dart';
import '../models/monthly_income.dart';
import '../models/landlord_alert.dart';
import 'fleet_management_screen.dart';
import 'rental_requests_screen.dart';
import 'finances_screen.dart';
import 'communication_screen.dart';
import 'landlord_profile_screen.dart';
import 'notifications_screen.dart'; 
import '../data/database_helper.dart'; 

class LandlordMainScreen extends StatefulWidget {
  const LandlordMainScreen({super.key});

  @override
  State<LandlordMainScreen> createState() => _LandlordMainScreenState();
}

class _LandlordMainScreenState extends State<LandlordMainScreen> {
  int _currentTabIndex = 0;
  bool _isLoading = true; // <--- Agregamos estado de carga

  // Variables para los datos
  late List<RentalRequest> pendingRequests;
  late FleetStatus fleetStatus;
  late MonthlyIncome monthlyIncome;
  late List<LandlordAlert> criticalAlerts;

  String _userName = '';

  @override
  void initState() {
    super.initState();
    // En lugar de cargar mock data directo, inicializamos todo de forma asíncrona
    _initializeData();
  }

  // --- INICIALIZACIÓN GENERAL ---
  Future<void> _initializeData() async {
    await _loadUserName();
    await _loadDataFromDB(); // <--- Carga desde SQLite
    if (mounted) {
      setState(() {
        _isLoading = false; // Oculta el spinner de carga
      });
    }
  }

  // --- 1. CARGAMOS EL USUARIO ---
  Future<void> _loadUserName() async {
    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getAll('users');
    final currentEmail = currentUserEmailNotifier.value;

    if (users.isNotEmpty && currentEmail != null) {
      try {
        final miUsuario = users.firstWhere((user) => user['email'] == currentEmail);
        setState(() {
          final fullName = miUsuario['name']?.toString() ?? 'Usuario';
          _userName = fullName.split(' ')[0];
        });
      } catch (e) {
        setState(() => _userName = 'Usuario');
      }
    } else {
      setState(() => _userName = 'Usuario');
    }
  }

  // --- 2. CARGAMOS LOS DATOS REALES DE SQLITE ---
  Future<void> _loadDataFromDB() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    try {
      // A) Buscar Solicitudes Pendientes
      final reqResult = await db.query('rental_requests', where: 'status = ?', whereArgs: ['pending']);
      if (reqResult.isNotEmpty) {
        pendingRequests = reqResult.map((map) => RentalRequest(
          id: map['id'].toString(),
          rentalId: map['rentalId'].toString(),
          equipmentName: map['equipmentName'].toString(),
          renterName: map['renterName'].toString(),
          renterPhone: map['renterPhone'].toString(),
          renterLocation: map['renterLocation'].toString(),
          requestDate: DateTime.parse(map['requestDate'].toString()),
          startDate: DateTime.parse(map['startDate'].toString()),
          endDate: DateTime.parse(map['endDate'].toString()),
          status: map['status'].toString(),
          dailyRate: (map['dailyRate'] as num).toDouble(),
        )).toList();
      } else {
        _loadMockPendingRequests(); // Fallback si no hay datos
      }

      // B) Calcular el estado de la flota
      final equipResult = await db.query('landlord_equipments');
      if (equipResult.isNotEmpty) {
        int available = 0;
        for (var eq in equipResult) {
          if (eq['isActive'] == 1) available++;
        }
        fleetStatus = FleetStatus(
          totalEquipment: equipResult.length,
          rented: equipResult.length - available, // Simplificado
          available: available,
          maintenance: 0,
        );
      } else {
        _loadMockFleetStatus(); // Fallback si no hay equipos
      }

      // C) Buscar Alertas Críticas
      final alertsResult = await db.query('landlord_alerts', orderBy: 'createdAt DESC', limit: 2);
      if (alertsResult.isNotEmpty) {
        criticalAlerts = alertsResult.map((map) => LandlordAlert(
          id: map['id'].toString(),
          title: map['title'].toString(),
          message: map['message'].toString(),
          type: map['type'].toString(),
          createdAt: DateTime.parse(map['createdAt'].toString()),
          rentalId: map['rentalId']?.toString(),
          equipmentId: map['equipmentId']?.toString(),
        )).toList();
      } else {
        _loadMockAlerts(); // Fallback
      }

      // D) Buscar Ingresos Mensuales (Simulado hasta conectar con tabla transactions)
      _loadMockIncome();

    } catch (e) {
      print("Error cargando BD: $e");
      // Si ocurre un error, no rompemos la app, cargamos datos falsos
      _loadMockPendingRequests();
      _loadMockFleetStatus();
      _loadMockAlerts();
      _loadMockIncome();
    }
  }

  // --- MÉTODOS DE RESPALDO (MOCK DATA) ---
  void _loadMockPendingRequests() {
    pendingRequests = [];
  }

  void _loadMockFleetStatus() {
    fleetStatus = FleetStatus(totalEquipment: 0, rented: 0, available: 0, maintenance: 0);
  }

  void _loadMockIncome() {
    monthlyIncome = MonthlyIncome(totalIncome: 0.0, pendingPayments: 0.0, completedPayments: 0.0, rentalsCompleted: 0, periodStart: DateTime.now(), periodEnd: DateTime.now());
  }

  void _loadMockAlerts() {
    criticalAlerts = [];
  }


  // --- INTERFAZ VISUAL ---
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final screens = [
      _buildDashboardTab(isDark),
      const FleetManagementScreen(),
      const RentalRequestsScreen(),
      const FinancesScreen(),
      const CommunicationScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: tr('Inicio', 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.agriculture_outlined),
            activeIcon: const Icon(Icons.agriculture),
            label: tr('Mis Rentas', 'My Rentals'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inbox_outlined),
            activeIcon: const Icon(Icons.inbox),
            label: tr('Solicitudes', 'Requests'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.attach_money_outlined),
            activeIcon: const Icon(Icons.attach_money),
            label: tr('Finanzas', 'Finances'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_rounded),
            activeIcon: const Icon(Icons.people),
            label: tr('Comunicación', 'Communication'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(bool isDark) {
    // Si la base de datos está cargando, mostramos la ruedita
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
        appBar: _buildAppBar(isDark),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(isDark),
            const SizedBox(height: 24),
            _buildCriticalAlerts(isDark),
            const SizedBox(height: 24),
            _buildKPISection(isDark),
            const SizedBox(height: 24),
            _buildFleetStatus(isDark),
            const SizedBox(height: 24),
            _buildMonthlyIncome(isDark),
            const SizedBox(height: 24),
            _buildPendingRequests(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text(
        tr('Panel Arrendador', 'Landlord Dashboard'),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(),
              ),
            );
          },
          icon: const Icon(Icons.notifications_outlined),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LandlordProfileScreen(),
              ),
            );
          },
          icon: const Icon(Icons.person_outline),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Bienvenido, $_userName', 'Welcome, $_userName'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          tr(
            'Aquí está el resumen de tu negocio de hoy',
            'Here is your business summary for today',
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
        ),
      ],
    );
  }

  Widget _buildCriticalAlerts(bool isDark) {
    if (criticalAlerts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Alertas Críticas', 'Critical Alerts'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...criticalAlerts.map((alert) => _buildAlertCard(alert, isDark)),
      ],
    );
  }

  Widget _buildAlertCard(LandlordAlert alert, bool isDark) {
    final isWarning = alert.type == 'warning';
    final isCritical = alert.type == 'critical';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCritical
            ? AppTheme.errorColor.withOpacity(isDark ? 0.15 : 0.1)
            : (isWarning
                ? Colors.orange.withOpacity(isDark ? 0.15 : 0.1)
                : AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.1)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical
              ? AppTheme.errorColor.withOpacity(isDark ? 0.3 : 0.2)
              : (isWarning
                  ? Colors.orange.withOpacity(isDark ? 0.3 : 0.2)
                  : AppTheme.primaryColor.withOpacity(isDark ? 0.3 : 0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.error_rounded : Icons.warning_rounded,
            color: isCritical ? AppTheme.errorColor : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPISection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Solicitudes Pendientes', 'Pending Requests'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor.withOpacity(0.8),
                      AppTheme.accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.pending_actions_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pendingRequests.length}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('Solicitudes aguardando acción',
                          'Requests awaiting action'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFleetStatus(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Estado de la Flota', 'Fleet Status'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFleetCard(
                label: tr('Rentados', 'Rented'),
                value: fleetStatus.rented.toString(),
                icon: Icons.local_shipping_rounded,
                color: AppTheme.primaryColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFleetCard(
                label: tr('Disponibles', 'Available'),
                value: fleetStatus.available.toString(),
                icon: Icons.check_circle_rounded,
                color: Colors.green,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFleetCard(
                label: tr('Mantenimiento', 'Maintenance'),
                value: fleetStatus.maintenance.toString(),
                icon: Icons.build_rounded,
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFleetCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyIncome(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Ingresos del Mes', 'Monthly Income'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Ingresos Totales', 'Total Income'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${monthlyIncome.totalIncome.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tr('Completados', 'Completed'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${monthlyIncome.completedPayments.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF303030) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value:
                        monthlyIncome.totalIncome > 0 ? (monthlyIncome.completedPayments / monthlyIncome.totalIncome) : 0.0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('Pagos Pendientes', 'Pending Payments'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                  ),
                  Text(
                    '\$${monthlyIncome.pendingPayments.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingRequests(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('Solicitudes Pendientes', 'Pending Requests'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      tr('Ver todas las solicitudes',
                          'View all requests'),
                    ),
                  ),
                );
              },
              child: Text(tr('Ver todas', 'View all')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...pendingRequests.take(3).map(
              (request) => _buildRequestCard(request, isDark),
            ),
      ],
    );
  }

  Widget _buildRequestCard(RentalRequest request, bool isDark) {
    final daysLeft = request.startDate.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.equipmentName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('Solicitante: ', 'Requester: ') + request.renterName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${request.dailyRate}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                daysLeft > 0
                    ? tr('Comienza en $daysLeft días',
                        'Starts in $daysLeft days')
                    : tr('Comienza hoy', 'Starts today'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
              ),
              const Spacer(),
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              tr('Solicitud rechazada',
                                  'Request rejected'),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        tr('Rechazar', 'Reject'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              tr('Solicitud aprobada',
                                  'Request approved'),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        tr('Aprobar', 'Approve'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}