import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_card.dart';
import '../globals.dart'; // <--- IMPORT GLOBAL

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _getFilteredBookings(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return MockData.bookings;
      case 1:
        return MockData.bookings
            .where((b) =>
                b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.active ||
                b.status == BookingStatus.pending)
            .toList();
      case 2:
        return MockData.bookings
            .where((b) =>
                b.status == BookingStatus.completed ||
                b.status == BookingStatus.cancelled)
            .toList();
      default:
        return MockData.bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos el modo oscuro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              tr('Mis Reservas', 'My Bookings'), // TRADUCCIÓN
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : AppTheme.cardColor, // ADAPTACIÓN
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.borderColor), // ADAPTACIÓN
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: tr('Todas', 'All')), // TRADUCCIÓN
                Tab(text: tr('Activas', 'Active')), // TRADUCCIÓN
                Tab(text: tr('Historial', 'History')), // TRADUCCIÓN
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bookings List
          Expanded(
            child: TabBarView(
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
  }

  Widget _buildBookingsList(int tabIndex) {
    final bookings = _getFilteredBookings(tabIndex);

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              tr('No hay reservas', 'No bookings'), // TRADUCCIÓN
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              tr('Cuando realices una reserva aparecerá aquí', 'When you make a booking, it will appear here'), // TRADUCCIÓN
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BookingCard(booking: bookings[index]),
        );
      },
    );
  }
}
