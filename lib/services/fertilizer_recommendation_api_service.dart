import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/backend_config.dart';

class FertilizerRecommendation {
  const FertilizerRecommendation({
    required this.summary,
    required this.npk,
    required this.application,
    required this.cautions,
    required this.source,
  });

  final String summary;
  final String npk;
  final String application;
  final List<String> cautions;
  final String source;
}

class FertilizerRecommendationApiService {
  FertilizerRecommendationApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<FertilizerRecommendation> recommend({
    required String plant,
    required String stage,
    required String condition,
    required String soil,
    required String npk,
  }) async {
    final response = await _client
        .post(
          BackendConfig.geminiUri('/fertilizerRecommendation'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'plant': plant,
            'stage': stage,
            'condition': condition,
            'soil': soil,
            'npk': npk,
          }),
        )
        .timeout(const Duration(seconds: 18));

    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Fertilizer recommendation is unavailable.');
    }

    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception('No fertilizer recommendation was returned.');
    }

    return FertilizerRecommendation(
      summary: decoded['summary']?.toString() ?? '',
      npk: decoded['npk']?.toString() ?? 'Use a soil-test-based product.',
      application: decoded['application']?.toString() ?? '',
      cautions: (decoded['cautions'] is List)
          ? (decoded['cautions'] as List)
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .take(5)
                .toList(growable: false)
          : const [],
      source: decoded['source']?.toString() ?? 'Gemini',
    );
  }
}
