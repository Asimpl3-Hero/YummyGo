import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/favorite_provider.dart';
import '../widgets/favorite_state_builder.dart';

class FavoriteUsageExample extends StatelessWidget {
  const FavoriteUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              FavoriteProvider.of(context, listen: false).refreshFavorites();
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              try {
                await FavoriteProvider.of(context, listen: false).clearAllFavorites();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All favorites cleared')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: FavoriteStateBuilder(
        builder: (context, favoriteIds) {
          if (favoriteIds.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteIds.length,
            itemBuilder: (context, index) {
              final productId = favoriteIds[index];
              return FavoriteItemTile(productId: productId);
            },
          );
        },
        loadingBuilder: (context) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading favorites...'),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteItemTile extends StatelessWidget {
  final String productId;

  const FavoriteItemTile({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Loading...'),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text('Product $productId'),
            subtitle: const Text('Error loading product'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // Remove invalid favorite
                final fakeProduct = _createFakeDocumentSnapshot(productId);
                try {
                  await FavoriteProvider.of(context, listen: false)
                      .toggleFavorite(fakeProduct);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error removing favorite: $e')),
                    );
                  }
                }
              },
            ),
          );
        }

        final product = snapshot.data!;
        final productData = product.data() as Map<String, dynamic>?;
        final productName = productData?['name'] ?? 'Unknown Product';

        return ListTile(
          leading: const Icon(Icons.favorite, color: Colors.red),
          title: Text(productName),
          subtitle: Text('ID: $productId'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite),
            color: Colors.red,
            onPressed: () async {
              try {
                await FavoriteProvider.of(context, listen: false)
                    .toggleFavorite(product);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from favorites')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  DocumentSnapshot _createFakeDocumentSnapshot(String id) {
    // This is a simplified approach for demonstration
    // In real implementation, you'd handle this differently
    return FirebaseFirestore.instance.collection('products').doc(id).snapshots().first as DocumentSnapshot;
  }
}

class ProductTileWithFavorite extends StatelessWidget {
  final DocumentSnapshot product;

  const ProductTileWithFavorite({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = FavoriteProvider.of(context);
    final isFavorite = favoriteProvider.isExist(product);
    final productData = product.data() as Map<String, dynamic>?;
    final productName = productData?['name'] ?? 'Unknown Product';

    return ListTile(
      title: Text(productName),
      subtitle: Text('ID: ${product.id}'),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: favoriteProvider.isLoading
            ? null
            : () async {
                try {
                  await favoriteProvider.toggleFavorite(product);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
      ),
    );
  }
}