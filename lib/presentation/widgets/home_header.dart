import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/services/location_service.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/screens/explore_screen.dart';
import 'package:malkiyat_app/presentation/screens/notifications_screen.dart';
import 'package:malkiyat_app/presentation/screens/profile_screen.dart';
import 'package:malkiyat_app/presentation/screens/search_screen.dart';
import 'package:malkiyat_app/presentation/widgets/app_search_bar.dart';

/// The home tab's header — logo/wordmark, current location, notifications
/// and account shortcuts, and the search bar. Matches ZippeeHomes' plain
/// white header (as opposed to the gradient AppHeader used elsewhere).
class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final LocationService _locationService = sl<LocationService>();
  String _locationLabel = 'Pakistan';

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  Future<void> _resolveLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position == null || !mounted) return;
    final label = await _locationService.describePosition(position);
    if (label != null && mounted) {
      setState(() => _locationLabel = label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/icons/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        children: [
                          TextSpan(text: 'mal', style: TextStyle(color: AppTheme.navy)),
                          TextSpan(text: 'kiyat', style: TextStyle(color: AppTheme.accentColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: AppTheme.accentColor),
                        const SizedBox(width: 3),
                        Text(
                          _locationLabel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _IconCircle(
                icon: Icons.notifications_none_rounded,
                background: AppTheme.surfaceAlt,
                iconColor: AppTheme.textPrimary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
              const SizedBox(width: 10),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state is Authenticated ? state.user : null;
                  final initial = (user?.name?.isNotEmpty == true
                          ? user!.name![0]
                          : (user?.email.isNotEmpty == true ? user!.email[0] : '?'))
                      .toUpperCase();
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor,
                      child: user == null
                          ? const Icon(Icons.person_outline, color: Colors.white, size: 20)
                          : Text(
                              initial,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  readOnly: true,
                  hint: 'Search homes, plots, commercial...',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _IconCircle(
                icon: Icons.map_outlined,
                background: AppTheme.surfaceAlt,
                iconColor: AppTheme.textPrimary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExploreScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  const _IconCircle({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: background,
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
