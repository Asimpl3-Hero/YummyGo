enum FavoriteLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class FavoriteException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const FavoriteException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'FavoriteException: $message';
}