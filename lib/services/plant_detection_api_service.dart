import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/backend_config.dart';
import '../models/plant_identification_result.dart';

class PlantDetectionApiException implements Exception {
  PlantDetectionApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class PlantDetectionApiService {
  PlantDetectionApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<PlantIdentificationResult> identifyPlant({
    required Uint8List imageBytes,
    required String fileName,
    String organ = 'flower',
  }) async {
    http.Response response;
    try {
      response = await _client
          .post(
            BackendConfig.geminiUri('/identifyPlant'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(<String, dynamic>{
              'imageBase64': base64Encode(imageBytes),
              'fileName': fileName,
              'organ': organ,
            }),
          )
          // A sleeping Render free instance can take up to about a minute to wake.
          .timeout(const Duration(seconds: 75));
    } on TimeoutException {
      debugPrint('Plant identification backend error: request timed out.');
      throw PlantDetectionApiException(
        'The plant identification request took too long. Please try again.',
      );
    } on StateError catch (error) {
      debugPrint('Plant identification backend error: ${error.message}');
      throw PlantDetectionApiException(error.message);
    } catch (_) {
      debugPrint('Plant identification backend error: unable to reach backend.');
      throw PlantDetectionApiException(
        'Unable to reach the plant identification service. Please check your connection and try again.',
      );
    }

    final decoded = _decodeJson(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? (decoded['message'] as String? ??
              'Plant identification failed on the server.')
          : 'Plant identification failed on the server.';
      throw PlantDetectionApiException(message, statusCode: response.statusCode);
    }

    if (decoded is! Map<String, dynamic>) {
      throw PlantDetectionApiException(
        'The plant identification backend returned an unexpected response.',
      );
    }

    return PlantIdentificationResult.fromJson(decoded);
  }

  dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
