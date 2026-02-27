import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';

class AddEditListingScreen extends StatefulWidget {
  final ListingModel? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  String _selectedCategory = 'Restaurant';
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) {
      // Edit mode - populate fields
      _nameController.text = widget.listing!.name;
      _addressController.text = widget.listing!.address;
      _contactController.text = widget.listing!.contactNumber;
      _descriptionController.text = widget.listing!.description;
      _latitudeController.text = widget.listing!.latitude.toString();
      _longitudeController.text = widget.listing!.longitude.toString();
      _selectedCategory = widget.listing!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location retrieved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _saveListing() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);

      final listing = ListingModel(
        id: widget.listing?.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        createdBy: authProvider.user!.uid,
        createdAt: widget.listing?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (widget.listing == null) {
        // Create new listing
        success = await listingsProvider.createListing(listing);
      } else {
        // Update existing listing
        success = await listingsProvider.updateListing(widget.listing!.id!, listing);
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.listing == null
                  ? 'Listing created successfully'
                  : 'Listing updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              listingsProvider.errorMessage ?? 'Failed to save listing',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.listing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add New Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Place/Service Name *',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) => AppValidators.validateRequired(value, 'Name'),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: ListingCategories.categories
                    .where((cat) => cat != 'All')
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Address field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => AppValidators.validateRequired(value, 'Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Contact field
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: AppValidators.validatePhone,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Coordinates section
              Text(
                'Location Coordinates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Use current location button
              OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
              const SizedBox(height: 16),

              // Latitude field
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude *',
                  prefixIcon: Icon(Icons.location_searching),
                  hintText: 'e.g., -1.9441',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) => AppValidators.validateCoordinate(value, 'Latitude'),
              ),
              const SizedBox(height: 16),

              // Longitude field
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude *',
                  prefixIcon: Icon(Icons.location_searching),
                  hintText: 'e.g., 30.0619',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) => AppValidators.validateCoordinate(value, 'Longitude'),
              ),
              const SizedBox(height: 24),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kigali coordinates range:\nLat: -2.0 to -1.9, Lng: 30.0 to 30.2',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              Consumer<ListingsProvider>(
                builder: (context, listingsProvider, _) {
                  if (listingsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _saveListing,
                    child: Text(
                      isEditing ? 'Update Listing' : 'Create Listing',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
