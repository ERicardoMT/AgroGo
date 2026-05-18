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
import 'notifications_screen.dart'; // <--- IMPORT
import '../data/database_helper.dart'; // <-- IMPORT MBD

class LandlordMainScreen extends StatefulWidget {
  const LandlordMainScreen({super.key});

  @override
  State<LandlordMainScreen> createState() => _LandlordMainScreenState();
}

class _LandlordMainScreenState extends State<LandlordMainScreen> {
  int _currentTabIndex = 0;

  // Mock data
  late List<RentalRequest> pendingRequests;
  late FleetStatus fleetStatus;
  late MonthlyIncome monthlyIncome;
  late List<LandlordAlert> criticalAlerts;

  String _userName = ''; // <--- Agregamos variable para el nombre real

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _loadUserName(); // <--- Cargamos nombre desde BD
  }

  Future<void> _loadUserName() async {
    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getAll('users');
    final currentEmail = currentUserEmailNotifier.value;

    if (users.isNotEmpty && currentEmail != null) {
      try {
        final miUsuario = users.firstWhere((user) => user['email'] == currentEmail);
        setState(() {
          // Extraemos solo el primer nombre en caso de que escriban todo el nombre completo
          final fullName = miUsuario['name']?.toString() ?? 'Usuario';
          _userName = fullName.split(' ')[0];
        });
      } catch (e) {
        setState(() {
          _userName = 'Usuario';
        });
      }
    } else {
      setState(() {
        _userName = 'Usuario';
      });
    }
  }

  void _loadMockData() {
    // Solicitudes pendientes
    pendingRequests = [
      RentalRequest(
        id: '1',
        rentalId: 'R001',
        equipmentName: 'Tractor John Deere 5075E',
        renterName: 'Juan Pérez',
        renterPhone: '+34 912 345 678',
        renterLocation: 'Valladolid, España',
        requestDate: DateTime.now().subtract(const Duration(hours: 3)),
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        status: 'pending',
        dailyRate: 150.0,
      ),
      RentalRequest(
        id: '2',
        rentalId: 'R002',
        equipmentName: 'Cosechadora CLAAS',
        renterName: 'María García',
        renterPhone: '+34 923 456 789',
        renterLocation: 'Palencia, España',
        requestDate: DateTime.now().subtract(const Duration(hours: 1)),
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        status: 'pending',
        dailyRate: 280.0,
      ),
    ];

    // Estado de flota
    fleetStatus = FleetStatus(
      totalEquipment: 6,
      rented: 3,
      available: 2,
      maintenance: 1,
    );

    // Ingresos del mes
    monthlyIncome = MonthlyIncome(
      totalIncome: 3450.00,
      pendingPayments: 850.00,
      completedPayments: 2600.00,
      rentalsCompleted: 8,
      periodStart: DateTime(DateTime.now().year, DateTime.now().month, 1),
      periodEnd: DateTime.now(),
    );

    // Alertas críticas
    criticalAlerts = [
      LandlordAlert(
        id: 'A1',
        title: 'Renta atrasada',
        message: 'Tractor rentado por Carlos hace 2 horas. Debe ser devuelto en 30 min.',
        type: 'critical',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        rentalId: 'R003',
      ),
      LandlordAlert(
        id: 'A2',
        title: 'Mantenimiento programado',
        message: 'La cosechadora requiere mantenimiento mañana a las 9:00 AM.',
        type: 'warning',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        equipmentId: 'E002',
      ),
    ];
  }

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
                builder: (context) => const NotificationsScreen(),
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
                builder: (context) => const LandlordProfileScreen(),
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
          // --- AQUÍ USAMOS EL NOMBRE REAL DEL USUARIO ---
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
                        monthlyIncome.completedPayments / monthlyIncome.totalIncome,
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
