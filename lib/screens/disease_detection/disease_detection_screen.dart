import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/disease_prediction.dart';
import '../../services/disease_detection_service.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'widgets/disease_detection_action_button.dart';
import 'widgets/disease_detection_result_card.dart';
import 'widgets/disease_detection_upload_area.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final ImagePicker _imagePicker = ImagePicker();
  final DiseaseDetectionService _diseaseDetectionService =
      const TfliteDiseaseDetectionService();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  DiseasePrediction? _prediction;
  String? _errorMessage;
  bool _isDetecting = false;

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
    if (_isDetecting) {
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
        _selectedImageName = image.name.isNotEmpty ? image.name : 'leaf-image.jpg';
        _prediction = null;
        _errorMessage = null;
        _isDetecting = true;
      });

      final prediction = await _diseaseDetectionService.detectDisease(
        bytes,
        fileName: _selectedImageName ?? 'leaf-image.jpg',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isDetecting = false;
        _prediction = prediction.success ? prediction : null;
        _errorMessage = prediction.success ? null : prediction.message;
      });
    } on DiseaseDetectionServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDetecting = false;
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDetecting = false;
        _errorMessage =
            'Disease detection failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Disease Detection'),
        centerTitle: false,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                                'Upload or capture a leaf image to identify possible diseases, understand severity, and review simple care guidance.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const DiseaseDetectionUploadArea(),
                              const SizedBox(height: 18),
                              LayoutBuilder(
                                builder: (context, actionConstraints) {
                                  final actionWidth =
                                      actionConstraints.maxWidth >= 640
                                          ? ((actionConstraints.maxWidth - 16) / 2)
                                              .clamp(220.0, 320.0)
                                              .toDouble()
                                          : actionConstraints.maxWidth;

                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      SizedBox(
                                        width: actionWidth,
                                        child: DiseaseDetectionActionButton(
                                          label: 'Capture Leaf Image',
                                          icon: Icons.photo_camera_rounded,
                                          onPressed: () => _pickImage(ImageSource.camera),
                                        ),
                                      ),
                                      SizedBox(
                                        width: actionWidth,
                                        child: DiseaseDetectionActionButton(
                                          label: 'Choose from Gallery',
                                          icon: Icons.photo_library_rounded,
                                          filled: false,
                                          onPressed: () => _pickImage(ImageSource.gallery),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 22),
                              DiseaseDetectionResultCard(
                                result: _prediction,
                                isLoading: _isDetecting,
                                errorMessage: _errorMessage,
                              ),
                              const SizedBox(height: 18),
                              LayoutBuilder(
                                builder: (context, actionConstraints) {
                                  final actionWidth =
                                      actionConstraints.maxWidth >= 640
                                          ? ((actionConstraints.maxWidth - 16) / 2)
                                              .clamp(220.0, 320.0)
                                              .toDouble()
                                          : actionConstraints.maxWidth;

                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      SizedBox(
                                        width: actionWidth,
                                        child: DiseaseDetectionActionButton(
                                          label: 'Share Report',
                                          icon: Icons.share_rounded,
                                          filled: false,
                                          onPressed: () => _showMessage(
                                            'Share Report will be connected later',
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
