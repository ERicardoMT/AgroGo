class Review {
  final String id;
  final String rentalId;
  final String reviewerName;
  final String reviewerRole; // rentador
  final double rating; // 1 a 5
  final String comment;
  final DateTime createdAt;
  final List<String> categories; // equipment_condition, punctuality, communication, price_value

  Review({
    required this.id,
    required this.rentalId,
    required this.reviewerName,
    required this.reviewerRole,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.categories,
  });

  String get formattedRating => rating.toStringAsFixed(1);

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rentalId: json['rentalId'],
      reviewerName: json['reviewerName'],
      reviewerRole: json['reviewerRole'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      categories: List<String>.from(json['categories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rentalId': rentalId,
      'reviewerName': reviewerName,
      'reviewerRole': reviewerRole,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'categories': categories,
    };
  }
}

class RenterRating {
  final String id;
  final String renterName;
  final String renterEmail;
  final double averageRating; // Promedio de todas sus valoraciones
  final int totalReviews;
  final List<Review> reviews;
  final bool isVerified;

  RenterRating({
    required this.id,
    required this.renterName,
    required this.renterEmail,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
    required this.isVerified,
  });

  String get formattedAverageRating => averageRating.toStringAsFixed(1);

  factory RenterRating.fromJson(Map<String, dynamic> json) {
    return RenterRating(
      id: json['id'],
      renterName: json['renterName'],
      renterEmail: json['renterEmail'],
      averageRating: json['averageRating'].toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      reviews: (json['reviews'] as List?)
              ?.map((r) => Review.fromJson(r))
              .toList() ??
          [],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'renterName': renterName,
      'renterEmail': renterEmail,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'isVerified': isVerified,
    };
  }
}
