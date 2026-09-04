import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/user_model.dart';
import 'package:malkiyat_app/data/repositories/chat_repository.dart';
import 'package:malkiyat_app/data/repositories/property_repository.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/screens/account_settings_screen.dart';
import 'package:malkiyat_app/presentation/screens/favorites_screen.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';
import 'package:malkiyat_app/presentation/screens/messages_screen.dart';
import 'package:malkiyat_app/presentation/screens/my_properties_screen.dart';
import 'package:malkiyat_app/presentation/screens/notifications_screen.dart';
import 'package:malkiyat_app/presentation/screens/projects_screen.dart';
import 'package:malkiyat_app/presentation/screens/register_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
                (route) => false,
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return _AuthenticatedProfile(user: state.user);
              }
              return _buildGuestProfile(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
              child: Icon(Icons.person_outline, size: 50, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text('Welcome to Malkiyat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Sign in to access your profile, favorites, and more',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthLandingScreen())),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthenticatedProfile extends StatefulWidget {
  final User user;
  const _AuthenticatedProfile({required this.user});

  @override
  State<_AuthenticatedProfile> createState() => _AuthenticatedProfileState();
}

class _AuthenticatedProfileState extends State<_AuthenticatedProfile> {
  late final Future<List<int>> _statsFuture = Future.wait([
    sl<PropertyRepository>().getMyFavorites().then((l) => l.length),
    sl<PropertyRepository>().getMyProperties().then((l) => l.length),
    sl<ChatRepository>().getConversations().then((l) => l.length),
  ]);

  String _accountId(String userId) => 'M-${userId.replaceAll('-', '').substring(0, 5).toUpperCase()}';

  Future<void> _emailSupport(String subject) async {
    final uri = Uri(scheme: 'mailto', path: 'support@malkiyat.pk', queryParameters: {'subject': subject});
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.hairline)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
                child: user.image == null ? const Icon(Icons.person, size: 32, color: Colors.white) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('Account ID · ${_accountId(user.id)}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Profile settings', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Stats row
        FutureBuilder<List<int>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            final stats = snapshot.data ?? [0, 0, 0];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.hairline)),
              child: Row(
                children: [
                  Expanded(child: _StatItem(value: stats[0], label: 'Saved', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())))),
                  const VerticalDivider(width: 1, indent: 8, endIndent: 8),
                  Expanded(child: _StatItem(value: stats[1], label: 'Listings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPropertiesScreen())))),
                  const VerticalDivider(width: 1, indent: 8, endIndent: 8),
                  Expanded(child: _StatItem(value: stats[2], label: 'Messages', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen())))),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        _buildMenuItem(icon: Icons.favorite_outline, title: 'My Favorites', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
        _buildMenuItem(icon: Icons.home_outlined, title: 'My Properties', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPropertiesScreen()))),
        _buildMenuItem(icon: Icons.drafts_outlined, title: 'Drafts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPropertiesScreen(isDraft: true, title: 'Drafts')))),
        _buildMenuItem(icon: Icons.apartment_outlined, title: 'Projects', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsScreen()))),
        _buildMenuItem(icon: Icons.chat_bubble_outline, title: 'Messages', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()))),
        _buildMenuItem(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
        _buildMenuItem(icon: Icons.help_outline, title: 'Help Center', onTap: () => _emailSupport('Help Center')),
        _buildMenuItem(icon: Icons.support_agent_outlined, title: 'Contact Support', onTap: () => _emailSupport('Support request')),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                child: const Text('Terms & Conditions'),
              ),
              const Text('·', style: TextStyle(color: AppTheme.textMuted)),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.hairline)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback onTap;

  const _StatItem({required this.value, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
