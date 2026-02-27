import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/listing_model.dart';

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ListingModel> _allListings = [];
  List<ListingModel> _userListings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get userListings => _userListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Get filtered listings based on search and category
  List<ListingModel> get filteredListings {
    List<ListingModel> filtered = _allListings;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((listing) => listing.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((listing) =>
              listing.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  // Initialize listeners for all listings
  void listenToAllListings() {
    _firestoreService.getAllListings().listen(
      (listings) {
        _allListings = listings;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading listings: $error';
        notifyListeners();
      },
    );
  }

  // Initialize listeners for user's listings
  void listenToUserListings(String userId) {
    _firestoreService.getUserListings(userId).listen(
      (listings) {
        _userListings = listings;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading your listings: $error';
        notifyListeners();
      },
    );
  }

  // Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Update selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  // Create a new listing
  Future<bool> createListing(ListingModel listing) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.createListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create listing: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update a listing
  Future<bool> updateListing(String listingId, ListingModel listing) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateListing(listingId, listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a listing
  Future<bool> deleteListing(String listingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteListing(listingId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete listing: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get a single listing
  Future<ListingModel?> getListing(String listingId) async {
    try {
      return await _firestoreService.getListing(listingId);
    } catch (e) {
      _errorMessage = 'Failed to load listing: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
