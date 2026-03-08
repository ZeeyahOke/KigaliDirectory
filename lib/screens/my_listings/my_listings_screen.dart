import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';
import 'add_edit_listing_screen.dart';

/// Screen displaying only listings created by the authenticated user.
///
/// Provides edit and delete actions on each listing card.
/// Uses [ListingsProvider] for data — no direct Firestore calls.
class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'My Listings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditListingScreen(),
            ),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
      body: Consumer2<ListingsProvider, AuthProvider>(
        builder: (context, listingsProvider, authProvider, _) {
          final userListings = listingsProvider.userListings;

          // Loading
          if (listingsProvider.isLoading && userListings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            );
          }

          // Empty
          if (userListings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t created any listings yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first listing',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          // Listings
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: userListings.length,
            itemBuilder: (context, index) {
              final listing = userListings[index];
              return ListingCard(
                listing: listing,
                showActions: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditListingScreen(existingListing: listing),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, listing.id, listing.name),
              );
            },
          );
        },
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a listing.
  void _confirmDelete(BuildContext context, String listingId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = context.read<ListingsProvider>();
              final success = await provider.deleteListing(listingId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Listing deleted successfully'
                          : 'Failed to delete listing',
                    ),
                    backgroundColor:
                        success ? AppConstants.successColor : AppConstants.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
