import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_card.dart';
import '../globals.dart'; 
import '../data/database_helper.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAll('bookings'); 
    final currentEmail = currentUserEmailNotifier.value;

    if (currentEmail == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final myBookingsData = data.where((b) => b['userId'] == currentEmail).toList();

    final parsedBookings = myBookingsData.map((b) {
      return Booking(
        id: b['id']?.toString() ?? '',
        equipmentId: b['equipmentId']?.toString() ?? '',
        equipmentName: b['equipmentName']?.toString() ?? 'Equipo',
        equipmentCategory: b['equipmentCategory']?.toString() ?? 'Categoría',
        userId: b['userId']?.toString() ?? '',
        startDate: DateTime.tryParse(b['startDate']?.toString() ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(b['endDate']?.toString() ?? '') ?? DateTime.now(),
        totalPrice: (b['totalPrice'] ?? 0).toDouble(),
        status: BookingStatus.values.firstWhere(
          (e) => e.name == b['status']?.toString().toLowerCase(),
          orElse: () => BookingStatus.pending,
        ),
        createdAt: DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList();

    if (mounted) {
      setState(() {
        _allBookings = parsedBookings;
        _isLoading = false;
      });
    }
  }

  List<Booking> _getFilteredBookings(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _allBookings;
      case 1:
        return _allBookings
            .where((b) =>
                b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.active ||
                b.status == BookingStatus.pending)
            .toList();
      case 2:
        return _allBookings
            .where((b) =>
                b.status == BookingStatus.completed ||
                b.status == BookingStatus.cancelled)
            .toList();
      default:
        return _allBookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, currentLanguage, child) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  tr('Mis Reservas', 'My Bookings'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab, 
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: tr('Todas', 'All')),
                    Tab(text: tr('Activas', 'Active')),
                    Tab(text: tr('Historial', 'History')),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildBookingsList(0),
                          _buildBookingsList(1),
                          _buildBookingsList(2),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingsList(int tabIndex) {
    final bookings = _getFilteredBookings(tabIndex);

    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchBookings,
        color: AppTheme.primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text(tr('No hay reservas', 'No bookings'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(tr('Cuando realices una reserva aparecerá aquí', 'When you make a booking, it will appear here'), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(booking: bookings[index]),
          );
        },
      ),
    );
  }
}
