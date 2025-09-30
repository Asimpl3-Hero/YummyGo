import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite_state.dart';
import '../provider/favorite_provider.dart';

class FavoriteStateBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, List<String> favoriteIds) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, FavoriteException error)? errorBuilder;

  const FavoriteStateBuilder({
    super.key,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        if (favoriteProvider.isLoading) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (favoriteProvider.hasError) {
          return errorBuilder?.call(context, favoriteProvider.error!) ??
              _DefaultErrorWidget(
                error: favoriteProvider.error!,
                onRetry: () => favoriteProvider.refreshFavorites(),
                onClearError: () => favoriteProvider.clearError(),
              );
        }

        return builder(context, favoriteProvider.favoriteIds);
      },
    );
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final FavoriteException error;
  final VoidCallback onRetry;
  final VoidCallback onClearError;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
    required this.onClearError,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (error.code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error Code: ${error.code}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onClearError,
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.code) {
      case 'NO_CONNECTIVITY':
        return Icons.wifi_off;
      case 'NOT_AUTHENTICATED':
        return Icons.login;
      case 'PRODUCT_NOT_FOUND':
        return Icons.search_off;
      default:
        return Icons.error_outline;
    }
  }
}