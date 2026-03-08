import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

/// Screen for creating a new listing or editing an existing one.
///
/// If [existingListing] is provided, the form is pre-populated for editing.
/// All Firestore operations go through [ListingsProvider].
class AddEditListingScreen extends StatefulWidget {
  final ListingModel? existingListing;

  const AddEditListingScreen({super.key, this.existingListing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  String _selectedCategory = AppConstants.categories.first;

  bool get _isEditing => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    final listing = widget.existingListing;
    _nameController = TextEditingController(text: listing?.name ?? '');
    _addressController = TextEditingController(text: listing?.address ?? '');
    _contactController =
        TextEditingController(text: listing?.contactNumber ?? '');
    _descriptionController =
        TextEditingController(text: listing?.description ?? '');
    _latController =
        TextEditingController(text: listing?.latitude.toString() ?? '');
    _lngController =
        TextEditingController(text: listing?.longitude.toString() ?? '');
    if (listing != null &&
        AppConstants.categories.contains(listing.category)) {
      _selectedCategory = listing.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final listingsProvider = context.read<ListingsProvider>();
    final userId = authProvider.user!.uid;

    final listing = ListingModel(
      id: widget.existingListing?.id ?? '',
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: double.parse(_latController.text.trim()),
      longitude: double.parse(_lngController.text.trim()),
      createdBy: widget.existingListing?.createdBy ?? userId,
      createdAt: widget.existingListing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await listingsProvider.updateListing(listing);
    } else {
      final id = await listingsProvider.createListing(listing);
      success = id != null;
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Listing updated successfully!'
                : 'Listing created successfully!',
          ),
          backgroundColor: AppConstants.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            listingsProvider.errorMessage ?? 'Operation failed. Please try again.',
          ),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Listing' : 'New Listing',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Place Name
              _buildLabel('Place / Service Name'),
              TextFormField(
                controller: _nameController,
                validator: (v) => Validators.required(v, 'Name'),
                decoration: _inputDecoration(
                  hint: 'e.g. King Faisal Hospital',
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Category dropdown
              _buildLabel('Category'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: AppConstants.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(AppConstants.categoryIcon(cat),
                            size: 18,
                            color: AppConstants.categoryColor(cat)),
                        const SizedBox(width: 8),
                        Text(cat),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                decoration: _inputDecoration(
                  hint: 'Select category',
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Address
              _buildLabel('Address'),
              TextFormField(
                controller: _addressController,
                validator: (v) => Validators.required(v, 'Address'),
                decoration: _inputDecoration(
                  hint: 'e.g. KG 544 St, Kigali',
                  icon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Contact Number
              _buildLabel('Contact Number'),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                decoration: _inputDecoration(
                  hint: 'e.g. +250 788 305 087',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Description
              _buildLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) => Validators.required(v, 'Description'),
                decoration: _inputDecoration(
                  hint: 'Describe this place or service...',
                  icon: Icons.description_outlined,
                ),
              ),
              const SizedBox(height: 18),

              // Coordinates section
              _buildLabel('Geographic Coordinates'),
              const SizedBox(height: 4),
              Text(
                'Enter the latitude and longitude of the location',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: Validators.latitude,
                      decoration: _inputDecoration(
                        hint: 'Latitude',
                        icon: Icons.north,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: Validators.longitude,
                      decoration: _inputDecoration(
                        hint: 'Longitude',
                        icon: Icons.east,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save button
              Consumer<ListingsProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _handleSave,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(_isEditing ? Icons.save : Icons.add_location_alt),
                      label: Text(
                        provider.isLoading
                            ? 'Saving...'
                            : _isEditing
                                ? 'Update Listing'
                                : 'Create Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppConstants.primaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppConstants.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppConstants.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
