import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/shared_widgets.dart';
import '../detail/listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final listings = listingProvider.listings;
    final categories = listingProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final catListings = cat == 'All'
                    ? listingProvider.allListings
                    : listingProvider.allListings
                        .where((l) => l.category == cat)
                        .toList();
                return CategoryChip(
                  label: cat,
                  isSelected: listingProvider.selectedCategory == cat,
                  count: cat == 'All' ? null : catListings.length,
                  onTap: () => listingProvider.setCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search for a service',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: listingProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => listingProvider.setSearch(''),
                      )
                    : null,
              ),
              onChanged: listingProvider.setSearch,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Near You',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${listings.length} places',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: listingProvider.isLoading
                ? const LoadingWidget()
                : listings.isEmpty
                    ? EmptyStateWidget(
                        title: 'No places found',
                        subtitle: listingProvider.searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'Be the first to add a listing!',
                        icon: Icons.location_off,
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: listings.length,
                        itemBuilder: (context, i) {
                          final listing = listings[i];
                          return ListingCard(
                            listing: listing,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(
                                    listing: listing),
                              ));
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










