import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/config/app_config.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/login_screen.dart';
import 'package:malkiyat_app/presentation/screens/register_screen.dart';
import 'package:malkiyat_app/presentation/widgets/google_sign_in_button.dart';

/// The auth entry point — a photo background with a bottom sheet-styled
/// card offering Sign In / Create Account / Google / Email, matching
/// ZippeeHomes' landing pattern. This replaces every direct navigation to
/// LoginScreen elsewhere in the app, so "sign in to continue" always looks
/// the same regardless of where it was triggered from.
class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
            fit: BoxFit.cover,
          ),
          Container(color: AppTheme.navy.withValues(alpha: 0.55)),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/icons/app_icon.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Malkiyat',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text('Create Account'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or', style: TextStyle(color: AppTheme.textMuted)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const GoogleSignInButton(),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          icon: const Icon(Icons.mail_outline, color: AppTheme.textPrimary),
                          label: const Text('Continue with email', style: TextStyle(color: AppTheme.textPrimary)),
                        ),
                      ),
                      if (!AppConfig.isGoogleSignInConfigured) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Google Sign-In is coming soon',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
