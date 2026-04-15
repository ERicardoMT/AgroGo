enum BookingStatus { pending, confirmed, active, completed, cancelled }

class Booking {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String equipmentCategory;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentCategory,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  int get daysCount => endDate.difference(startDate).inDays + 1;

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.active:
        return 'Activa';
      case BookingStatus.completed:
        return 'Completada';
      case BookingStatus.cancelled:
        return 'Cancelada';
    }
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      equipmentId: json['equipmentId'] as String,
      equipmentName: json['equipmentName'] as String,
      equipmentCategory: json['equipmentCategory'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
