import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/ad_model.dart';

class AdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _adsCollection = 'advertisements';
  static const String _analyticsCollection = 'ad_analytics';
  static const String _imagesStoragePath = 'ad_images';

  // Create new advertisement
  Future<String> createAd(AdModel ad) async {
    try {
      final docId = const Uuid().v4();
      final newAd = ad.copyWith(id: docId);

      await _firestore
          .collection(_adsCollection)
          .doc(docId)
          .set(newAd.toJson());

      // Initialize analytics for the ad
      await _firestore
          .collection(_analyticsCollection)
          .doc(docId)
          .set({
        'adId': docId,
        'impressions': 0,
        'clicks': 0,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      return docId;
    } catch (e) {
      throw Exception('Failed to create advertisement: $e');
    }
  }

  // Get user's advertisements
  Future<List<AdModel>> getUserAds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_adsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AdModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user ads: $e');
    }
  }

  // Get active advertisements for display
  Future<List<AdModel>> getActiveAds({String? format}) async {
    try {
      Query query = _firestore
          .collection(_adsCollection)
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: 'active');

      if (format != null) {
        query = query.where('displayFormat', isEqualTo: format);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map((doc) => AdModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active ads: $e');
    }
  }

  // Get single advertisement
  Future<AdModel> getAdById(String adId) async {
    try {
      final doc = await _firestore
          .collection(_adsCollection)
          .doc(adId)
          .get();

      if (!doc.exists) {
        throw Exception('Advertisement not found');
      }

      return AdModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch advertisement: $e');
    }
  }

  // Update advertisement
  Future<void> updateAd(AdModel ad) async {
    try {
      await _firestore
          .collection(_adsCollection)
          .doc(ad.id)
          .update(ad.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Failed to update advertisement: $e');
    }
  }

  // Delete advertisement
  Future<void> deleteAd(String adId) async {
    try {
      await _firestore.collection(_adsCollection).doc(adId).delete();
      // Also delete analytics
      await _firestore.collection(_analyticsCollection).doc(adId).delete();
    } catch (e) {
      throw Exception('Failed to delete advertisement: $e');
    }
  }

  // Update ad status (active/paused/expired)
  Future<void> updateAdStatus(String adId, bool isActive) async {
    try {
      await _firestore
          .collection(_adsCollection)
          .doc(adId)
          .update({
            'isActive': isActive,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
    } catch (e) {
      throw Exception('Failed to update ad status: $e');
    }
  }

  // Track advertisement impression
  Future<void> trackImpression(String adId) async {
    try {
      // Update ad impressions
      final docRef = _firestore.collection(_adsCollection).doc(adId);
      await docRef.update({
        'impressions': FieldValue.increment(1),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update analytics
      final analyticsRef =
          _firestore.collection(_analyticsCollection).doc(adId);
      await analyticsRef.update({
        'impressions': FieldValue.increment(1),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to track impression: $e');
    }
  }

  // Track advertisement click
  Future<void> trackClick(String adId) async {
    try {
      // Update ad clicks
      final docRef = _firestore.collection(_adsCollection).doc(adId);
      await docRef.update({
        'clicks': FieldValue.increment(1),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update analytics
      final analyticsRef =
          _firestore.collection(_analyticsCollection).doc(adId);
      await analyticsRef.update({
        'clicks': FieldValue.increment(1),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to track click: $e');
    }
  }

  // Get advertisement analytics
  Future<Map<String, dynamic>> getAdAnalytics(String adId) async {
    try {
      final doc = await _firestore
          .collection(_analyticsCollection)
          .doc(adId)
          .get();

      if (!doc.exists) {
        return {'impressions': 0, 'clicks': 0};
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }

  // Search ads by title or description
  Future<List<AdModel>> searchAds(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_adsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final results = snapshot.docs
          .map((doc) => AdModel.fromJson(doc.data()))
          .where((ad) =>
              ad.title.toLowerCase().contains(query.toLowerCase()) ||
              ad.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return results;
    } catch (e) {
      throw Exception('Failed to search ads: $e');
    }
  }

  // Get ads by category
  Future<List<AdModel>> getAdsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_adsCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => AdModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch ads by category: $e');
    }
  }

  // Upload advertisement image to Firebase Storage
  Future<String> uploadAdImage(File imageFile) async {
    try {
      final imageId = const Uuid().v4();
      final fileName = '$imageId.jpg';
      final storageRef = _storage.ref().child('$_imagesStoragePath/$fileName');

      // Upload file
      final uploadTask = await storageRef.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete advertisement image from Firebase Storage
  Future<void> deleteAdImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Delete multiple images
  Future<void> deleteAdImages(List<String> imageUrls) async {
    try {
      for (final imageUrl in imageUrls) {
        await deleteAdImage(imageUrl);
      }
    } catch (e) {
      throw Exception('Failed to delete images: $e');
    }
  }
}
