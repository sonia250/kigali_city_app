import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _listings => _firestore.collection('listings');
  CollectionReference get _reviews => _firestore.collection('reviews');

  Stream<List<Listing>> getListings() {
    return _listings
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  Stream<List<Listing>> getUserListings(String userId) {
    return _listings
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  Future<void> createListing(Listing listing) async {
    await _listings.doc(listing.id).set(listing.toFirestore());
  }

  Future<void> updateListing(Listing listing) async {
    await _listings.doc(listing.id).update(listing.toFirestore());
  }

  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
    final reviews = await _reviews.where('listingId', isEqualTo: id).get();
    for (final doc in reviews.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<Review>> getReviews(String listingId) {
    return _reviews
        .where('listingId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<void> addReview(Review review) async {
    await _reviews.add(review.toFirestore());
    final reviews =
        await _reviews.where('listingId', isEqualTo: review.listingId).get();
    double totalRating = 0;
    for (final doc in reviews.docs) {
      totalRating += (doc.data() as Map<String, dynamic>)['rating'] ?? 0;
    }
    final avgRating = totalRating / reviews.docs.length;
    await _listings.doc(review.listingId).update({
      'rating': avgRating,
      'reviewCount': reviews.docs.length,
    });
  }
}









