import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  const Review({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String reviewId;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reviewId': reviewId,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, {String? docId}) {
    final createdAtValue = map['createdAt'];
    return Review(
      reviewId: (map['reviewId'] as String?) ?? docId ?? '',
      productId: (map['productId'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      userName: (map['userName'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: (map['comment'] as String?) ?? '',
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.tryParse(createdAtValue?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

