import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/widgets/property_card.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! Authenticated) {
            return _buildGuestView(context);
          }
          return _buildFavoritesList(context);
        },
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign in to see your favorites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    context.read<PropertyBloc>().add(LoadFavorites());
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        if (state is FavoritesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PropertyError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PropertyBloc>().add(LoadFavorites());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is FavoritesLoaded) {
          if (state.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart on properties you like',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<PropertyBloc>().add(LoadFavorites());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.properties.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyCard(property: state.properties[index]),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
