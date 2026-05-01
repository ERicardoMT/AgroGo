class RentalOccupancy {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String renterName;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'upcoming', 'completed'
  final double? rentalCost;
  final String? location;
  final double? latitude;
  final double? longitude;

  RentalOccupancy({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.renterName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.rentalCost,
    this.location,
    this.latitude,
    this.longitude,
  });

  factory RentalOccupancy.fromJson(Map<String, dynamic> json) {
    return RentalOccupancy(
      id: json['id'] as String,
      equipmentId: json['equipmentId'] as String,
      equipmentName: json['equipmentName'] as String,
      renterName: json['renterName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      rentalCost: (json['rentalCost'] as num?)?.toDouble(),
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'equipmentId': equipmentId,
        'equipmentName': equipmentName,
        'renterName': renterName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'rentalCost': rentalCost,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      };

  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays;
  }

  bool get isActive {
    return DateTime.now().isAfter(startDate) &&
        DateTime.now().isBefore(endDate);
  }
}
