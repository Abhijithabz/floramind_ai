import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.category,
    required this.type,
    required this.description,
    required this.price,
    required this.location,
    required this.stock,
    required this.isPlant,
    required this.createdAt,
    required this.isFeatured,
    this.discountPrice,
    this.imageUrl = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.scientificName = '',
    this.sunlight = '',
    this.watering = '',
    this.soil = '',
    this.height = '',
    this.updatedAt,
    this.isFavorite = false,
    this.benefits = const <String>[],
    this.careNotes = const <String>[],
    this.deliveryInfo = '',
    this.tags = const <String>[],
    this.listingStatus = 'Active',
    this.isActive = true,
  });

  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String category;
  final String type;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String location;
  final int stock;
  final bool isPlant;
  final String scientificName;
  final String sunlight;
  final String watering;
  final String soil;
  final String height;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;
  final List<String> benefits;
  final List<String> careNotes;
  final String deliveryInfo;
  final List<String> tags;
  final String listingStatus;

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  bool get isOutOfStock => stock <= 0;

  Product copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? name,
    String? category,
    String? type,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? location,
    int? stock,
    bool? isPlant,
    String? scientificName,
    String? sunlight,
    String? watering,
    String? soil,
    String? height,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? benefits,
    List<String>? careNotes,
    String? deliveryInfo,
    List<String>? tags,
    String? listingStatus,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location ?? this.location,
      stock: stock ?? this.stock,
      isPlant: isPlant ?? this.isPlant,
      scientificName: scientificName ?? this.scientificName,
      sunlight: sunlight ?? this.sunlight,
      watering: watering ?? this.watering,
      soil: soil ?? this.soil,
      height: height ?? this.height,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      benefits: benefits ?? this.benefits,
      careNotes: careNotes ?? this.careNotes,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      tags: tags ?? this.tags,
      listingStatus: listingStatus ?? this.listingStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'name': name,
      'category': category,
      'type': type,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'stock': stock,
      'isPlant': isPlant,
      'scientificName': scientificName,
      'sunlight': sunlight,
      'watering': watering,
      'soil': soil,
      'height': height,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'benefits': benefits,
      'careNotes': careNotes,
      'deliveryInfo': deliveryInfo,
      'tags': tags,
      'listingStatus': listingStatus,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Product(
      id: (map['id'] as String?) ?? docId ?? '',
      sellerId: (map['sellerId'] as String?) ?? '',
      sellerName: (map['sellerName'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      type: (map['type'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (map['discountPrice'] as num?)?.toDouble(),
      imageUrl: (map['imageUrl'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      location: (map['location'] as String?) ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      isPlant: (map['isPlant'] as bool?) ?? false,
      scientificName: (map['scientificName'] as String?) ?? '',
      sunlight: (map['sunlight'] as String?) ?? '',
      watering: (map['watering'] as String?) ?? '',
      soil: (map['soil'] as String?) ?? '',
      height: (map['height'] as String?) ?? '',
      isFeatured: (map['isFeatured'] as bool?) ?? false,
      isActive: (map['isActive'] as bool?) ??
          ((map['listingStatus'] as String?) ?? 'Active') != 'Draft',
      createdAt: _dateFromValue(map['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromValue(map['updatedAt']),
      isFavorite: false,
      benefits: _stringList(map['benefits']),
      careNotes: _stringList(map['careNotes']),
      deliveryInfo: (map['deliveryInfo'] as String?) ?? '',
      tags: _stringList(map['tags']),
      listingStatus: (map['listingStatus'] as String?) ?? 'Active',
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) {
      return null;
    }
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

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const <String>[];
  }
}
