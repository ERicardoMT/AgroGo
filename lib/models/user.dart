class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? profileImage;
  final List<String> favorites;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.profileImage,
    this.favorites = const [],
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      profileImage: json['profileImage'] as String?,
      favorites: List<String>.from(json['favorites'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'location': location,
        'profileImage': profileImage,
        'favorites': favorites,
        'createdAt': createdAt.toIso8601String(),
      };
}
