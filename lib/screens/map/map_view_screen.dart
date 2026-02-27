import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';
import '../directory/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  ListingModel? _selectedListing;

  // Kigali center coordinates
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);
    final listings = listingsProvider.allListings;

    setState(() {
      _markers = listings.map((listing) {
        return Marker(
          markerId: MarkerId(listing.id ?? listing.name),
          position: LatLng(listing.latitude, listing.longitude),
          infoWindow: InfoWindow(
            title: listing.name,
            snippet: listing.category,
            onTap: () {
              setState(() {
                _selectedListing = listing;
              });
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(listing.category),
          ),
          onTap: () {
            setState(() {
              _selectedListing = listing;
            });
          },
        );
      }).toSet();
    });
  }

  double _getMarkerColor(String category) {
    switch (category) {
      case 'Hospital':
        return BitmapDescriptor.hueRed;
      case 'Police Station':
        return BitmapDescriptor.hueBlue;
      case 'Library':
        return BitmapDescriptor.hueViolet;
      case 'Restaurant':
        return BitmapDescriptor.hueOrange;
      case 'Café':
        return BitmapDescriptor.hueYellow;
      case 'Park':
        return BitmapDescriptor.hueGreen;
      case 'Tourist Attraction':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueRose;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ListingsProvider>(
        builder: (context, listingsProvider, _) {
          // Update markers when listings change
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateMarkers();
          });

          return Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _kigaliCenter,
                  zoom: 12,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
              ),

              // Selected listing card at bottom
              if (_selectedListing != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                ListingCategories.getCategoryIcon(
                                  _selectedListing!.category,
                                ),
                                color: AppColors.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedListing!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _selectedListing!.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedListing = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _selectedListing!.address,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ListingDetailScreen(
                                      listing: _selectedListing!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View Details'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Legend
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${listingsProvider.allListings.length} places',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
