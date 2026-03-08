import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/models.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class AddEditListingScreen extends StatefulWidget {
  final Listing? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() =>
      _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String _selectedCategory = 'Restaurant';
  bool _isEdit = false;
  LatLng _selectedLocation = const LatLng(-1.9441, 30.0619);

  final List<String> _categories = [
    'Hospital', 'Police Station', 'Library', 'Restaurant',
    'Café', 'Park', 'Tourist Attraction', 'Pharmacy',
    'School', 'Bank', 'Hotel', 'Shopping',
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.listing != null;
    if (_isEdit) {
      final l = widget.listing!;
      _nameController.text = l.name;
      _addressController.text = l.address;
      _contactController.text = l.contactNumber;
      _descriptionController.text = l.description;
      _latController.text = l.latitude.toString();
      _lngController.text = l.longitude.toString();
      _selectedCategory = l.category;
      _selectedLocation = LatLng(l.latitude, l.longitude);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final listingProvider = context.read<ListingProvider>();

    final lat = double.tryParse(_latController.text) ??
        _selectedLocation.latitude;
    final lng = double.tryParse(_lngController.text) ??
        _selectedLocation.longitude;

    bool success;
    if (_isEdit) {
      final updated = widget.listing!.copyWith(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
      );
      success = await listingProvider.updateListing(updated);
      if (success && mounted) {
        Navigator.of(context).pop(updated);
      }
    } else {
      success = await listingProvider.createListing(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
        userId: authProvider.user!.uid,
      );
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              listingProvider.error ?? 'Failed to save listing'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEdit ? 'Edit Listing' : 'Add Listing'),
        actions: [
          TextButton(
            onPressed: listingProvider.isLoading ? null : _save,
            child: Text(
              _isEdit ? 'Update' : 'Save',
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                style:
                    const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Place / Service Name *',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.surface,
                style:
                    const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                style:
                    const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style:
                    const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Contact Number *',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                style:
                    const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap the map to set location',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation,
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedLocation,
                        draggable: true,
                        onDragEnd: (pos) {
                          setState(
                              () => _selectedLocation = pos);
                          _latController.text =
                              pos.latitude.toString();
                          _lngController.text =
                              pos.longitude.toString();
                        },
                      ),
                    },
                    onTap: (pos) {
                      setState(() => _selectedLocation = pos);
                      _latController.text =
                          pos.latitude.toString();
                      _lngController.text =
                          pos.longitude.toString();
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                      style: const TextStyle(
                          color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                          labelText: 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                      style: const TextStyle(
                          color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                          labelText: 'Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (listingProvider.isLoading)
                const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accent))
              else
                ElevatedButton(
                  onPressed: _save,
                  child: Text(_isEdit
                      ? 'Update Listing'
                      : 'Create Listing'),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}










