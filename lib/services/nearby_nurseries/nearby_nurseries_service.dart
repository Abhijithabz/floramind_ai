import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/nearby_nursery.dart';

abstract class NearbyNurseriesService {
  const NearbyNurseriesService();

  Future<List<NearbyNursery>> fetchNurseries({
    LocationPoint? currentLocation,
  });

  Future<NearbyNursery?> fetchRecommendedNursery({
    LocationPoint? currentLocation,
  });
}

class SampleNearbyNurseriesService extends NearbyNurseriesService {
  const SampleNearbyNurseriesService();

  static const List<NearbyNursery> _nurseries = <NearbyNursery>[
    NearbyNursery(
      id: 'green-haven',
      name: 'Green Haven Nursery',
      address: '12 Garden Lane, Sector 18, Green Park',
      latitude: 28.5636,
      longitude: 77.2106,
      rating: 4.9,
      openingHours: 'Open today until 8:00 PM',
      isOpenNow: true,
      contactNumber: '+91 98765 43210',
      services: ['Plants', 'Seeds', 'Pots', 'Garden Tools'],
      description:
          'A premium neighborhood nursery known for healthy saplings and curated garden accessories.',
      categories: ['Plants', 'Seeds', 'Pots', 'Garden Tools'],
      accentColor: Color(0xFF2E7D32),
      fallbackDistanceLabel: '1.2 km away',
    ),
    NearbyNursery(
      id: 'bloom-grow',
      name: 'Bloom & Grow Nursery',
      address: '44 Palm Street, Civil Lines, City Center',
      latitude: 28.6174,
      longitude: 77.2139,
      rating: 4.7,
      openingHours: 'Open today until 7:30 PM',
      isOpenNow: true,
      contactNumber: '+91 91234 56789',
      services: ['Plants', 'Fertilizers', 'Seeds'],
      description:
          'Trusted by home gardeners for indoor plants, flowering shrubs, and seasonal fertilizer bundles.',
      categories: ['Plants', 'Fertilizers', 'Seeds'],
      accentColor: Color(0xFF43A047),
      fallbackDistanceLabel: '2.4 km away',
    ),
    NearbyNursery(
      id: 'earthroot',
      name: 'EarthRoot Garden Store',
      address: '89 Orchard Road, Lake View Colony',
      latitude: 28.5355,
      longitude: 77.3910,
      rating: 4.8,
      openingHours: 'Open today until 9:00 PM',
      isOpenNow: true,
      contactNumber: '+91 99887 76655',
      services: ['Plants', 'Fertilizers', 'Garden Tools', 'Pots'],
      description:
          'A modern garden store offering plant care essentials, decorative pots, and quality tools.',
      categories: ['Plants', 'Fertilizers', 'Pots', 'Garden Tools'],
      accentColor: Color(0xFF66BB6A),
      fallbackDistanceLabel: '3.1 km away',
    ),
    NearbyNursery(
      id: 'sprout-corner',
      name: 'Sprout Corner Nursery',
      address: '21 Banyan Avenue, Rose Garden Area',
      latitude: 28.4595,
      longitude: 77.0266,
      rating: 4.6,
      openingHours: 'Open today until 6:45 PM',
      isOpenNow: false,
      contactNumber: '+91 97654 32109',
      services: ['Seeds', 'Pots', 'Garden Tools'],
      description:
          'Popular for seed kits, small-space gardening supplies, and balcony-friendly plant options.',
      categories: ['Seeds', 'Pots', 'Garden Tools'],
      accentColor: Color(0xFF4C8BF5),
      fallbackDistanceLabel: '4.0 km away',
    ),
    NearbyNursery(
      id: 'fresh-leaf',
      name: 'Fresh Leaf Nursery',
      address: '77 Willow Drive, Serenity Enclave',
      latitude: 28.7041,
      longitude: 77.1025,
      rating: 4.5,
      openingHours: 'Open today until 7:00 PM',
      isOpenNow: true,
      contactNumber: '+91 90011 22334',
      services: ['Plants', 'Seeds', 'Fertilizers', 'Pots'],
      description:
          'A calm, premium nursery with carefully maintained flowering plants and home-garden essentials.',
      categories: ['Plants', 'Seeds', 'Fertilizers', 'Pots'],
      accentColor: Color(0xFFF4A261),
      fallbackDistanceLabel: '5.3 km away',
    ),
  ];

  @override
  Future<List<NearbyNursery>> fetchNurseries({
    LocationPoint? currentLocation,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final nurseries = _nurseries
        .map((nursery) => nursery.withDistance(currentLocation))
        .toList(growable: true);

    nurseries.sort(_compareByDistanceThenRating);
    return nurseries;
  }

  @override
  Future<NearbyNursery?> fetchRecommendedNursery({
    LocationPoint? currentLocation,
  }) async {
    final nurseries = await fetchNurseries(currentLocation: currentLocation);
    if (nurseries.isEmpty) {
      return null;
    }

    return nurseries.first;
  }
}

class PlacesNearbyNurseriesService extends NearbyNurseriesService {
  const PlacesNearbyNurseriesService();

  static const List<String> _overpassHosts = <String>[
    'overpass-api.de',
    'overpass.kumi.systems',
  ];

  @override
  Future<List<NearbyNursery>> fetchNurseries({
    LocationPoint? currentLocation,
  }) async {
    if (currentLocation == null) {
      return const <NearbyNursery>[];
    }

    const searchRadiusMeters = 10000;
    final query = '''
[out:json][timeout:15];
(
  nwr(around:${searchRadiusMeters},${currentLocation.latitude},${currentLocation.longitude})["shop"="garden_centre"];
  nwr(around:${searchRadiusMeters},${currentLocation.latitude},${currentLocation.longitude})["shop"="plant_nursery"];
  nwr(around:${searchRadiusMeters},${currentLocation.latitude},${currentLocation.longitude})["landuse"="plant_nursery"];
  nwr(around:${searchRadiusMeters},${currentLocation.latitude},${currentLocation.longitude})["name"~"nursery|nurseries|garden centre|garden center|plant shop|plants",i];
);
out center tags;
''';

    final responses = await Future.wait(
      _overpassHosts.map(
        (host) => _requestOverpass(host, query),
      ),
    );
    final response = responses.firstWhere(
      (candidate) => candidate != null && candidate.statusCode == 200,
      orElse: () => null,
    );

    if (response == null) {
      throw Exception('Live nursery search timed out or was unavailable.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid nursery search response.');
    }

    final elements = decoded['elements'];
    if (elements is! List) {
      return const <NearbyNursery>[];
    }

    final results = <NearbyNursery>[];
    final seen = <String>{};
    for (final element in elements) {
      if (element is! Map<String, dynamic>) {
        continue;
      }

      final tags = _stringMap(element['tags']);
      final coordinates = _coordinates(element);
      final name = tags['name']?.trim();
      if (name == null || name.isEmpty || coordinates == null) {
        continue;
      }

      final id = 'osm-${element['type']}-${element['id']}';
      if (!seen.add(id)) {
        continue;
      }

      final nursery = NearbyNursery(
        id: id,
        name: name,
        address: _addressFromTags(tags),
        latitude: coordinates.$1,
        longitude: coordinates.$2,
        rating: 0,
        openingHours: tags['opening_hours'] ?? 'Hours not listed',
        // OpenStreetMap does not reliably provide a live open/closed status.
        isOpenNow: false,
        contactNumber: tags['phone'] ?? tags['contact:phone'] ?? '',
        services: _servicesFromTags(tags),
        description:
            'Listed on OpenStreetMap. Check the listing for current details.',
        categories: _servicesFromTags(tags),
        accentColor: const Color(0xFF2E7D32),
        fallbackDistanceLabel: 'Distance unavailable',
      ).withDistance(currentLocation);
      if (nursery.distanceKm != null && nursery.distanceKm! <= 10) {
        results.add(nursery);
      }
    }

    results.sort(_compareByDistanceThenRating);
    if (results.isNotEmpty) {
      return results;
    }

    return _fetchNominatimNurseries(currentLocation);
  }

  Future<http.Response?> _requestOverpass(String host, String query) async {
    try {
      return await http
          .get(
            Uri.https(
              host,
              '/api/interpreter',
              <String, String>{'data': query},
            ),
            headers: const <String, String>{
              'Accept': 'application/json',
              'User-Agent': 'FloraMind/1.0 (plant nursery finder)',
            },
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    }
  }

  Future<List<NearbyNursery>> _fetchNominatimNurseries(
    LocationPoint currentLocation,
  ) async {
    const searchRadiusKm = 10.0;
    final latitudeDelta = searchRadiusKm / 111.0;
    final longitudeDelta = searchRadiusKm /
        (111.0 * math.cos(currentLocation.latitude * math.pi / 180.0));
    final viewbox = [
      currentLocation.longitude - longitudeDelta,
      currentLocation.latitude + latitudeDelta,
      currentLocation.longitude + longitudeDelta,
      currentLocation.latitude - latitudeDelta,
    ].join(',');

    try {
      final response = await http
          .get(
            Uri.https(
              'nominatim.openstreetmap.org',
              '/search',
              <String, String>{
                'q': 'nursery',
                'format': 'jsonv2',
                'limit': '30',
                'viewbox': viewbox,
                'bounded': '1',
                'addressdetails': '1',
              },
            ),
            headers: const <String, String>{
              'Accept': 'application/json',
              'User-Agent': 'FloraMind/1.0 (plant nursery finder)',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return const <NearbyNursery>[];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return const <NearbyNursery>[];
      }

      final results = <NearbyNursery>[];
      final seen = <String>{};
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final latitude = double.tryParse(item['lat']?.toString() ?? '');
        final longitude = double.tryParse(item['lon']?.toString() ?? '');
        if (latitude == null || longitude == null) {
          continue;
        }

        final nursery = NearbyNursery(
          id: 'nominatim-${item['osm_type']}-${item['osm_id']}',
          name: (item['name']?.toString().trim().isNotEmpty == true)
              ? item['name'].toString().trim()
              : item['display_name']?.toString().split(',').first.trim() ??
                  'Plant nursery',
          address: item['display_name']?.toString() ?? 'Address not listed',
          latitude: latitude,
          longitude: longitude,
          rating: 0,
          openingHours: 'Hours not listed',
          isOpenNow: true,
          contactNumber: '',
          services: const <String>['Plants', 'Garden supplies'],
          description:
              'Real place listing from OpenStreetMap. Check Maps for current details.',
          categories: const <String>['Plants', 'Garden supplies'],
          accentColor: const Color(0xFF2E7D32),
          fallbackDistanceLabel: 'Distance unavailable',
        ).withDistance(currentLocation);

        if (nursery.distanceKm != null &&
            nursery.distanceKm! <= searchRadiusKm &&
            seen.add(nursery.id)) {
          results.add(nursery);
        }
      }

      results.sort(_compareByDistanceThenRating);
      return results;
    } catch (_) {
      return const <NearbyNursery>[];
    }
  }

  @override
  Future<NearbyNursery?> fetchRecommendedNursery({
    LocationPoint? currentLocation,
  }) async {
    final nurseries = await fetchNurseries(currentLocation: currentLocation);
    return nurseries.isEmpty ? null : nurseries.first;
  }
}

class NearbyNurseryServiceFactory {
  const NearbyNurseryServiceFactory();

  static NearbyNurseriesService create() {
    return const PlacesNearbyNurseriesService();
  }
}

Map<String, String> _stringMap(dynamic value) {
  if (value is! Map) {
    return const <String, String>{};
  }

  return value.map(
    (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
  );
}

(double, double)? _coordinates(Map<String, dynamic> element) {
  final latitude = (element['lat'] as num?)?.toDouble() ??
      ((element['center'] as Map?)?['lat'] as num?)?.toDouble();
  final longitude = (element['lon'] as num?)?.toDouble() ??
      ((element['center'] as Map?)?['lon'] as num?)?.toDouble();
  if (latitude == null || longitude == null) {
    return null;
  }
  return (latitude, longitude);
}

String _addressFromTags(Map<String, String> tags) {
  final parts = <String>[
    if ((tags['addr:housenumber'] ?? '').isNotEmpty) tags['addr:housenumber']!,
    if ((tags['addr:street'] ?? '').isNotEmpty) tags['addr:street']!,
    if ((tags['addr:suburb'] ?? '').isNotEmpty) tags['addr:suburb']!,
    if ((tags['addr:city'] ?? '').isNotEmpty) tags['addr:city']!,
  ];
  return parts.isEmpty ? 'Address not listed' : parts.join(', ');
}

List<String> _servicesFromTags(Map<String, String> tags) {
  final services = <String>['Plants'];
  if (tags['shop'] == 'garden_centre') {
    services.add('Garden supplies');
  }
  if ((tags['product'] ?? '').toLowerCase().contains('seed')) {
    services.add('Seeds');
  }
  return services;
}

int _compareByDistanceThenRating(NearbyNursery left, NearbyNursery right) {
  final distanceComparison = left.sortDistanceKm.compareTo(right.sortDistanceKm);
  if (distanceComparison != 0) {
    return distanceComparison;
  }

  final ratingComparison = right.rating.compareTo(left.rating);
  if (ratingComparison != 0) {
    return ratingComparison;
  }

  return left.name.compareTo(right.name);
}
