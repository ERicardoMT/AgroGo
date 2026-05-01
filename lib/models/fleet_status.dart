class FleetStatus {
  final int totalEquipment;
  final int rented;
  final int available;
  final int maintenance;

  FleetStatus({
    required this.totalEquipment,
    required this.rented,
    required this.available,
    required this.maintenance,
  });

  factory FleetStatus.fromJson(Map<String, dynamic> json) {
    return FleetStatus(
      totalEquipment: json['totalEquipment'] as int,
      rented: json['rented'] as int,
      available: json['available'] as int,
      maintenance: json['maintenance'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalEquipment': totalEquipment,
        'rented': rented,
        'available': available,
        'maintenance': maintenance,
      };
}
