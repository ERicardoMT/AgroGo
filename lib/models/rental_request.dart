class RentalRequest {
  final String id;
  final String rentalId;
  final String equipmentName;
  final String renterName;
  final String renterPhone;
  final String renterLocation;
  final DateTime requestDate;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'pending', 'approved', 'rejected'
  final double dailyRate;
  final String? notes;

  RentalRequest({
    required this.id,
    required this.rentalId,
    required this.equipmentName,
    required this.renterName,
    required this.renterPhone,
    required this.renterLocation,
    required this.requestDate,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.dailyRate,
    this.notes,
  });

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'] as String,
      rentalId: json['rentalId'] as String,
      equipmentName: json['equipmentName'] as String,
      renterName: json['renterName'] as String,
      renterPhone: json['renterPhone'] as String,
      renterLocation: json['renterLocation'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      dailyRate: (json['dailyRate'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rentalId': rentalId,
        'equipmentName': equipmentName,
        'renterName': renterName,
        'renterPhone': renterPhone,
        'renterLocation': renterLocation,
        'requestDate': requestDate.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'dailyRate': dailyRate,
        'notes': notes,
      };
}
