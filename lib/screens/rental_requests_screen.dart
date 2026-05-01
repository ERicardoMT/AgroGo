import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../models/rental_request.dart';
import '../models/rental_occupancy.dart';

class RentalRequestsScreen extends StatefulWidget {
  const RentalRequestsScreen({super.key});

  @override
  State<RentalRequestsScreen> createState() => _RentalRequestsScreenState();
}

class _RentalRequestsScreenState extends State<RentalRequestsScreen>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _requestsTabController;

  late List<RentalRequest> allRequests;
  late List<RentalOccupancy> rentalOccupancies;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    _requestsTabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _requestsTabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    allRequests = [
      // Solicitudes pendientes
      RentalRequest(
        id: '1',
        rentalId: 'R001',
        equipmentName: 'Tractor John Deere 5075E',
        renterName: 'Juan Pérez',
        renterPhone: '+34 612 345 678',
        renterLocation: 'Córdoba, Argentina',
        requestDate: DateTime.now().subtract(const Duration(hours: 3)),
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        status: 'pending',
        dailyRate: 150.0,
        notes: 'Necesita para labrar 80 hectáreas',
      ),
      RentalRequest(
        id: '2',
        rentalId: 'R002',
        equipmentName: 'Cosechadora CLAAS',
        renterName: 'María García',
        renterPhone: '+34 656 789 012',
        renterLocation: 'Santa Fe, Argentina',
        requestDate: DateTime.now().subtract(const Duration(hours: 1)),
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        status: 'pending',
        dailyRate: 280.0,
        notes: 'Cosecha de trigo',
      ),
      // Solicitudes aceptadas
      RentalRequest(
        id: '3',
        rentalId: 'R003',
        equipmentName: 'Tractor Massey Ferguson 4275',
        renterName: 'Carlos López',
        renterPhone: '+34 698 765 432',
        renterLocation: 'La Pampa, Argentina',
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        startDate: DateTime.now().subtract(const Duration(hours: 6)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        status: 'approved',
        dailyRate: 180.0,
        notes: 'Renta en progreso',
      ),
      RentalRequest(
        id: '4',
        rentalId: 'R004',
        equipmentName: 'Rastra de arrastre',
        renterName: 'Roberto Martín',
        renterPhone: '+34 712 345 678',
        renterLocation: 'Buenos Aires, Argentina',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 8)),
        status: 'approved',
        dailyRate: 45.0,
      ),
      // Solicitudes rechazadas
      RentalRequest(
        id: '5',
        rentalId: 'R005',
        equipmentName: 'Tractor John Deere 5075E',
        renterName: 'Ana Rodríguez',
        renterPhone: '+34 634 567 890',
        renterLocation: 'Mendoza, Argentina',
        requestDate: DateTime.now().subtract(const Duration(days: 5)),
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        status: 'rejected',
        dailyRate: 150.0,
        notes: 'Rechazo: Equipo en mantenimiento en esas fechas',
      ),
    ];

    rentalOccupancies = [
      RentalOccupancy(
        id: 'RO001',
        equipmentId: 'E001',
        equipmentName: 'Tractor John Deere 5075E',
        renterName: 'Carlos López',
        startDate: DateTime.now().subtract(const Duration(hours: 6)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        status: 'active',
        rentalCost: 150.0,
        location: 'La Pampa, Campo Principal',
        latitude: -36.6201,
        longitude: -64.2675,
      ),
      RentalOccupancy(
        id: 'RO002',
        equipmentId: 'E002',
        equipmentName: 'Cosechadora CLAAS',
        renterName: 'Próxima renta',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        status: 'upcoming',
        rentalCost: 280.0,
        location: 'Santa Fe',
      ),
      RentalOccupancy(
        id: 'RO003',
        equipmentId: 'E003',
        equipmentName: 'Tractor Massey Ferguson',
        renterName: 'Disponible',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now(),
        status: 'completed',
        rentalCost: 180.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          tr('Solicitudes y Rentas', 'Requests and Rentals'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        bottom: TabBar(
          controller: _mainTabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: isDark ? Colors.grey[600] : Colors.grey[700],
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(
              text: tr('Solicitudes', 'Requests'),
              icon: const Icon(Icons.inbox_rounded),
            ),
            Tab(
              text: tr('Activas', 'Active'),
              icon: const Icon(Icons.play_circle_outline_rounded),
            ),
            Tab(
              text: tr('Calendario', 'Calendar'),
              icon: const Icon(Icons.calendar_today_rounded),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _buildRequestsTab(isDark),
          _buildActiveRentalsTab(isDark),
          _buildCalendarTab(isDark),
        ],
      ),
    );
  }

  // ========== TAB 1: SOLICITUDES ==========
  Widget _buildRequestsTab(bool isDark) {
    return Column(
      children: [
        // Sub-tabs para solicitudes
        Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: TabBar(
            controller: _requestsTabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: isDark ? Colors.grey[600] : Colors.grey[700],
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: tr('Pendientes', 'Pending')),
              Tab(text: tr('Aceptadas', 'Accepted')),
              Tab(text: tr('Rechazadas', 'Rejected')),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _requestsTabController,
            children: [
              _buildRequestsList(isDark, 'pending'),
              _buildRequestsList(isDark, 'approved'),
              _buildRequestsList(isDark, 'rejected'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsList(bool isDark, String status) {
    final filteredRequests =
        allRequests.where((req) => req.status == status).toList();

    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending'
                  ? Icons.inbox_rounded
                  : (status == 'approved'
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined),
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              status == 'pending'
                  ? tr('Sin solicitudes pendientes',
                      'No pending requests')
                  : (status == 'approved'
                      ? tr('Sin solicitudes aceptadas',
                          'No accepted requests')
                      : tr('Sin solicitudes rechazadas',
                          'No rejected requests')),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) =>
          _buildRequestCard(filteredRequests[index], isDark, status),
    );
  }

  Widget _buildRequestCard(RentalRequest request, bool isDark, String status) {
    final daysUntilStart =
        request.startDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.renterName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'pending'
                      ? Colors.orange.withOpacity(isDark ? 0.2 : 0.1)
                      : (status == 'approved'
                          ? Colors.green.withOpacity(isDark ? 0.2 : 0.1)
                          : Colors.red.withOpacity(isDark ? 0.2 : 0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status == 'pending'
                      ? tr('Pendiente', 'Pending')
                      : (status == 'approved'
                          ? tr('Aceptada', 'Accepted')
                          : tr('Rechazada', 'Rejected')),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: status == 'pending'
                            ? Colors.orange
                            : (status == 'approved'
                                ? Colors.green
                                : Colors.red),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.renterLocation,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 11,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                request.renterPhone,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildInfoBadge(
                icon: Icons.calendar_today_outlined,
                label: daysUntilStart > 0
                    ? tr('En $daysUntilStart días', 'In $daysUntilStart days')
                    : tr('Hoy', 'Today'),
                isDark: isDark,
              ),
              _buildInfoBadge(
                icon: Icons.schedule_rounded,
                label:
                    '${request.endDate.difference(request.startDate).inDays} días',
                isDark: isDark,
              ),
              _buildInfoBadge(
                icon: Icons.attach_money_rounded,
                label: '\$${request.dailyRate}/día',
                isDark: isDark,
              ),
            ],
          ),
          if (request.notes != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                request.notes!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 11,
                      height: 1.3,
                    ),
              ),
            ),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
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
                    icon: const Icon(Icons.close_rounded),
                    label: Text(tr('Rechazar', 'Reject')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
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
                    icon: const Icon(Icons.check_rounded),
                    label: Text(tr('Aceptar', 'Accept')),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  // ========== TAB 2: RENTAS ACTIVAS ==========
  Widget _buildActiveRentalsTab(bool isDark) {
    final activeRentals = rentalOccupancies
        .where((r) =>
            r.status == 'active' ||
            (DateTime.now().isAfter(r.startDate) &&
                DateTime.now().isBefore(r.endDate)))
        .toList();

    if (activeRentals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              tr('Sin rentas activas', 'No active rentals'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: activeRentals.length,
      itemBuilder: (context, index) =>
          _buildActiveRentalCard(activeRentals[index], isDark),
    );
  }

  Widget _buildActiveRentalCard(RentalOccupancy rental, bool isDark) {
    final timeRemaining = rental.endDate.difference(DateTime.now());
    final hoursRemaining = timeRemaining.inHours % 24;
    final daysRemaining = timeRemaining.inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
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
                      rental.equipmentName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rentado por: ${rental.renterName}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tr('En uso', 'In use'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Tiempo restante', 'Time remaining'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$daysRemaining ${tr("días", "days")} y $hoursRemaining ${tr("horas", "hours")}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (rental.location != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rental.location!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        tr('Ubicación en mapa', 'Location on map'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded),
                label: Text(tr('Ver Ubicación', 'View Location')),
              ),
              const Spacer(),
              if (rental.rentalCost != null)
                Text(
                  '\$${rental.rentalCost}/día',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== TAB 3: CALENDARIO ==========
  Widget _buildCalendarTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Ocupación por Equipo', 'Equipment Occupancy'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          ...rentalOccupancies.map(
            (occupancy) => _buildOccupancyTimeline(occupancy, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyTimeline(RentalOccupancy occupancy, bool isDark) {
    final duration = occupancy.endDate.difference(occupancy.startDate).inDays;
    final isActive = occupancy.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(
            occupancy.equipmentName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF404040) : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                // Indicador de ocupación
                Container(
                  height: double.infinity,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green
                        : (occupancy.status == 'upcoming'
                            ? Colors.blue
                            : Colors.grey),
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      isActive
                          ? tr('Activa', 'Active')
                          : (occupancy.status == 'upcoming'
                              ? tr('Próxima', 'Upcoming')
                              : tr('Completada', 'Completed')),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${occupancy.startDate.day}/${occupancy.startDate.month} - ${occupancy.endDate.day}/${occupancy.endDate.month}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '($duration ${tr("días", "days")})',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Rentador: ${occupancy.renterName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }
}
