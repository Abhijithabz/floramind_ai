import 'package:flutter/foundation.dart';

class BackendConfig {
  static const String _overrideBaseUrl = String.fromEnvironment(
    'FLORAMIND_BACKEND_URL',
    defaultValue: '',
  );
  static const String _geminiBackendUrl = String.fromEnvironment(
    'GEMINI_BACKEND_URL',
    defaultValue: '',
  );

  // USB debugging uses adb reverse, so the phone can reach the local server.
  static String get geminiBaseUrl => _geminiBackendUrl.isNotEmpty
      ? _geminiBackendUrl
      : 'https://floramind-gemini-backend.onrender.com';

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Use the development machine on the connected physical Android network.
        // Override this with FLORAMIND_BACKEND_URL for another network or emulator.
        return 'http://192.168.43.238:5000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:5000';
    }
  }

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static Uri geminiUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$geminiBaseUrl$normalizedPath');
  }
}
