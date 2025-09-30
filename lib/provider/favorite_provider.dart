import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../models/favorite_state.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  FavoriteLoadingState _loadingState = FavoriteLoadingState.initial;
  FavoriteException? _error;
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();

  List<String> get favoriteIds => _favoriteIds;
  FavoriteLoadingState get loadingState => _loadingState;
  FavoriteException? get error => _error;
  bool get hasError => _error != null;
  bool get isLoading => _loadingState == FavoriteLoadingState.loading;
  bool get isLoaded => _loadingState == FavoriteLoadingState.loaded;

  FavoriteProvider() {
    _initializeFavorites();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeFavorites() async {
    try {
      await _checkConnectivity();
      await _setupRealtimeListener();
    } catch (e) {
      _handleError('Failed to initialize favorites', e);
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw const FavoriteException(
        message: 'No internet connection available',
        code: 'NO_CONNECTIVITY',
      );
    }
  }

  String? get _currentUserId => _auth.currentUser?.uid;

  bool get _isUserAuthenticated => _currentUserId != null;

  CollectionReference get _userFavoritesCollection {
    if (!_isUserAuthenticated) {
      throw const FavoriteException(
        message: 'User not authenticated',
        code: 'NOT_AUTHENTICATED',
      );
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId!)
        .collection('favorites');
  }

  Future<void> _setupRealtimeListener() async {
    if (!_isUserAuthenticated) {
      _logger.w('User not authenticated, skipping favorites setup');
      _setLoadingState(FavoriteLoadingState.loaded);
      return;
    }

    _setLoadingState(FavoriteLoadingState.loading);

    try {
      _favoritesSubscription?.cancel();
      _favoritesSubscription = _userFavoritesCollection
          .where('isFavorite', isEqualTo: true)
          .snapshots()
          .listen(
            _onFavoritesChanged,
            onError: (error) => _handleError('Error in favorites stream', error),
          );

      _logger.i('Favorites realtime listener setup successful');
    } catch (e) {
      _handleError('Failed to setup realtime listener', e);
    }
  }

  void _onFavoritesChanged(QuerySnapshot snapshot) {
    try {
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
      _clearError();
      _setLoadingState(FavoriteLoadingState.loaded);
      _logger.d('Favorites updated: ${_favoriteIds.length} items');
    } catch (e) {
      _handleError('Error processing favorites update', e);
    }
  }

  Future<void> toggleFavorite(DocumentSnapshot product) async {
    if (!_isUserAuthenticated) {
      throw const FavoriteException(
        message: 'User must be authenticated to manage favorites',
        code: 'NOT_AUTHENTICATED',
      );
    }

    await _checkConnectivity();
    await _validateProduct(product);

    final String productId = product.id;
    final bool isFavorite = _favoriteIds.contains(productId);

    try {
      if (isFavorite) {
        await _removeFavorite(productId);
        _logger.i('Removed product $productId from favorites');
      } else {
        await _addFavorite(productId, product.data() as Map<String, dynamic>?);
        _logger.i('Added product $productId to favorites');
      }
    } catch (e) {
      _handleError(
        isFavorite ? 'Failed to remove favorite' : 'Failed to add favorite',
        e,
      );
      rethrow;
    }
  }

  Future<void> _validateProduct(DocumentSnapshot product) async {
    if (!product.exists) {
      throw const FavoriteException(
        message: 'Product does not exist',
        code: 'PRODUCT_NOT_FOUND',
      );
    }

    final data = product.data();
    if (data == null) {
      throw const FavoriteException(
        message: 'Product data is invalid',
        code: 'INVALID_PRODUCT_DATA',
      );
    }
  }

  bool isExist(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> _addFavorite(String productId, Map<String, dynamic>? productData) async {
    try {
      await _userFavoritesCollection.doc(productId).set({
        'isFavorite': true,
        'addedAt': FieldValue.serverTimestamp(),
        'productData': productData,
      });
    } catch (e) {
      _logger.e('Error adding favorite: $e');
      throw FavoriteException(
        message: 'Failed to add product to favorites',
        code: 'ADD_FAVORITE_FAILED',
        originalException: e,
      );
    }
  }

  Future<void> _removeFavorite(String productId) async {
    try {
      await _userFavoritesCollection.doc(productId).delete();
    } catch (e) {
      _logger.e('Error removing favorite: $e');
      throw FavoriteException(
        message: 'Failed to remove product from favorites',
        code: 'REMOVE_FAVORITE_FAILED',
        originalException: e,
      );
    }
  }

  Future<void> refreshFavorites() async {
    try {
      await _checkConnectivity();
      await _setupRealtimeListener();
    } catch (e) {
      _handleError('Failed to refresh favorites', e);
    }
  }

  Future<void> clearAllFavorites() async {
    if (!_isUserAuthenticated) {
      throw const FavoriteException(
        message: 'User must be authenticated to clear favorites',
        code: 'NOT_AUTHENTICATED',
      );
    }

    try {
      await _checkConnectivity();
      final batch = _firestore.batch();
      final snapshot = await _userFavoritesCollection.get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _logger.i('All favorites cleared successfully');
    } catch (e) {
      _handleError('Failed to clear all favorites', e);
      rethrow;
    }
  }

  void _setLoadingState(FavoriteLoadingState state) {
    if (_loadingState != state) {
      _loadingState = state;
      notifyListeners();
    }
  }

  void _handleError(String message, dynamic error) {
    final exception = error is FavoriteException
        ? error
        : FavoriteException(
            message: message,
            originalException: error,
          );

    _error = exception;
    _setLoadingState(FavoriteLoadingState.error);
    _logger.e(message, error: error);
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
