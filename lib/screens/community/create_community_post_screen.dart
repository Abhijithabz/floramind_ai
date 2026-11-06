import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/community/community_service.dart';
import '../dashboard/widgets/dashboard_background.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() =>
      _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final CommunityService _communityService = const CommunityService();
  late final TextEditingController _authorController;
  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  static const List<String> _categories = <String>[
    'Disease',
    'Care',
    'Pests',
    'Propagation',
    'Watering',
    'Leaves',
  ];

  Uint8List? _imageBytes;
  String? _imageFileName;
  String _selectedCategory = 'Disease';
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _authorController = TextEditingController(text: _defaultAuthorName());
  }

  @override
  void dispose() {
    _authorController.dispose();
    _plantController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _defaultAuthorName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user?.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Guest Gardener';
  }

  Future<void> _pickImage() async {
    if (_isSubmitting) {
      return;
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (!mounted || image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      return;
    }

    setState(() {
      _imageBytes = bytes;
      _imageFileName = image.path.split(RegExp(r'[\\/]' )).last;
      _errorMessage = null;
    });
  }

  Future<void> _submitPost() async {
    if (_isSubmitting) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _communityService.createPost(
        authorName: _authorController.text.trim(),
        authorRole: 'Community Member',
        category: _selectedCategory,
        plantName: _plantController.text.trim(),
        title: _titleController.text.trim(),
        problemDescription: _descriptionController.text.trim(),
        imageBytes: _imageBytes,
        imageFileName: _imageFileName ??
            'community_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } on CommunityServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Unable to publish the post right now.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to publish the post right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Create Post'),
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Share a plant question, a leaf problem, or a helpful community tip.',
                          style: textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ImagePickerArea(
                          imageBytes: _imageBytes,
                          onTap: _pickImage,
                        ),
                        const SizedBox(height: 18),
                        _FieldCard(
                          child: TextFormField(
                            controller: _authorController,
                            decoration: const InputDecoration(
                              labelText: 'Your name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FieldCard(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            items: _categories
                                .map(
                                  (category) => DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: _isSubmitting
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.sell_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FieldCard(
                          child: TextFormField(
                            controller: _plantController,
                            decoration: const InputDecoration(
                              labelText: 'Plant name',
                              prefixIcon: Icon(Icons.local_florist_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a plant name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FieldCard(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Post title',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a post title';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FieldCard(
                          child: TextFormField(
                            controller: _descriptionController,
                            minLines: 5,
                            maxLines: 8,
                            decoration: const InputDecoration(
                              labelText: 'Problem description',
                              alignLabelWithHint: true,
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 80),
                                child: Icon(Icons.edit_note_rounded),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please describe the issue';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submitPost,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(
                            _isSubmitting ? 'Publishing...' : 'Publish Post',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }
}

class _ImagePickerArea extends StatelessWidget {
  const _ImagePickerArea({
    required this.imageBytes,
    required this.onTap,
  });

  final Uint8List? imageBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 240,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.84),
              colorScheme.primaryContainer.withValues(alpha: 0.26),
            ],
          ),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.10),
          ),
        ),
        child: imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 54,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add a plant or problem image',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap here to preview a local image from your device.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }
}
