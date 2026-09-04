import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/config/app_config.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// "Continue with Google" — reads GOOGLE_CLIENT_ID from the build
/// environment (--dart-define=GOOGLE_CLIENT_ID=...). Real credentials
/// aren't wired up yet, so tapping this shows a clear "not available yet"
/// message instead of pretending to sign the user in.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  void _onPressed(BuildContext context) {
    if (!AppConfig.isGoogleSignInConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In is not set up yet — check back soon.')),
      );
      return;
    }
    // TODO: wire up the real Google Sign-In flow once GOOGLE_CLIENT_ID
    // (and the matching backend OAuth verification endpoint) exist.
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _onPressed(context),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.border)),
        icon: const Text(
          'G',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF4285F4)),
        ),
        label: const Text('Continue with Google', style: TextStyle(color: AppTheme.textPrimary)),
      ),
    );
  }
}
