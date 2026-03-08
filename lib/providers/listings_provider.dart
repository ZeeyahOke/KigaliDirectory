import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';

/// Provider that wraps [FirestoreService] and manages listings state.
///
/// Handles:
/// - Real-time Firestore streams for all listings and user-specific listings
/// - CRUD operations with loading / success / error state management
/// - Local search and category filtering on the streamed data
///
/// UI widgets should NEVER call Firestore directly — they interact
/// exclusively through this provider.
class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // ── Stream subscriptions ──────────────────────────────────────────────────
  StreamSubscription? _allListingsSubscription;
  StreamSubscription? _userListingsSubscription;

  // ── State fields ──────────────────────────────────────────────────────────
  List<ListingModel> _allListings = [];
  List<ListingModel> _userListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Search & filter state ─────────────────────────────────────────────────
  String _searchQuery = '';
  String? _selectedCategory;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get userListings => _userListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  /// Returns the filtered list of all listings based on current search query
  /// and selected category.
  List<ListingModel> get filteredListings {
    List<ListingModel> results = List.from(_allListings);

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      results = results
          .where((listing) => listing.category == _selectedCategory)
          .toList();
    }

    // Apply search query filter (case-insensitive substring match)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results
          .where((listing) => listing.name.toLowerCase().contains(query))
          .toList();
    }

    return results;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAM INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Starts listening to the real-time stream of ALL listings.
  /// Called when the app initializes after authentication.
  void listenToAllListings() {
    _setLoading(true);
    _allListingsSubscription?.cancel();

    _allListingsSubscription =
        _firestoreService.getListingsStream().listen(
      (listings) {
        _allListings = listings;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load listings. Please try again.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Starts listening to the real-time stream of listings created by [userId].
  void listenToUserListings(String userId) {
    _userListingsSubscription?.cancel();

    _userListingsSubscription =
        _firestoreService.getUserListingsStream(userId).listen(
      (listings) {
        _userListings = listings;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading user listings: $error');
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new listing in Firestore.
  ///
  /// Returns the generated document ID on success, or null on failure.
  Future<String?> createListing(ListingModel listing) async {
    _setLoading(true);
    _clearError();

    try {
      final id = await _firestoreService.createListing(listing);
      _setLoading(false);
      return id;
    } catch (e) {
      _setError('Failed to create listing. Please try again.');
      _setLoading(false);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Updates an existing listing in Firestore.
  ///
  /// Returns true on success, false on failure.
  Future<bool> updateListing(ListingModel listing) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateListing(listing);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update listing. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Deletes a listing from Firestore by its [id].
  ///
  /// Returns true on success, false on failure.
  Future<bool> deleteListing(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteListing(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete listing. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH & FILTER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Updates the search query and triggers a rebuild.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Updates the selected category filter and triggers a rebuild.
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clears both search query and category filter.
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEED DATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Seeds the database with sample Kigali listings.
  Future<bool> seedData(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.seedSampleListings(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to seed data. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _allListingsSubscription?.cancel();
    _userListingsSubscription?.cancel();
    super.dispose();
  }
}
