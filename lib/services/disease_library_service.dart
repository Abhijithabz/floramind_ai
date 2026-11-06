import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../data/plant_disease_library_sample_data.dart';
import '../models/disease_severity.dart';
import '../models/plant_disease.dart';
import '../models/plant_profile.dart';
import 'firebase/firebase_bootstrap.dart';

class DiseaseLibraryData {
  const DiseaseLibraryData({
    required this.plants,
    required this.diseases,
  });

  final List<PlantProfile> plants;
  final List<PlantDisease> diseases;

  bool get isEmpty => plants.isEmpty && diseases.isEmpty;
}

class DiseaseLibraryMatchData {
  const DiseaseLibraryMatchData({
    required this.requestedPlantName,
    required this.requestedScientificName,
    required this.requestedPlantId,
    required this.plant,
    required this.diseases,
  });

  final String requestedPlantName;
  final String requestedScientificName;
  final String requestedPlantId;
  final PlantProfile? plant;
  final List<PlantDisease> diseases;

  bool get isEmpty => diseases.isEmpty;

  String get displayPlantName {
    final resolvedName = (plant?.commonName ?? '').trim();
    if (resolvedName.isNotEmpty) {
      return resolvedName;
    }

    if (requestedPlantName.trim().isNotEmpty) {
      return requestedPlantName.trim();
    }

    if (requestedScientificName.trim().isNotEmpty) {
      return requestedScientificName.trim();
    }

    return 'Unknown plant';
  }

  String get displayPlantId {
    final resolvedId = (plant?.id ?? '').trim();
    if (resolvedId.isNotEmpty) {
      return resolvedId;
    }

    return requestedPlantId.trim();
  }
}

abstract class DiseaseLibraryService {
  const DiseaseLibraryService();

  Future<DiseaseLibraryData> loadLibrary();

  Future<DiseaseLibraryMatchData> loadMatchesForPlant({
    String? plantName,
    String? scientificName,
    String? plantId,
  });
}

class FirestoreDiseaseLibraryService extends DiseaseLibraryService {
  const FirestoreDiseaseLibraryService();

  static const String _plantsCollection = 'plants';
  static const String _diseasesCollection = 'diseases';
  static const String _pestsCollection = 'pests';

  @override
  Future<DiseaseLibraryData> loadLibrary() async {
    await FirebaseBootstrap.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      return const DiseaseLibraryData(
        plants: sampleLibraryPlants,
        diseases: sampleLibraryDiseases,
      );
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final plantsSnapshot = await firestore.collection(_plantsCollection).get();
      final plants = plantsSnapshot.docs.map(_plantFromDoc).toList(growable: false);

      final plantsById = <String, PlantProfile>{
        for (final plant in plants) plant.id: plant,
      };

      final diseasesSnapshot = await firestore.collection(_diseasesCollection).get();
      final pestsSnapshot = await firestore.collection(_pestsCollection).get();

      final diseases = <PlantDisease>[
        ...diseasesSnapshot.docs.map(
          (doc) => _conditionFromDoc(
            doc,
            plantsById: plantsById,
            isPest: false,
          ),
        ),
        ...pestsSnapshot.docs.map(
          (doc) => _conditionFromDoc(
            doc,
            plantsById: plantsById,
            isPest: true,
          ),
        ),
      ]..sort((left, right) => left.name.toLowerCase().compareTo(right.name.toLowerCase()));

      return DiseaseLibraryData(plants: plants, diseases: diseases);
    } on FirebaseException {
      return const DiseaseLibraryData(
        plants: sampleLibraryPlants,
        diseases: sampleLibraryDiseases,
      );
    }
  }

  @override
  Future<DiseaseLibraryMatchData> loadMatchesForPlant({
    String? plantName,
    String? scientificName,
    String? plantId,
  }) async {
    await FirebaseBootstrap.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      final plants = sampleLibraryPlants;
      final resolvedPlant = _resolvePlant(
        plants,
        plantName: plantName,
        scientificName: scientificName,
        plantId: plantId,
      );
      return DiseaseLibraryMatchData(
        requestedPlantName: plantName?.trim() ?? '',
        requestedScientificName: scientificName?.trim() ?? '',
        requestedPlantId: plantId?.trim() ?? '',
        plant: resolvedPlant,
        diseases: resolvedPlant == null
            ? const <PlantDisease>[]
            : sampleLibraryDiseases
                .where((disease) => disease.matchesPlant(resolvedPlant.id))
                .toList(growable: false),
      );
    }

    List<PlantProfile> plants;
    try {
      plants = await _fetchPlants();
    } on FirebaseException {
      return _sampleMatches(
        plantName: plantName,
        scientificName: scientificName,
        plantId: plantId,
      );
    }

    if (plants.isEmpty) {
      return _sampleMatches(
        plantName: plantName,
        scientificName: scientificName,
        plantId: plantId,
      );
    }
    final resolvedPlant = _resolvePlant(
      plants,
      plantName: plantName,
      scientificName: scientificName,
      plantId: plantId,
    );

    if (resolvedPlant == null) {
      return _sampleMatches(
        plantName: plantName,
        scientificName: scientificName,
        plantId: plantId,
      );
    }

    final firestore = FirebaseFirestore.instance;
    final diseaseSnapshot = await firestore
        .collection(_diseasesCollection)
        .where('plantId', isEqualTo: resolvedPlant.id)
        .get();
    final pestSnapshot = await firestore
        .collection(_pestsCollection)
        .where('plantId', isEqualTo: resolvedPlant.id)
        .get();

    final diseases = <PlantDisease>[
      ...diseaseSnapshot.docs.map(
        (doc) => _conditionFromDoc(
          doc,
          plantsById: {resolvedPlant.id: resolvedPlant},
          isPest: false,
        ),
      ),
      ...pestSnapshot.docs.map(
        (doc) => _conditionFromDoc(
          doc,
          plantsById: {resolvedPlant.id: resolvedPlant},
          isPest: true,
        ),
      ),
    ]..sort((left, right) {
        final severityOrder = right.severity.index.compareTo(left.severity.index);
        if (severityOrder != 0) {
          return severityOrder;
        }
        return left.name.toLowerCase().compareTo(right.name.toLowerCase());
      });

    if (diseases.isEmpty) {
      return _sampleMatches(
        plantName: plantName,
        scientificName: scientificName,
        plantId: plantId,
      );
    }

    return DiseaseLibraryMatchData(
      requestedPlantName: plantName?.trim() ?? '',
      requestedScientificName: scientificName?.trim() ?? '',
      requestedPlantId: plantId?.trim() ?? '',
      plant: resolvedPlant,
      diseases: diseases,
    );
  }

  Future<List<PlantProfile>> _fetchPlants() async {
    final snapshot = await FirebaseFirestore.instance.collection(_plantsCollection).get();
    return snapshot.docs.map(_plantFromDoc).toList(growable: false);
  }

  DiseaseLibraryMatchData _sampleMatches({
    String? plantName,
    String? scientificName,
    String? plantId,
  }) {
    final resolvedPlant = _resolvePlant(
      sampleLibraryPlants,
      plantName: plantName,
      scientificName: scientificName,
      plantId: plantId,
    );
    return DiseaseLibraryMatchData(
      requestedPlantName: plantName?.trim() ?? '',
      requestedScientificName: scientificName?.trim() ?? '',
      requestedPlantId: plantId?.trim() ?? '',
      plant: resolvedPlant,
      diseases: resolvedPlant == null
          ? const <PlantDisease>[]
          : sampleLibraryDiseases
              .where((disease) => disease.matchesPlant(resolvedPlant.id))
              .toList(growable: false),
    );
  }

  PlantProfile? _resolvePlant(
    List<PlantProfile> plants, {
    String? plantName,
    String? scientificName,
    String? plantId,
  }) {
    final candidates = <String>[
      if (plantId?.trim().isNotEmpty == true) plantId!.trim(),
      if (plantName?.trim().isNotEmpty == true) plantName!.trim(),
      if (scientificName?.trim().isNotEmpty == true) scientificName!.trim(),
    ];

    for (final candidate in candidates) {
      final normalizedCandidate = _normalize(candidate);
      for (final plant in plants) {
        if (_matchesPlantIdentity(plant, normalizedCandidate)) {
          return plant;
        }
      }
    }

    final query = candidates.join(' ').trim().toLowerCase();
    if (query.isEmpty) {
      return null;
    }

    for (final plant in plants) {
      if (plant.matchesQuery(query)) {
        return plant;
      }
    }

    return null;
  }

  PlantProfile _plantFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final id = _readString(data, const ['id', 'plantId'], fallback: doc.id);
    final commonName = _readString(
      data,
      const ['commonName', 'name', 'plantName'],
      fallback: _humanizeId(doc.id),
    );

    return PlantProfile(
      id: id.isEmpty ? doc.id : id,
      commonName: commonName,
      scientificName: _readString(data, const ['scientificName', 'botanicalName']),
      category: _readString(data, const ['category', 'type'], fallback: 'Plant'),
      aliases: _readStringList(data, const ['aliases', 'alternateNames', 'synonyms']),
      description: _readString(data, const ['description', 'overview']),
    );
  }

  PlantDisease _conditionFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required Map<String, PlantProfile> plantsById,
    required bool isPest,
  }) {
    final data = doc.data();
    final id = _readString(data, const ['id'], fallback: doc.id);
    final name = _readString(data, const ['name'], fallback: _humanizeId(doc.id));
    final plantId = _readString(data, const ['plantId', 'plantID']);
    final plant = plantsById[plantId];
    final symptoms = _readStringList(data, const ['symptoms']);
    final causes = _readStringList(data, const ['causes']);
    final remedies = _readStringList(data, const ['remedies', 'treatments', 'treatment']);
    final prevention = _readStringList(data, const ['prevention']);
    final severity = _parseSeverity(data['severity']);
    final overview = _readString(
      data,
      const ['overview', 'description', 'summary'],
      fallback: _buildOverview(name, symptoms),
    );
    final plantName = (plant?.commonName ?? '').trim();

    return PlantDisease(
      id: id.isEmpty ? doc.id : id,
      name: name,
      type: isPest ? 'Insect Pest' : 'Plant Disease',
      severity: severity,
      affectedPlantIds: plantId.isEmpty ? const <String>[] : <String>[plantId],
      affectedPlantNames: <String>[
        if (plantName.isNotEmpty)
          plantName
        else if (plantId.isNotEmpty)
          plantId,
      ],
      overview: overview,
      imageLabel: _readString(data, const ['imageLabel'], fallback: name),
      imageUrl: _readString(data, const ['imageUrl']),
      symptoms: symptoms,
      causes: causes,
      remedies: remedies,
      prevention: prevention,
    );
  }

  String _buildOverview(String name, List<String> symptoms) {
    if (symptoms.isEmpty) {
      return 'Reference card for $name.';
    }

    final preview = symptoms.length == 1 ? symptoms.first : symptoms.take(2).join(', ');
    return 'Common signs include $preview.';
  }

  String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  List<String> _readStringList(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is Iterable) {
        final items = value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
        if (items.isNotEmpty) {
          return items;
        }
      } else if (value is String && value.trim().isNotEmpty) {
        return <String>[value.trim()];
      }
    }

    return const <String>[];
  }

  DiseaseSeverity _parseSeverity(Object? rawSeverity) {
    if (rawSeverity is int) {
      if (rawSeverity <= 0) {
        return DiseaseSeverity.low;
      }
      if (rawSeverity == 1) {
        return DiseaseSeverity.moderate;
      }
      if (rawSeverity == 2) {
        return DiseaseSeverity.high;
      }
      return DiseaseSeverity.critical;
    }

    final normalized = rawSeverity?.toString().trim().toLowerCase() ?? '';
    switch (normalized) {
      case '0':
      case 'low':
        return DiseaseSeverity.low;
      case '1':
      case 'moderate':
      case 'medium':
        return DiseaseSeverity.moderate;
      case '2':
      case 'high':
        return DiseaseSeverity.high;
      case '3':
      case 'critical':
      case 'severe':
        return DiseaseSeverity.critical;
      default:
        return DiseaseSeverity.moderate;
    }
  }

  String _humanizeId(String value) {
    final text = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (text.isEmpty) {
      return value;
    }

    return text
        .split(RegExp(r'\s+'))
        .map((part) {
          if (part.isEmpty) {
            return part;
          }
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        })
        .join(' ');
  }

  bool _matchesPlantIdentity(PlantProfile plant, String normalizedCandidate) {
    final identifiers = <String>[
      plant.id,
      plant.commonName,
      plant.scientificName,
      ...plant.aliases,
    ].map(_normalize);

    return identifiers.any((identifier) => identifier == normalizedCandidate);
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
