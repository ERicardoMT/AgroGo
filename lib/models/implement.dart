class Implement {
  final String id;
  final String name;
  final String type; // 'rastra', 'arado', 'sembradora', etc.
  final String? description;
  final double? width; // ancho en metros
  final String? condition; // 'excelente', 'bueno', 'regular'

  Implement({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.width,
    this.condition = 'bueno',
  });

  factory Implement.fromJson(Map<String, dynamic> json) {
    return Implement(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      width: (json['width'] as num?)?.toDouble(),
      condition: json['condition'] as String? ?? 'bueno',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'width': width,
        'condition': condition,
      };
}
