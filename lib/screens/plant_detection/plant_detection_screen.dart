import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/plant_info.dart';
import '../../models/plant_prediction.dart';
import '../../services/plant_detection_service.dart';
import '../../services/plant_info_service.dart';
import '../dashboard/widgets/dashboard_background.dart';
import '../disease_library/plant_common_conditions_screen.dart';
import 'widgets/plant_detection_action_button.dart';
import 'widgets/plant_detection_result_card.dart';
import 'widgets/plant_detection_upload_area.dart';

class PlantDetectionScreen extends StatefulWidget {
  const PlantDetectionScreen({super.key});

  @override
  State<PlantDetectionScreen> createState() => _PlantDetectionScreenState();
}

class _PlantDetectionScreenState extends State<PlantDetectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final ImagePicker _imagePicker = ImagePicker();
  final PlantDetectionService _detectionService =
      ApiBackedPlantDetectionService();
  final PlantInfoService _plantInfoService = const PlantInfoService();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  PlantPrediction? _prediction;
  PlantInfo? _plantInfo;
  String? _errorMessage;
  bool _isIdentifying = false;
  bool _isLoadingPlantInfo = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isIdentifying) {
      return;
    }

    try {
      final effectiveSource = kIsWeb ? ImageSource.gallery : source;
      final image = await _imagePicker.pickImage(
        source: effectiveSource,
        imageQuality: 92,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        _showMessage('The selected image is empty.');
        return;
      }

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName =
            image.name.isNotEmpty ? image.name : 'plant-image.jpg';
        _prediction = null;
        _errorMessage = null;
      });
    } catch (_) {
      _showMessage(
        'Unable to open the image picker right now. Please try again.',
      );
    }
  }

  Future<void> _identifyPlant() async {
    final imageBytes = _selectedImageBytes;
    if (imageBytes == null) {
      _showMessage('Please choose a plant image first.');
      return;
    }

    if (_isIdentifying) {
      return;
    }

    setState(() {
      _isIdentifying = true;
      _errorMessage = null;
      _prediction = null;
      _plantInfo = null;
      _isLoadingPlantInfo = false;
    });

    try {
      final prediction = await _detectionService.detectPlant(
        imageBytes,
        fileName: _selectedImageName ?? 'plant-image.jpg',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isIdentifying = false;
        _prediction = prediction.success ? prediction : null;
        _errorMessage = prediction.success ? null : prediction.message;
        _plantInfo = null;
        _isLoadingPlantInfo = prediction.success && prediction.prediction != null;
      });

      if (prediction.success && prediction.prediction != null) {
        final identifiedPlant = prediction.prediction!;
        final plantInfo = await _plantInfoService.fetchPlantInfo(
          plantName: identifiedPlant.commonName,
          scientificName: identifiedPlant.scientificName,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _plantInfo = plantInfo;
          _isLoadingPlantInfo = false;
        });
      }
    } on PlantDetectionServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isIdentifying = false;
        _errorMessage = error.message;
        _isLoadingPlantInfo = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isIdentifying = false;
        _errorMessage = 'Plant identification failed unexpectedly.';
        _isLoadingPlantInfo = false;
      });
    }
  }

  Future<void> _openCommonDiseasesAndPests() async {
    final prediction = _prediction?.prediction;
    if (prediction == null) {
      _showMessage('Please identify a plant first.');
      return;
    }

    final plantInfo = _plantInfo;
    final plantInfoName = plantInfo == null ? '' : plantInfo.plantName.trim();
    final plantInfoScientificName =
        plantInfo == null ? '' : plantInfo.scientificName.trim();
    final detectedPlantName = plantInfoName.isNotEmpty
        ? plantInfoName
        : prediction.commonName;
    final detectedScientificName = plantInfoScientificName.isNotEmpty
        ? plantInfoScientificName
        : prediction.scientificName;
    final detectedPlantId = PlantInfo.documentIdFor(
      detectedScientificName.isNotEmpty
          ? detectedScientificName
          : detectedPlantName,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantCommonConditionsScreen(
          plantName: detectedPlantName,
          scientificName: detectedScientificName,
          plantId: detectedPlantId,
        ),
      ),
    );
  }

  void _clearSelection() {
    if (_isIdentifying) {
      return;
    }

    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _prediction = null;
      _plantInfo = null;
      _errorMessage = null;
      _isLoadingPlantInfo = false;
    });
  }

  Widget _buildGuidanceCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const tips = [
      'Take a clear photo of the plant.',
      'Keep the flower or leaves visible.',
      'Avoid blurry images.',
      'Use good lighting.',
      'Keep the plant centered.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: (isDark ? colorScheme.surfaceContainerHigh : Colors.white)
            .withValues(alpha: 0.82),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For better identification:',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelection = _selectedImageBytes != null;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Plant Detection'),
        centerTitle: false,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final contentWidth = width >= 1100
                    ? 1040.0
                    : width >= 820
                        ? 760.0
                        : width - 32;
                final buttonWidth = width >= 720
                    ? ((contentWidth - 16) / 2).clamp(220.0, 320.0).toDouble()
                    : contentWidth;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Identify any garden plant by taking a photo or selecting one from your gallery.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.5,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              PlantDetectionUploadArea(
                                imageBytes: _selectedImageBytes,
                                imageName: _selectedImageName,
                                isLoading: _isIdentifying,
                              ),
                              const SizedBox(height: 16),
                              _buildGuidanceCard(context),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(
                                    width: buttonWidth,
                                    child: PlantDetectionActionButton(
                                      label: 'Capture Plant Image',
                                      icon: Icons.photo_camera_rounded,
                                      onPressed: () => _pickImage(ImageSource.camera),
                                    ),
                                  ),
                                  SizedBox(
                                    width: buttonWidth,
                                    child: PlantDetectionActionButton(
                                      label: 'Choose from Gallery',
                                      icon: Icons.photo_library_rounded,
                                      filled: false,
                                      onPressed: () => _pickImage(ImageSource.gallery),
                                    ),
                                  ),
                                ],
                              ),
                              if (hasSelection) ...[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: PlantDetectionActionButton(
                                    label: _isIdentifying
                                        ? 'Identifying...'
                                        : 'Identify Plant',
                                    icon: Icons.travel_explore_rounded,
                                    onPressed: _isIdentifying ? null : _identifyPlant,
                                    isLoading: _isIdentifying,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 22),
                              PlantDetectionResultCard(
                                result: _prediction,
                                plantInfo: _plantInfo,
                                isPlantInfoLoading: _isLoadingPlantInfo,
                                isLoading: _isIdentifying,
                                errorMessage: _errorMessage,
                              ),
                              const SizedBox(height: 18),
                              LayoutBuilder(
                                builder: (context, actionConstraints) {
                                  final actionWidth = actionConstraints.maxWidth >= 640
                                      ? ((actionConstraints.maxWidth - 16) / 2)
                                          .clamp(220.0, 320.0)
                                          .toDouble()
                                      : actionConstraints.maxWidth;

                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      if (_prediction?.prediction != null)
                                        SizedBox(
                                          width: actionWidth,
                                          child: PlantDetectionActionButton(
                                            label: 'Common Diseases & Pests',
                                            icon: Icons.bug_report_rounded,
                                            filled: false,
                                            onPressed: _openCommonDiseasesAndPests,
                                          ),
                                        ),
                                      SizedBox(
                                        width: actionWidth,
                                        child: PlantDetectionActionButton(
                                          label: 'Choose Another Image',
                                          icon: Icons.refresh_rounded,
                                          filled: false,
                                          onPressed: hasSelection ? _clearSelection : null,
                                        ),
                                      ),
                                      SizedBox(
                                        width: actionWidth,
                                        child: PlantDetectionActionButton(
                                          label: 'Share Result',
                                          icon: Icons.share_rounded,
                                          filled: false,
                                          onPressed: _prediction == null
                                              ? null
                                              : () => _showMessage(
                                                    'Sharing can be connected later.',
                                                  ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
