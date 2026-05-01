import 'implement.dart';

class LandlordEquipment {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final double power; // en HP
  final String transmission; // 'Manual', 'Automática', 'CVT'
  final String traction; // '2WD', '4WD', 'AWD'
  final double usageHours;
  final bool isActive; // Disponible/Activo o Inactivo/En Taller
  final List<String>? imageUrls;
  final String? condition; // 'Excelente', 'Bueno', 'Regular', 'Requiere Mantenimiento'
  final List<Implement>? implements;
  final double? dailyRate;
  final DateTime createdAt;
  final DateTime? lastMaintenanceDate;

  LandlordEquipment({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.power,
    required this.transmission,
    required this.traction,
    required this.usageHours,
    this.isActive = true,
    this.imageUrls,
    this.condition = 'Bueno',
    this.implements,
    this.dailyRate,
    required this.createdAt,
    this.lastMaintenanceDate,
  });

  factory LandlordEquipment.fromJson(Map<String, dynamic> json) {
    return LandlordEquipment(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      power: (json['power'] as num).toDouble(),
      transmission: json['transmission'] as String,
      traction: json['traction'] as String,
      usageHours: (json['usageHours'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      condition: json['condition'] as String? ?? 'Bueno',
      implements: (json['implements'] as List?)
          ?.map((e) => Implement.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyRate: (json['dailyRate'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'model': model,
        'year': year,
        'power': power,
        'transmission': transmission,
        'traction': traction,
        'usageHours': usageHours,
        'isActive': isActive,
        'imageUrls': imageUrls,
        'condition': condition,
        'implements': implements?.map((e) => e.toJson()).toList(),
        'dailyRate': dailyRate,
        'createdAt': createdAt.toIso8601String(),
        'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      };

  LandlordEquipment copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    int? year,
    double? power,
    String? transmission,
    String? traction,
    double? usageHours,
    bool? isActive,
    List<String>? imageUrls,
    String? condition,
    List<Implement>? implements,
    double? dailyRate,
    DateTime? createdAt,
    DateTime? lastMaintenanceDate,
  }) {
    return LandlordEquipment(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      power: power ?? this.power,
      transmission: transmission ?? this.transmission,
      traction: traction ?? this.traction,
      usageHours: usageHours ?? this.usageHours,
      isActive: isActive ?? this.isActive,
      imageUrls: imageUrls ?? this.imageUrls,
      condition: condition ?? this.condition,
      implements: implements ?? this.implements,
      dailyRate: dailyRate ?? this.dailyRate,
      createdAt: createdAt ?? this.createdAt,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
    );
  }
}
