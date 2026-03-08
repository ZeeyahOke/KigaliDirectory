import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/category_filter.dart';
import 'listing_detail_screen.dart';

/// Directory screen displaying all listings from Firestore.
///
/// Features a search bar and category filter chips. Results update
/// in real time via Firestore streams managed by [ListingsProvider].
class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Teal header area with search
          Container(
            color: AppConstants.primaryColor,
            child: Column(
              children: [
                Consumer<ListingsProvider>(
                  builder: (context, provider, _) {
                    return ListingSearchBar(
                      value: provider.searchQuery,
                      onChanged: (query) => provider.setSearchQuery(query),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Category filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Consumer<ListingsProvider>(
              builder: (context, provider, _) {
                return CategoryFilter(
                  selectedCategory: provider.selectedCategory,
                  onCategorySelected: (category) =>
                      provider.setCategory(category),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Listings list
          Expanded(
            child: Consumer<ListingsProvider>(
              builder: (context, provider, _) {
                // Loading state
                if (provider.isLoading && provider.allListings.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.primaryColor,
                    ),
                  );
                }

                // Error state
                if (provider.errorMessage != null &&
                    provider.allListings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          provider.errorMessage!,
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final listings = provider.filteredListings;

                // Empty state
                if (listings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          provider.searchQuery.isNotEmpty ||
                                  provider.selectedCategory != null
                              ? 'No listings match your search'
                              : 'No listings available yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        if (provider.searchQuery.isNotEmpty ||
                            provider.selectedCategory != null)
                          TextButton(
                            onPressed: () => provider.clearFilters(),
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  );
                }

                // Success — listing cards
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return ListingCard(
                      listing: listing,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailScreen(listing: listing),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
