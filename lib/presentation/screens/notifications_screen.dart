import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// There's no notifications backend yet (no push tokens, no server-side
/// events to notify about), so this is an honest empty state rather than
/// a fake feed — matches ZippeeHomes' "You're all caught up" pattern.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryColor, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "You're all caught up",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                "We'll let you know here when your listing is approved, "
                "an inquiry comes in, or Malkiyat posts an announcement.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
