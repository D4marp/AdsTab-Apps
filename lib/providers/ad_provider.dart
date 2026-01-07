import 'package:flutter/material.dart';
import 'dart:io';
import '../models/ad_model.dart';
import '../services/ad_service.dart';

class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService();

  List<AdModel> _userAds = [];
  List<AdModel> _displayAds = [];
  AdModel? _currentAd;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AdModel> get userAds => _userAds;
  List<AdModel> get displayAds => _displayAds;
  AdModel? get currentAd => _currentAd;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch user's ads
  Future<void> fetchUserAds(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userAds = await _adService.getUserAds(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch ads for display (active ads)
  Future<void> fetchDisplayAds({String? format}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _displayAds = await _adService.getActiveAds(format: format);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single ad
  Future<void> fetchAdById(String adId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentAd = await _adService.getAdById(adId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new ad
  Future<String?> createAd(AdModel ad) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final adId = await _adService.createAd(ad);
      await fetchUserAds(ad.userId);
      return adId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update ad
  Future<bool> updateAd(AdModel ad) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adService.updateAd(ad);
      await fetchUserAds(ad.userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete ad
  Future<bool> deleteAd(String adId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adService.deleteAd(adId);
      await fetchUserAds(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle ad active status
  Future<bool> toggleAdStatus(String adId, bool isActive) async {
    try {
      await _adService.updateAdStatus(adId, isActive);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Track ad impression
  Future<void> trackImpression(String adId) async {
    try {
      await _adService.trackImpression(adId);
    } catch (e) {
      _error = e.toString();
    }
  }

  // Track ad click
  Future<void> trackClick(String adId) async {
    try {
      await _adService.trackClick(adId);
    } catch (e) {
      _error = e.toString();
    }
  }

  // Filter ads by category
  List<AdModel> getAdsByCategory(String category) {
    return _displayAds.where((ad) => ad.category == category).toList();
  }

  // Filter ads by format
  List<AdModel> getAdsByFormat(String format) {
    return _displayAds.where((ad) => ad.displayFormat == format).toList();
  }

  // Upload ad image to Firebase Storage
  Future<String> uploadAdImage(File imageFile) async {
    try {
      return await _adService.uploadAdImage(imageFile);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
