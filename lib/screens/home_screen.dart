import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../utils/constants.dart';
import 'directory/directory_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'map/map_view_screen.dart';
import 'settings/settings_screen.dart';

/// Main home screen with BottomNavigationBar.
///
/// Contains 4 tabs: Directory, My Listings, Map View, Settings.
/// Uses IndexedStack to preserve tab state when switching.
/// Initializes Firestore streams via [ListingsProvider] on load.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DirectoryScreen(),
    MyListingsScreen(),
    MapViewScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize Firestore streams after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStreams();
    });
  }

  void _initializeStreams() {
    final authProvider = context.read<AuthProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    // Start listening to all listings (for Directory and Map screens)
    listingsProvider.listenToAllListings();

    // Start listening to user-specific listings (for My Listings screen)
    if (authProvider.user != null) {
      listingsProvider.listenToUserListings(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Directory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'My Listings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map View',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
