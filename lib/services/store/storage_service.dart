import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  const StorageService();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  Future<String?> uploadProductImage({
    required String sellerId,
    required String productId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (!isAvailable) {
      return null;
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('products/$sellerId/$productId/image_$fileName');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadSellerProfileImage({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (!isAvailable) {
      return null;
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('seller_profiles/$userId/profile_$fileName');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}

