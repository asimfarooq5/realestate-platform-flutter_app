import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// Floating pill bottom nav bar, matching the ZippeeHomes GlobalBottomNav
/// look — translucent white pill, hairline border, soft navy-tinted shadow,
/// a raised orange FAB in the center for posting a listing, and the
/// remaining four tabs (Home/Explore/Messages/Account) split around it.
class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  static const _leftItems = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    (icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
  ];

  static const _rightItems = [
    (icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Messages'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 76,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.navy.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navy.withValues(alpha: 0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ..._leftItems.asMap().entries.map((entry) => _NavItem(
                          icon: entry.key == currentIndex ? entry.value.activeIcon : entry.value.icon,
                          label: entry.value.label,
                          active: entry.key == currentIndex,
                          onTap: () => onTap(entry.key),
                        )),
                    const SizedBox(width: 56),
                    ..._rightItems.asMap().entries.map((entry) {
                      final index = entry.key + 2;
                      return _NavItem(
                        icon: index == currentIndex ? entry.value.activeIcon : entry.value.icon,
                        label: entry.value.label,
                        active: index == currentIndex,
                        onTap: () => onTap(index),
                      );
                    }),
                  ],
                ),
              ),
              Positioned(
                bottom: 26,
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentColor,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.navy : AppTheme.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.navy.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
