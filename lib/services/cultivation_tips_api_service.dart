import 'package:cloud_functions/cloud_functions.dart';

import '../models/crop_profile.dart';

class CultivationTipsApiService {
  const CultivationTipsApiService();

  Future<List<String>> generateTips(CropProfile plant) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'generateCultivationTips',
    );
    final result = await callable.call<Map<String, dynamic>>({
      'plant': plant.name,
      'category': plant.category,
      'temperature': plant.temperature,
      'exposure': plant.exposure,
      'soil': plant.soil,
      'ph': plant.ph,
      'watering': plant.watering,
      'spacing': plant.spacing,
      'stage': 'General cultivation',
    });

    final tips = result.data['tips'];
    if (tips is! List) {
      throw const FormatException('The cultivation tips response was invalid.');
    }
    return tips
        .whereType<String>()
        .map((tip) => tip.trim())
        .where((tip) => tip.isNotEmpty)
        .take(8)
        .toList(growable: false);
  }
}
