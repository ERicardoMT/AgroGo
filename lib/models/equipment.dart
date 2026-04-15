class Equipment {
  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final double pricePerDay;
  final double pricePerWeek;
  final double pricePerMonth;
  final double rating;
  final int reviewCount;
  final bool available;
  final String ownerId;
  final String ownerName;
  final List<String> images;
  final Map<String, String> specs;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    required this.rating,
    required this.reviewCount,
    required this.available,
    required this.ownerId,
    required this.ownerName,
    required this.images,
    required this.specs,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      pricePerWeek: (json['pricePerWeek'] as num).toDouble(),
      pricePerMonth: (json['pricePerMonth'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      available: json['available'] as bool,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      images: List<String>.from(json['images'] as List),
      specs: Map<String, String>.from(json['specs'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'location': location,
      'pricePerDay': pricePerDay,
      'pricePerWeek': pricePerWeek,
      'pricePerMonth': pricePerMonth,
      'rating': rating,
      'reviewCount': reviewCount,
      'available': available,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'images': images,
      'specs': specs,
    };
  }
}
