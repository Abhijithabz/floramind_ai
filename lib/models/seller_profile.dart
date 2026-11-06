import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfile {
  const SellerProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SellerProfile.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SellerProfile(
      userId: (map['userId'] as String?) ?? docId ?? '',
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      profileImage: (map['profileImage'] as String?) ?? '',
      createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _toDate(map['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

