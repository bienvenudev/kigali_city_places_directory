import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../my_listings/my_listings_screen.dart';
import '../map/map_view_screen.dart';
import '../settings/settings_screen.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize listeners for listings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      listingsProvider.listenToAllListings();
      if (authProvider.user != null) {
        listingsProvider.listenToUserListings(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDirectoryContent();
      case 1:
        return const MyListingsScreen();
      case 2:
        return const MapViewScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildDirectoryContent();
    }
  }

  Widget _buildDirectoryContent() {
    return Consumer<ListingsProvider>(
      builder: (context, listingsProvider, _) {
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a service',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            listingsProvider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  listingsProvider.setSearchQuery(value);
                },
              ),
            ),

            // Category chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ListingCategories.categories.length,
                itemBuilder: (context, index) {
                  final category = ListingCategories.categories[index];
                  final isSelected = listingsProvider.selectedCategory == category;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        listingsProvider.setSelectedCategory(category);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.secondary,
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Listings list
            Expanded(
              child: listingsProvider.filteredListings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No listings found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Data refreshes automatically via streams
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listingsProvider.filteredListings.length,
                        itemBuilder: (context, index) {
                          final listing = listingsProvider.filteredListings[index];
                          return ListingCard(
                            listing: listing,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailScreen(listing: listing),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City Directory'),
        actions: [
          if (_selectedIndex == 0)
            Consumer<ListingsProvider>(
              builder: (context, listingsProvider, _) {
                if (listingsProvider.searchQuery.isNotEmpty ||
                    listingsProvider.selectedCategory != 'All') {
                  return IconButton(
                    icon: const Icon(Icons.filter_alt_off),
                    onPressed: () {
                      _searchController.clear();
                      listingsProvider.clearFilters();
                    },
                    tooltip: 'Clear filters',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
