import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/screens/add_property_screen.dart';
import 'package:malkiyat_app/presentation/screens/explore_screen.dart';
import 'package:malkiyat_app/presentation/screens/login_screen.dart';
import 'package:malkiyat_app/presentation/screens/messages_screen.dart';
import 'package:malkiyat_app/presentation/screens/profile_screen.dart';
import 'package:malkiyat_app/presentation/widgets/featured_properties_section.dart';
import 'package:malkiyat_app/presentation/widgets/nearby_properties_section.dart';
import 'package:malkiyat_app/presentation/widgets/cities_section.dart';
import 'package:malkiyat_app/presentation/widgets/real_estate_categories_section.dart';
import 'package:malkiyat_app/presentation/widgets/list_property_banner.dart';
import 'package:malkiyat_app/presentation/widgets/home_header.dart';
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
    const ExploreScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  void _onAddTap() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onAddTap: _onAddTap,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 16),
                  ListPropertyBanner(),
                  SizedBox(height: 24),
                  RealEstateCategoriesSection(),
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
      ),
    );
  }
}
