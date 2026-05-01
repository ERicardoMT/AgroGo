class LandlordAlert {
  final String id;
  final String title;
  final String message;
  final String type; // 'critical', 'warning', 'info'
  final DateTime createdAt;
  final bool isRead;
  final String? equipmentId;
  final String? rentalId;

  LandlordAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.equipmentId,
    this.rentalId,
  });

  factory LandlordAlert.fromJson(Map<String, dynamic> json) {
    return LandlordAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      equipmentId: json['equipmentId'] as String?,
      rentalId: json['rentalId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'equipmentId': equipmentId,
        'rentalId': rentalId,
      };
}
