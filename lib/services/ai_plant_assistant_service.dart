import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/community_post.dart';
import '../models/disease_severity.dart';
import '../models/plant_disease.dart';
import '../models/plant_info.dart';
import '../models/plant_profile.dart';
import '../models/product.dart';
import 'community/community_service.dart';
import 'disease_library_service.dart';
import 'firebase/firebase_bootstrap.dart';
import 'store/product_service.dart';

enum AssistantTopic {
  plantCare,
  diseaseHelp,
  watering,
  fertilizer,
  gardenTips,
  general,
}

class AssistantResponse {
  const AssistantResponse({
    required this.message,
    required this.topic,
  });

  final String message;
  final AssistantTopic topic;
}

class AssistantKnowledgeException implements Exception {
  const AssistantKnowledgeException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _AssistantKnowledgeBase {
  const _AssistantKnowledgeBase({
    required this.plantInfos,
    required this.diseaseLibrary,
    required this.products,
    required this.communityPosts,
  });

  final List<PlantInfo> plantInfos;
  final DiseaseLibraryData diseaseLibrary;
  final List<Product> products;
  final List<CommunityPost> communityPosts;
}

class _ResolvedPlant {
  const _ResolvedPlant({
    required this.displayName,
    required this.plantInfo,
    required this.plantProfile,
  });

  final String displayName;
  final PlantInfo? plantInfo;
  final PlantProfile? plantProfile;
}

class FirestoreAssistantService {
  const FirestoreAssistantService();

  static const _diseaseService = FirestoreDiseaseLibraryService();
  static const _productService = ProductService();
  static const _communityService = CommunityService();

  static Future<_AssistantKnowledgeBase>? _cachedLoad;

  Future<AssistantResponse> answerQuestion(String question) async {
    await FirebaseBootstrap.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      throw const AssistantKnowledgeException(
        'Firebase is not configured for this build.',
      );
    }

    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty) {
      return const AssistantResponse(
        message:
            'Ask me about plant care, diseases, watering, fertilizers, or garden tips, and I will look up the Firestore garden data.',
        topic: AssistantTopic.general,
      );
    }

    final knowledge = await _loadKnowledgeBase();
    final topic = _detectTopic(normalizedQuestion);
    final resolvedPlant = _resolvePlant(normalizedQuestion, knowledge);

    switch (topic) {
      case AssistantTopic.diseaseHelp:
        return AssistantResponse(
          message: _buildDiseaseAnswer(normalizedQuestion, knowledge, resolvedPlant),
          topic: topic,
        );
      case AssistantTopic.watering:
        return AssistantResponse(
          message: _buildWateringAnswer(knowledge, resolvedPlant),
          topic: topic,
        );
      case AssistantTopic.fertilizer:
        return AssistantResponse(
          message: _buildFertilizerAnswer(normalizedQuestion, knowledge, resolvedPlant),
          topic: topic,
        );
      case AssistantTopic.gardenTips:
        return AssistantResponse(
          message: _buildGardenTipsAnswer(knowledge, resolvedPlant),
          topic: topic,
        );
      case AssistantTopic.plantCare:
        return AssistantResponse(
          message: _buildPlantCareAnswer(knowledge, resolvedPlant),
          topic: topic,
        );
      case AssistantTopic.general:
        if (resolvedPlant != null) {
          return AssistantResponse(
            message: _buildPlantCareAnswer(knowledge, resolvedPlant),
            topic: AssistantTopic.plantCare,
          );
        }
        return const AssistantResponse(
          message:
              'I can help with plant care, diseases, watering, fertilizers, and garden tips. Ask about a specific plant for more detailed Firestore-based guidance.',
          topic: AssistantTopic.general,
        );
    }
  }

  Future<_AssistantKnowledgeBase> _loadKnowledgeBase() async {
    final cached = _cachedLoad;
    if (cached != null) {
      return cached;
    }

    final loader = Future<_AssistantKnowledgeBase>(() async {
      final plantInfos = await _loadPlantInfos();
      final diseaseLibrary = await _loadDiseaseLibrary();
      final products = await _loadProducts();
      final communityPosts = await _loadCommunityPosts();

      return _AssistantKnowledgeBase(
        plantInfos: plantInfos,
        diseaseLibrary: diseaseLibrary,
        products: products,
        communityPosts: communityPosts,
      );
    });

    _cachedLoad = loader;
    return loader;
  }

  Future<List<PlantInfo>> _loadPlantInfos() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('plant_information')
          .get();
      return snapshot.docs
          .map((doc) => PlantInfo.fromMap(doc.data()))
          .toList(growable: false);
    } catch (_) {
      return const <PlantInfo>[];
    }
  }

  Future<DiseaseLibraryData> _loadDiseaseLibrary() async {
    try {
      return await _diseaseService.loadLibrary();
    } catch (_) {
      return const DiseaseLibraryData(
        plants: <PlantProfile>[],
        diseases: <PlantDisease>[],
      );
    }
  }

  Future<List<Product>> _loadProducts() async {
    try {
      return await _productService.watchActiveProducts().first;
    } catch (_) {
      return const <Product>[];
    }
  }

  Future<List<CommunityPost>> _loadCommunityPosts() async {
    try {
      return await _communityService.watchPosts().first;
    } catch (_) {
      return const <CommunityPost>[];
    }
  }

  AssistantTopic _detectTopic(String question) {
    final lower = question.toLowerCase();

    if (_containsAny(lower, _diseaseKeywords)) {
      return AssistantTopic.diseaseHelp;
    }
    if (_containsAny(lower, _fertilizerKeywords)) {
      return AssistantTopic.fertilizer;
    }
    if (_containsAny(lower, _wateringKeywords)) {
      return AssistantTopic.watering;
    }
    if (_containsAny(lower, _gardenTipKeywords)) {
      return AssistantTopic.gardenTips;
    }
    if (_containsAny(lower, _plantCareKeywords)) {
      return AssistantTopic.plantCare;
    }
    return AssistantTopic.general;
  }

  _ResolvedPlant? _resolvePlant(String question, _AssistantKnowledgeBase knowledge) {
    final normalizedQuestion = _normalize(question);
    if (normalizedQuestion.isEmpty) {
      return null;
    }

    final candidates = <_PlantCandidate>[
      ...knowledge.plantInfos.map(
        (info) => _PlantCandidate(
          displayName: info.plantName,
          plantInfo: info,
          plantProfile: _matchProfile(info.plantName, info.scientificName, knowledge),
          searchTerms: _candidateTerms(
            info.plantName,
            scientificName: info.scientificName,
          ),
        ),
      ),
      ...knowledge.diseaseLibrary.plants.map(
        (profile) => _PlantCandidate(
          displayName: profile.commonName,
          plantInfo: _matchPlantInfo(profile, knowledge.plantInfos),
          plantProfile: profile,
          searchTerms: _candidateTerms(
            profile.commonName,
            scientificName: profile.scientificName,
            aliases: profile.aliases,
          ),
        ),
      ),
    ];

    candidates.sort((left, right) {
      final leftLength = left.displayName.length;
      final rightLength = right.displayName.length;
      return rightLength.compareTo(leftLength);
    });

    for (final candidate in candidates) {
      if (candidate.searchTerms
          .any((term) => term.isNotEmpty && normalizedQuestion.contains(term))) {
        return _ResolvedPlant(
          displayName: candidate.displayName,
          plantInfo: candidate.plantInfo,
          plantProfile: candidate.plantProfile,
        );
      }
    }

    return null;
  }

  PlantProfile? _matchProfile(
    String plantName,
    String scientificName,
    _AssistantKnowledgeBase knowledge,
  ) {
    final normalizedPlant = _normalize(plantName);
    final normalizedScientific = _normalize(scientificName);

    for (final profile in knowledge.diseaseLibrary.plants) {
      final identifiers = <String>[
        profile.id,
        profile.commonName,
        profile.scientificName,
        ...profile.aliases,
      ].map(_normalize);

      if (identifiers.contains(normalizedPlant) ||
          identifiers.contains(normalizedScientific) ||
          identifiers.any((value) => value.isNotEmpty && normalizedPlant.contains(value))) {
        return profile;
      }
    }

    return null;
  }

  PlantInfo? _matchPlantInfo(PlantProfile profile, List<PlantInfo> plantInfos) {
    for (final info in plantInfos) {
      final normalizedName = _normalize(info.plantName);
      final normalizedScientific = _normalize(info.scientificName);
      final profileNames = <String>[
        profile.commonName,
        profile.scientificName,
        profile.id,
        ...profile.aliases,
      ].map(_normalize);

      if (profileNames.contains(normalizedName) ||
          profileNames.contains(normalizedScientific) ||
          profileNames.any((value) => value.isNotEmpty && normalizedName.contains(value))) {
        return info;
      }
    }

    return null;
  }

  String _buildPlantCareAnswer(
    _AssistantKnowledgeBase knowledge,
    _ResolvedPlant? resolvedPlant,
  ) {
    final plant = resolvedPlant?.plantInfo;
    if (plant != null) {
      final tips = <String>[
        if (plant.careTips.isNotEmpty) ...plant.careTips.take(3),
        if (plant.commonProblems.isNotEmpty) ...plant.commonProblems.take(2),
      ];

      return [
        'Here is Firestore care guidance for ${plant.plantName}.',
        if (plant.description.trim().isNotEmpty) 'Overview: ${plant.description}',
        if (plant.watering.trim().isNotEmpty) 'Watering: ${plant.watering}',
        if (plant.sunlight.trim().isNotEmpty) 'Sunlight: ${plant.sunlight}',
        if (plant.soil.trim().isNotEmpty) 'Soil: ${plant.soil}',
        if (plant.temperature.trim().isNotEmpty) 'Temperature: ${plant.temperature}',
        if (plant.humidity.trim().isNotEmpty) 'Humidity: ${plant.humidity}',
        if (tips.isNotEmpty) 'Care tips:\n- ${tips.join('\n- ')}',
      ].join('\n\n');
    }

    final fallbackPlants = knowledge.plantInfos.take(3).toList(growable: false);
    if (fallbackPlants.isEmpty) {
      return 'I could not find plant care records in Firestore right now. Try asking about a specific plant name.';
    }

    final tips = fallbackPlants
        .map(
          (info) => '${info.plantName}: ${info.watering.isNotEmpty ? info.watering : 'Keep an eye on soil moisture and adjust watering to the plant type.'}',
        )
        .join('\n- ');

    return [
      'I could not match a specific plant, but Firestore has these care notes:',
      '- $tips',
      'If you tell me the plant name, I can give a more specific answer.',
    ].join('\n\n');
  }

  String _buildDiseaseAnswer(
    String question,
    _AssistantKnowledgeBase knowledge,
    _ResolvedPlant? resolvedPlant,
  ) {
    final plant = resolvedPlant?.plantProfile;
    final query = _normalize(question);

    final resolvedDiseases = <PlantDisease>[];
    if (plant != null) {
      resolvedDiseases.addAll(
        knowledge.diseaseLibrary.diseases.where((disease) {
          return disease.matchesPlant(plant.id) ||
              _matchesPlantName(disease.affectedPlantNames, plant.commonName) ||
              _matchesPlantName(disease.affectedPlantNames, plant.scientificName) ||
              _matchesQuery(query, _normalize(disease.name)) ||
              _matchesQuery(query, _normalize(disease.overview)) ||
              disease.tags.any((tag) => _matchesQuery(query, _normalize(tag)));
        }),
      );
    } else {
      resolvedDiseases.addAll(
        knowledge.diseaseLibrary.diseases.where((disease) {
          return disease.matchesQuery(question) ||
              _matchesQuery(query, _normalize(disease.name)) ||
              disease.tags.any((tag) => _matchesQuery(query, _normalize(tag)));
        }),
      );
    }

    if (resolvedDiseases.isEmpty) {
      resolvedDiseases.addAll(knowledge.diseaseLibrary.diseases.take(3));
    }

    final limited = resolvedDiseases.take(3).toList(growable: false);
    if (limited.isEmpty) {
      return 'I could not find disease or pest records in Firestore right now.';
    }

    return [
      if (resolvedPlant?.displayName != null)
        'Here are the Firestore disease and pest records I found for ${resolvedPlant!.displayName}:'
      else
        'Here are some relevant disease and pest records from Firestore:',
      for (var i = 0; i < limited.length; i++) ...[
        '',
        '${i + 1}. ${limited[i].name} (${limited[i].severity.label})',
        limited[i].severity.description,
        if (limited[i].overview.trim().isNotEmpty) 'Overview: ${limited[i].overview}',
        if (limited[i].symptoms.isNotEmpty) 'Symptoms:\n- ${limited[i].symptoms.take(3).join('\n- ')}',
        if (limited[i].causes.isNotEmpty) 'Causes:\n- ${limited[i].causes.take(3).join('\n- ')}',
        if (limited[i].remedies.isNotEmpty) 'Remedies:\n- ${limited[i].remedies.take(3).join('\n- ')}',
        if (limited[i].prevention.isNotEmpty) 'Prevention:\n- ${limited[i].prevention.take(3).join('\n- ')}',
      ],
    ].join('\n');
  }

  String _buildWateringAnswer(
    _AssistantKnowledgeBase knowledge,
    _ResolvedPlant? resolvedPlant,
  ) {
    final plant = resolvedPlant?.plantInfo;
    if (plant != null) {
      final parts = <String>[
        'Watering guidance for ${plant.plantName} from Firestore:',
        if (plant.watering.trim().isNotEmpty) 'Watering: ${plant.watering}',
        if (plant.soil.trim().isNotEmpty) 'Soil: ${plant.soil}',
        if (plant.careTips.isNotEmpty)
          'Helpful care notes:\n- ${plant.careTips.take(2).join('\n- ')}',
      ];
      return parts.join('\n\n');
    }

    final examples = knowledge.plantInfos
        .where((info) => info.watering.trim().isNotEmpty)
        .take(3)
        .map((info) => '${info.plantName}: ${info.watering}')
        .toList(growable: false);

    if (examples.isEmpty) {
      return 'I could not find watering records in Firestore right now. Ask me about a specific plant for a more detailed answer.';
    }

    return [
      'General watering guidance from Firestore plant data:',
      '- Water when the top layer of soil starts to dry unless the plant prefers to stay moist.',
      '- Avoid letting pots sit in standing water.',
      '- Examples:\n- ${examples.join('\n- ')}',
    ].join('\n\n');
  }

  String _buildFertilizerAnswer(
    String question,
    _AssistantKnowledgeBase knowledge,
    _ResolvedPlant? resolvedPlant,
  ) {
    final lower = question.toLowerCase();
    final plantName = resolvedPlant?.displayName.toLowerCase();

    final fertilizerProducts = knowledge.products.where((product) {
      final haystack = _productHaystack(product);
      return _containsAny(haystack, _fertilizerKeywords) ||
          _containsAny(haystack, const ['compost', 'manure', 'npk']);
    }).toList(growable: false);

    if (fertilizerProducts.isEmpty) {
      return 'I could not find active fertilizer products in Firestore right now. Try again after the product catalog is populated.';
    }

    final relevant = fertilizerProducts.where((product) {
      if (plantName == null || plantName.isEmpty) {
        return true;
      }
      final haystack = _productHaystack(product);
      return haystack.contains(plantName) || haystack.contains(lower);
    }).toList(growable: false);

    final selected = relevant.isNotEmpty ? relevant : fertilizerProducts;
    final top = selected.take(3).toList(growable: false);

    return [
      if (resolvedPlant?.displayName != null)
        'Fertilizer guidance for ${resolvedPlant!.displayName}:'
      else
        'Here are active fertilizer options from Firestore:',
      for (var i = 0; i < top.length; i++) ...[
        '',
        '${i + 1}. ${top[i].name}',
        if (top[i].description.trim().isNotEmpty) 'Description: ${top[i].description}',
        if (top[i].benefits.isNotEmpty) 'Benefits:\n- ${top[i].benefits.take(3).join('\n- ')}',
        if (top[i].careNotes.isNotEmpty) 'Care notes:\n- ${top[i].careNotes.take(3).join('\n- ')}',
        if (top[i].watering.trim().isNotEmpty) 'Use with this watering pattern: ${top[i].watering}',
      ],
    ].join('\n');
  }

  String _buildGardenTipsAnswer(
    _AssistantKnowledgeBase knowledge,
    _ResolvedPlant? resolvedPlant,
  ) {
    final plant = resolvedPlant?.plantInfo;
    final tips = <String>[];

    if (plant != null) {
      tips.addAll(plant.careTips.take(3));
      tips.addAll(plant.commonProblems.take(2));
    } else {
      for (final info in knowledge.plantInfos.take(3)) {
        tips.addAll(info.careTips.take(1));
      }
    }

    for (final post in knowledge.communityPosts.take(3)) {
      final helpful = post.helpfulAnswer?.message.trim();
      if (helpful != null && helpful.isNotEmpty) {
        tips.add(helpful);
      } else if (post.problemDescription.trim().isNotEmpty) {
        tips.add(post.problemDescription.trim());
      }
    }

    final cleanedTips = tips
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .take(5)
        .toList(growable: false);

    if (cleanedTips.isEmpty) {
      return 'I could not find garden tips in Firestore right now. Try asking about a specific plant or topic.';
    }

    return [
      if (plant != null)
        'Garden tips for ${plant.plantName} from Firestore:'
      else
        'Here are a few Firestore garden tips:',
      '',
      '- ${cleanedTips.join('\n- ')}',
    ].join('\n');
  }

  bool _containsAny(String value, List<String> keywords) {
    for (final keyword in keywords) {
      if (value.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  bool _matchesPlantName(List<String> names, String plantName) {
    final normalizedPlant = _normalize(plantName);
    if (normalizedPlant.isEmpty) {
      return false;
    }

    for (final name in names) {
      final normalizedName = _normalize(name);
      if (normalizedName.isNotEmpty && normalizedPlant.contains(normalizedName)) {
        return true;
      }
    }

    return false;
  }

  bool _matchesQuery(String query, String haystack) {
    if (query.isEmpty || haystack.isEmpty) {
      return false;
    }

    return haystack.contains(query) || query.contains(haystack);
  }

  String _productHaystack(Product product) {
    return <String>[
      product.name,
      product.category,
      product.type,
      product.description,
      product.scientificName,
      product.sunlight,
      product.watering,
      product.soil,
      product.deliveryInfo,
      ...product.tags,
      ...product.benefits,
      ...product.careNotes,
    ].join(' ').toLowerCase();
  }

  List<String> _candidateTerms(
    String primary, {
    String? scientificName,
    List<String> aliases = const <String>[],
  }) {
    final terms = <String>[
      _normalize(primary),
      if (scientificName != null) _normalize(scientificName),
      ...aliases.map(_normalize),
    ];
    return terms.where((term) => term.isNotEmpty).toList(growable: false);
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}

class _PlantCandidate {
  const _PlantCandidate({
    required this.displayName,
    required this.plantInfo,
    required this.plantProfile,
    required this.searchTerms,
  });

  final String displayName;
  final PlantInfo? plantInfo;
  final PlantProfile? plantProfile;
  final List<String> searchTerms;
}

const List<String> _diseaseKeywords = [
  'disease',
  'diseases',
  'pest',
  'pests',
  'fungus',
  'fungal',
  'leaf spot',
  'spot',
  'mildew',
  'rot',
  'blight',
  'aphid',
  'mealybug',
  'whitefly',
  'thrips',
  'mite',
];

const List<String> _wateringKeywords = [
  'water',
  'watering',
  'irrigation',
  'moisture',
  'dry',
  'overwater',
  'underwater',
];

const List<String> _fertilizerKeywords = [
  'fertilizer',
  'fertilise',
  'fertilize',
  'feed',
  'compost',
  'manure',
  'npk',
  'nutrient',
];

const List<String> _gardenTipKeywords = [
  'tip',
  'tips',
  'garden',
  'gardening',
  'how to grow',
  'grow',
  'care',
];

const List<String> _plantCareKeywords = [
  'plant care',
  'care',
  'look after',
  'maintain',
  'grow',
  'healthy',
  'sunlight',
  'soil',
];
