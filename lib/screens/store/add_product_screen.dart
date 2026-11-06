import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product.dart';
import '../dashboard/widgets/dashboard_background.dart';
import 'garden_store_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    super.key,
    this.existingProduct,
  });

  final Product? existingProduct;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _imageController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _locationController;
  late final TextEditingController _contactController;
  late final TextEditingController _scientificController;
  late final TextEditingController _plantTypeController;
  late final TextEditingController _sunlightController;
  late final TextEditingController _wateringController;
  late final TextEditingController _soilController;
  late final TextEditingController _heightController;
  late final TextEditingController _notesController;
  late final TextEditingController _benefitsController;

  final GardenStoreController _controller = GardenStoreController.instance;
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isSaving = false;

  String _selectedCategory = 'Plants';
  String _selectedProductType = 'Plant';
  String _selectedListingStatus = 'Active';

  static const List<String> _categoryOptions = [
    'Plants',
    'Flowers',
    'Seeds',
    'Indoor Plants',
    'Garden Plants',
    'Saplings',
    'Pots & Planters',
    'Gardening Tools',
    'Fertilizers',
    'Plant Care',
  ];

  static const List<String> _listingStatusOptions = [
    'Active',
    'Out of Stock',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
    final product = widget.existingProduct;

    _imageController = TextEditingController(text: product?.imageUrl ?? '');
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(0),
    );
    _discountPriceController = TextEditingController(
      text: product?.discountPrice?.toStringAsFixed(0) ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    _locationController = TextEditingController(text: product?.location ?? '');
    _contactController = TextEditingController(text: '');
    _scientificController = TextEditingController(text: product?.scientificName ?? '');
    _plantTypeController = TextEditingController(text: product?.type ?? '');
    _sunlightController = TextEditingController(text: product?.sunlight ?? '');
    _wateringController = TextEditingController(text: product?.watering ?? '');
    _soilController = TextEditingController(text: product?.soil ?? '');
    _heightController = TextEditingController(text: product?.height ?? '');
    _notesController = TextEditingController(text: product?.careNotes.join(', ') ?? '');
    _benefitsController = TextEditingController(text: product?.benefits.join(', ') ?? '');

    _selectedCategory = product?.category ?? 'Plants';
    _selectedProductType = product?.isPlant == true ? 'Plant' : 'Gardening Product';
    _selectedListingStatus = product?.listingStatus ?? 'Active';
  }

  @override
  void dispose() {
    _imageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _scientificController.dispose();
    _plantTypeController.dispose();
    _sunlightController.dispose();
    _wateringController.dispose();
    _soilController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = image.name;
      if (_imageController.text.trim().isEmpty) {
        _imageController.text = image.name;
      }
    });
  }

  Future<void> _publishProduct() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || _isSaving) {
      return;
    }

    if (!_controller.isAuthenticated) {
      _showMessage('Please login to sell products.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final isPlant = _selectedProductType == 'Plant';
    final existing = widget.existingProduct;
    final stockValue = int.parse(_stockController.text.trim());
    final normalizedStock =
        _selectedListingStatus == 'Out of Stock' ? 0 : stockValue;
    final product = Product(
      id: existing?.id ?? 'local-${now.millisecondsSinceEpoch}',
      sellerId: _controller.currentSellerId ?? '',
      sellerName: _controller.currentSellerName,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      type: isPlant
          ? _plantTypeController.text.trim()
          : _plantTypeController.text.trim().isEmpty
              ? 'Gardening Product'
              : _plantTypeController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      discountPrice: _discountPriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_discountPriceController.text.trim()),
      imageUrl: _selectedImageBytes == null
          ? _imageController.text.trim()
          : existing?.imageUrl ?? '',
      rating: existing?.rating ?? 4.6,
      reviewCount: existing?.reviewCount ?? 0,
      location: _locationController.text.trim(),
      stock: normalizedStock,
      isPlant: isPlant,
      scientificName: _scientificController.text.trim(),
      sunlight: _sunlightController.text.trim(),
      watering: _wateringController.text.trim(),
      soil: _soilController.text.trim(),
      height: _heightController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      isFavorite: existing?.isFavorite ?? false,
      isFeatured: existing?.isFeatured ?? false,
      benefits: _parseCommaList(_benefitsController.text),
      careNotes: _parseCommaList(_notesController.text),
      deliveryInfo: _contactController.text.trim().isEmpty
          ? 'Delivery arranged through the seller profile after checkout.'
          : 'Contact: ${_contactController.text.trim()}',
      listingStatus: _selectedListingStatus,
      isActive: _selectedListingStatus != 'Draft',
      tags: <String>[
        _selectedCategory,
        ..._parseCommaList(_benefitsController.text),
        ..._parseCommaList(_notesController.text),
      ],
    );

    final result = widget.existingProduct == null
        ? await _controller.publishProduct(
            product: product,
            imageBytes: _selectedImageBytes,
            imageName: _selectedImageName,
          )
        : await _controller.updateProduct(
            product: product,
            imageBytes: _selectedImageBytes,
            imageName: _selectedImageName,
          );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    _showMessage(result.message);
    if (result.success) {
      Navigator.of(context).pop();
    }
  }

  List<String> _parseCommaList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPlant = _selectedProductType == 'Plant';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth >= 960
              ? 920.0
              : constraints.maxWidth;
          final twoColumns = constraints.maxWidth >= 860;
          final fieldWidth = twoColumns
              ? ((constraints.maxWidth - 12) / 2).clamp(220.0, 460.0).toDouble()
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF5EAF61),
                            Color(0xFF9AD26A),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existingProduct == null ? 'Add Product' : 'Edit Product',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Publish products to Firestore and keep seller listings in sync across devices.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Product Image',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _imageController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'Optional if you upload an image',
                            ),
                            validator: (value) {
                              if (_selectedImageBytes != null ||
                                  (value != null && value.trim().isNotEmpty)) {
                                return null;
                              }
                              return 'Add an image URL or pick an image';
                            },
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              FilledButton.icon(
                                onPressed: _isSaving ? null : _pickImage,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Pick Image'),
                              ),
                              if (_selectedImageName != null)
                                Text(
                                  'Selected: $_selectedImageName',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Product Name',
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Product name',
                              ),
                              validator: (value) => _requiredValidator(value, 'Product name'),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Category',
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: _categoryOptions
                                  .map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Product Type',
                            child: DropdownButtonFormField<String>(
                              value: _selectedProductType,
                              decoration: const InputDecoration(labelText: 'Product type'),
                              items: const [
                                DropdownMenuItem(value: 'Plant', child: Text('Plant')),
                                DropdownMenuItem(
                                  value: 'Gardening Product',
                                  child: Text('Gardening Product'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedProductType = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Listing Status',
                            child: DropdownButtonFormField<String>(
                              value: _selectedListingStatus,
                              decoration: const InputDecoration(labelText: 'Status'),
                              items: _listingStatusOptions
                                  .map(
                                    (status) => DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedListingStatus = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Description',
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) => _requiredValidator(value, 'Description'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Price',
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                prefixText: 'Rs. ',
                              ),
                              validator: (value) {
                                final error = _requiredValidator(value, 'Price');
                                if (error != null) {
                                  return error;
                                }
                                if (double.tryParse(value!.trim()) == null) {
                                  return 'Enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Discount Price',
                            child: TextFormField(
                              controller: _discountPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Discount price',
                                prefixText: 'Rs. ',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value.trim()) == null) {
                                  return 'Enter a valid discount price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Stock Quantity',
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Stock quantity'),
                              validator: (value) {
                                final error = _requiredValidator(value, 'Stock quantity');
                                if (error != null) {
                                  return error;
                                }
                                if (int.tryParse(value!.trim()) == null) {
                                  return 'Enter a valid stock quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Seller Location',
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(labelText: 'Seller location'),
                              validator: (value) =>
                                  _requiredValidator(value, 'Seller location'),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _SectionCard(
                            title: 'Contact Information',
                            child: TextFormField(
                              controller: _contactController,
                              decoration: const InputDecoration(
                                labelText: 'Contact information',
                              ),
                              validator: (value) =>
                                  _requiredValidator(value, 'Contact information'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (isPlant) ...[
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Scientific Name',
                              child: TextFormField(
                                controller: _scientificController,
                                decoration: const InputDecoration(labelText: 'Scientific name'),
                                validator: (value) =>
                                    _requiredValidator(value, 'Scientific name'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Plant Type',
                              child: TextFormField(
                                controller: _plantTypeController,
                                decoration: const InputDecoration(labelText: 'Plant type'),
                                validator: (value) => _requiredValidator(value, 'Plant type'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Sunlight Requirement',
                              child: TextFormField(
                                controller: _sunlightController,
                                decoration: const InputDecoration(labelText: 'Sunlight'),
                                validator: (value) =>
                                    _requiredValidator(value, 'Sunlight requirement'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Water Requirement',
                              child: TextFormField(
                                controller: _wateringController,
                                decoration: const InputDecoration(labelText: 'Watering'),
                                validator: (value) =>
                                    _requiredValidator(value, 'Water requirement'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Soil Requirement',
                              child: TextFormField(
                                controller: _soilController,
                                decoration: const InputDecoration(labelText: 'Soil'),
                                validator: (value) =>
                                    _requiredValidator(value, 'Soil requirement'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Plant Height',
                              child: TextFormField(
                                controller: _heightController,
                                decoration: const InputDecoration(labelText: 'Plant height'),
                                validator: (value) => _requiredValidator(value, 'Plant height'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Usage Notes',
                              child: TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Usage notes',
                                ),
                                validator: (value) =>
                                    _requiredValidator(value, 'Usage notes'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _SectionCard(
                              title: 'Benefits',
                              child: TextFormField(
                                controller: _benefitsController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Benefits',
                                ),
                                validator: (value) =>
                                    _requiredValidator(value, 'Benefits'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _publishProduct,
                      icon: Icon(
                        widget.existingProduct == null
                            ? Icons.publish_rounded
                            : Icons.save_rounded,
                      ),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : widget.existingProduct == null
                                ? 'Publish Product'
                                : 'Update Product',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.existingProduct == null ? 'Add Product' : 'Edit Product'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(child: _buildBody(context)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withValues(alpha: 0.78),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
