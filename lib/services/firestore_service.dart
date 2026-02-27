import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new listing
  Future<String?> createListing(ListingModel listing) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('listings')
          .add(listing.toFirestore());
      return docRef.id; // Return the generated ID
    } catch (e) {
      print('Error creating listing: $e');
      rethrow;
    }
  }

  // Get all listings (real-time stream)
  Stream<List<ListingModel>> getAllListings() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get user's listings (real-time stream)
  Stream<List<ListingModel>> getUserListings(String userId) {
    return _firestore
        .collection('listings')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    });
  }

  // Update a listing
  Future<void> updateListing(String listingId, ListingModel listing) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update(listing.toFirestore());
    } catch (e) {
      print('Error updating listing: $e');
      rethrow;
    }
  }

  // Delete a listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).delete();
    } catch (e) {
      print('Error deleting listing: $e');
      rethrow;
    }
  }

  // Get a single listing
  Future<ListingModel?> getListing(String listingId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('listings').doc(listingId).get();
      if (doc.exists) {
        return ListingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting listing: $e');
      return null;
    }
  }

  // Search listings by name (case-insensitive)
  Stream<List<ListingModel>> searchListings(String query) {
    if (query.isEmpty) {
      return getAllListings();
    }

    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .where((listing) =>
              listing.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Filter listings by category
  Stream<List<ListingModel>> getListingsByCategory(String category) {
    if (category == 'All') {
      return getAllListings();
    }

    return _firestore
        .collection('listings')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    });
  }

  // Combined search and filter
  Stream<List<ListingModel>> searchAndFilterListings({
    String? searchQuery,
    String? category,
  }) {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<ListingModel> listings = snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();

      // Apply category filter
      if (category != null && category != 'All') {
        listings = listings.where((listing) => listing.category == category).toList();
      }

      // Apply search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        listings = listings
            .where((listing) =>
                listing.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      return listings;
    });
  }
}
