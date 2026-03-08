import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/shared_widgets.dart';
import '../detail/listing_detail_screen.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final myListings = listingProvider.userListings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddEditListingScreen(),
          ));
        },
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
      body: myListings.isEmpty
          ? EmptyStateWidget(
              title: 'No Listings Yet',
              subtitle:
                  'Start contributing to the Kigali City Directory by adding your first listing.',
              icon: Icons.add_location_alt_outlined,
              onAction: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AddEditListingScreen(),
                ));
              },
              actionLabel: 'Add First Listing',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myListings.length,
              itemBuilder: (context, i) {
                final listing = myListings[i];
                return Dismissible(
                  key: Key(listing.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Delete Listing',
                          style: TextStyle(
                              color: AppColors.textPrimary)),
                      content: const Text(
                        'Are you sure you want to delete this listing?',
                        style: TextStyle(
                            color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(true),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    listingProvider.deleteListing(listing.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${listing.name} deleted'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                  background: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete,
                        color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ListingDetailScreen(listing: listing),
                      ),
                    ),
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryEmoji(
                                    listing.category),
                                style: const TextStyle(
                                    fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  listing.category,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.accent),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (_) =>
                                    AddEditListingScreen(
                                        listing: listing),
                              ));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getCategoryEmoji(String category) {
    const icons = {
      'Hospital': '🏥',
      'Police Station': '🚔',
      'Library': '📚',
      'Restaurant': '🍽️',
      'Café': '☕',
      'Park': '🌳',
      'Tourist Attraction': '🗺️',
      'Pharmacy': '💊',
      'School': '🏫',
      'Bank': '🏦',
      'Hotel': '🏨',
      'Shopping': '🛍️',
    };
    return icons[category] ?? '📍';
  }
}










