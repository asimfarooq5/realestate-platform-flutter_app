import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';

/// A promotional CTA banner, in the same visual slot ZippeeHomes uses for
/// its rotating "Signature Experience" carousel — but pointed at something
/// actually useful for a real-estate app: getting a listing posted.
class ListPropertyBanner extends StatelessWidget {
  const ListPropertyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppTheme.navy.withValues(alpha: 0.88)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(999)),
                child: const Text(
                  'FOR PROPERTY OWNERS',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'List your property for free',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Reach thousands of buyers and renters across Pakistan',
                style: TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! Authenticated) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthLandingScreen()));
                    return;
                  }
                  // TODO: navigate to the add-property flow once it exists.
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Post Now', style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800, fontSize: 13)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 14, color: AppTheme.navy),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
