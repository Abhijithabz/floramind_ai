import 'dart:math' as math;

import 'package:flutter/material.dart';

class LocationPoint {
  const LocationPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  String get displayLabel =>
      'Current location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}

class NearbyNursery {
  const NearbyNursery({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.openingHours,
    required this.isOpenNow,
    required this.contactNumber,
    required this.services,
    required this.description,
    required this.categories,
    required this.accentColor,
    required this.fallbackDistanceLabel,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final String openingHours;
  final bool isOpenNow;
  final String contactNumber;
  final List<String> services;
  final String description;
  final List<String> categories;
  final Color accentColor;
  final String fallbackDistanceLabel;
  final double? distanceKm;

  String get distanceLabel =>
      distanceKm == null ? fallbackDistanceLabel : _formatDistance(distanceKm!);

  double get sortDistanceKm => distanceKm ?? fallbackDistanceKm ?? double.infinity;

  double? get fallbackDistanceKm => _parseDistanceLabel(fallbackDistanceLabel);

  String get openingStatusLabel {
    if (openingHours.trim().toLowerCase() == 'hours not listed') {
      return 'Hours not listed';
    }
    return isOpenNow ? 'Open now' : 'Closed now';
  }

  bool matchesCategory(String category) {
    return category == 'All' || categories.contains(category);
  }

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(normalized) ||
        address.toLowerCase().contains(normalized) ||
        description.toLowerCase().contains(normalized) ||
        services.any((service) => service.toLowerCase().contains(normalized));
  }

  NearbyNursery withDistance(LocationPoint? origin) {
    if (origin == null) {
      return copyWith(distanceKm: null);
    }

    return copyWith(
      distanceKm: _distanceBetween(
        origin.latitude,
        origin.longitude,
        latitude,
        longitude,
      ),
    );
  }

  NearbyNursery copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    String? openingHours,
    bool? isOpenNow,
    String? contactNumber,
    List<String>? services,
    String? description,
    List<String>? categories,
    Color? accentColor,
    String? fallbackDistanceLabel,
    double? distanceKm,
  }) {
    return NearbyNursery(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      openingHours: openingHours ?? this.openingHours,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      contactNumber: contactNumber ?? this.contactNumber,
      services: services ?? this.services,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      accentColor: accentColor ?? this.accentColor,
      fallbackDistanceLabel: fallbackDistanceLabel ?? this.fallbackDistanceLabel,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

double _distanceBetween(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  const earthRadiusKm = 6371.0;
  final dLat = _degreesToRadians(endLatitude - startLatitude);
  final dLng = _degreesToRadians(endLongitude - startLongitude);
  final lat1 = _degreesToRadians(startLatitude);
  final lat2 = _degreesToRadians(endLatitude);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) => degrees * (math.pi / 180.0);

String _formatDistance(double distanceKm) {
  if (distanceKm < 1) {
    return '${(distanceKm * 1000).round()} m away';
  }

  return '${distanceKm.toStringAsFixed(distanceKm >= 10 ? 0 : 1)} km away';
}

double? _parseDistanceLabel(String label) {
  final normalized = label.trim().toLowerCase();
  final match = RegExp(r'([\d.]+)\s*(km|m)').firstMatch(normalized);
  if (match == null) {
    return null;
  }

  final value = double.tryParse(match.group(1) ?? '');
  if (value == null) {
    return null;
  }

  final unit = match.group(2);
  if (unit == 'm') {
    return value / 1000;
  }

  return value;
}
