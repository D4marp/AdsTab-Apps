import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Service untuk initialize dan manage Firestore database
class FirestoreInitializationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firestore dengan collections dan indexes
  static Future<void> initializeDatabase() async {
    try {
      print('Initializing Firestore Database...');

      // Create categories
      await _createCategories();

      print('✓ Firestore Database initialized successfully');
    } catch (e) {
      print('Error initializing Firestore: $e');
      rethrow;
    }
  }

  /// Create default categories
  static Future<void> _createCategories() async {
    final List<String> categories = [
      'Product',
      'Service',
      'Event',
      'Job',
      'Real Estate',
      'Automotive',
      'Education',
      'Health',
      'Fashion',
      'Food',
      'Technology',
      'Other',
    ];

    final categoriesRef = _firestore.collection('categories');

    for (final category in categories) {
      try {
        // Check if category already exists
        final query =
            await categoriesRef.where('name', isEqualTo: category).get();

        if (query.docs.isEmpty) {
          // Create category
          await categoriesRef.add({
            'name': category,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('✓ Created category: $category');
        }
      } catch (e) {
        print('Error creating category $category: $e');
      }
    }
  }

  /// Add sample ad (untuk testing)
  static Future<String> addSampleAd({
    required String userId,
    String title = 'Sample Advertisement',
    String description = 'This is a sample advertisement for testing',
    String category = 'Product',
  }) async {
    try {
      final adId = const Uuid().v4();
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30));

      await _firestore.collection('advertisements').doc(adId).set({
        'id': adId,
        'userId': userId,
        'title': title,
        'description': description,
        'category': category,
        'imageUrls': [],
        'displayFormat': 'tab',
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDate),
        'isActive': false,
        'impressions': 0,
        'clicks': 0,
        'targetAudience': 'General',
        'budget': '0',
        'companyName': 'Sample Company',
        'contactEmail': 'sample@example.com',
        'contactPhone': '+62812345678',
        'status': 'draft',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create analytics doc
      await _firestore.collection('ad_analytics').doc(adId).set({
        'adId': adId,
        'impressions': 0,
        'clicks': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✓ Sample ad created with ID: $adId');
      return adId;
    } catch (e) {
      print('Error adding sample ad: $e');
      rethrow;
    }
  }

  /// Verify database structure
  static Future<Map<String, int>> verifyDatabase() async {
    try {
      final Map<String, int> stats = {};

      final collections = ['users', 'advertisements', 'ad_analytics', 'categories'];

      for (final collection in collections) {
        final count = await _firestore.collection(collection).count().get();
        stats[collection] = count.count ?? 0;
      }

      return stats;
    } catch (e) {
      print('Error verifying database: $e');
      rethrow;
    }
  }

  /// Clear all data (for testing only)
  static Future<void> clearAllData() async {
    try {
      final collections = ['users', 'advertisements', 'ad_analytics', 'categories'];

      for (final collection in collections) {
        final docs = await _firestore.collection(collection).get();
        for (final doc in docs.docs) {
          await doc.reference.delete();
        }
        print('✓ Cleared collection: $collection');
      }
    } catch (e) {
      print('Error clearing data: $e');
      rethrow;
    }
  }
}
