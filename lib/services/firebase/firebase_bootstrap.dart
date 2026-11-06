import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../config/firebase_config.dart';

class FirebaseBootstrap {
  static Future<void> ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    final options = AppFirebaseConfig.currentPlatform;
    if (options == null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          await Firebase.initializeApp();
          return;
        } catch (error, stackTrace) {
          debugPrint('Firebase default Android initialization failed.');
          debugPrint('$error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
      debugPrint(
        'Firebase is not configured for this build. '
        'The app will continue without Firestore persistence.',
      );
      return;
    }

    try {
      await Firebase.initializeApp(options: options);
    } catch (error, stackTrace) {
      debugPrint(
        'Firebase initialization failed. '
        'The app will continue without Firestore persistence.',
      );
      debugPrint('$error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
