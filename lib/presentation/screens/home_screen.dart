import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/search_screen.dart';
import 'package:malkiyat_app/presentation/screens/favorites_screen.dart';
import 'package:malkiyat_app/presentation/screens/profile_screen.dart';
import 'package:malkiyat_app/presentation/widgets/featured_properties_section.dart';
import 'package:malkiyat_app/presentation/widgets/nearby_properties_section.dart';
import 'package:malkiyat_app/presentation/widgets/cities_section.dart';
import 'package:malkiyat_app/presentation/widgets/property_types_section.dart';
import 'package:malkiyat_app/presentation/widgets/search_bar_widget.dart';
import 'package:malkiyat_app/presentation/widgets/floating_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const SearchScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed gradient header — mirrors ZippeeHomes' diagonal
        // navy-to-blue AppHeader with rounded bottom corners. Unlike a
        // SliverAppBar this never collapses/shows a title over the search
        // bar while scrolling.
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.headerGradient,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Your Dream Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Discover properties across Pakistan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchBarWidget(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Scrolling content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 20),
                PropertyTypesSection(),
                SizedBox(height: 24),
                NearbyPropertiesSection(),
                SizedBox(height: 24),
                FeaturedPropertiesSection(),
                SizedBox(height: 24),
                CitiesSection(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
