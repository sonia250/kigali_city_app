import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/listing_service.dart';
import '../models/models.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService;

  List<Listing> _listings = [];
  List<Listing> _userListings = [];
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  StreamSubscription? _listingsSubscription;
  StreamSubscription? _userListingsSubscription;

  ListingProvider(this._listingService);

  List<Listing> get listings => _filteredListings;
  List<Listing> get allListings => _listings;
  List<Listing> get userListings => _userListings;
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<Listing> get _filteredListings {
    return _listings.where((listing) {
      final matchesSearch = _searchQuery.isEmpty ||
          listing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          listing.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    final cats = ['All', ..._listings.map((l) => l.category).toSet().toList()];
    return cats;
  }

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _listingsSubscription = _listingService.getListings().listen(
      (listings) {
        _listings = listings;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void startUserListening(String userId) {
    _userListingsSubscription =
        _listingService.getUserListings(userId).listen((listings) {
      _userListings = listings;
      notifyListeners();
    });
  }

  void stopListening() {
    _listingsSubscription?.cancel();
    _userListingsSubscription?.cancel();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<bool> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final listing = Listing(
        id: const Uuid().v4(),
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: userId,
        createdAt: DateTime.now(),
      );
      await _listingService.createListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(Listing listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _listingService.updateListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _listingService.deleteListing(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void loadReviews(String listingId) {
    _listingService.getReviews(listingId).listen((reviews) {
      _reviews = reviews;
      notifyListeners();
    });
  }

  Future<bool> addReview({
    required String listingId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
  }) async {
    try {
      final review = Review(
        id: const Uuid().v4(),
        listingId: listingId,
        userId: userId,
        userName: userName,
        comment: comment,
        rating: rating,
        createdAt: DateTime.now(),
      );
      await _listingService.addReview(review);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}









