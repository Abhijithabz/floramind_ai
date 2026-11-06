import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/plant_info.dart';

class PlantInfoService {
  const PlantInfoService();

  static const String _collectionName = 'plant_information';

  Future<PlantInfo?> fetchPlantInfo({
    String? plantName,
    String? scientificName,
  }) async {
    if (Firebase.apps.isEmpty) {
      return null;
    }

    final candidates = <String>[
      if (scientificName?.trim().isNotEmpty == true)
        PlantInfo.documentIdFor(scientificName!),
      if (plantName?.trim().isNotEmpty == true)
        PlantInfo.documentIdFor(plantName!),
    ];

    final collection = FirebaseFirestore.instance.collection(_collectionName);
    for (final candidate in candidates) {
      if (candidate.isEmpty) {
        continue;
      }

      final doc = await collection.doc(candidate).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        return PlantInfo.fromMap(data);
      }
    }

    if (scientificName?.trim().isNotEmpty == true) {
      final query = await collection
          .where('scientificName', isEqualTo: scientificName)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return PlantInfo.fromMap(query.docs.first.data());
      }
    }

    if (plantName?.trim().isNotEmpty == true) {
      final query = await collection
          .where('plantName', isEqualTo: plantName)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return PlantInfo.fromMap(query.docs.first.data());
      }
    }

    return null;
  }

  Future<bool> savePlantInfo(PlantInfo info) async {
    if (Firebase.apps.isEmpty) {
      return false;
    }

    final documentId = PlantInfo.documentIdFor(info.scientificName.isNotEmpty
        ? info.scientificName
        : info.plantName);
    if (documentId.isEmpty) {
      return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(documentId)
          .set(info.toMap());
      return true;
    } on FirebaseException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
