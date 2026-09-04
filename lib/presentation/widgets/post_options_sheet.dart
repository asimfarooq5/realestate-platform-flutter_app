import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/add_property_screen.dart';

class _PostOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;

  const _PostOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
  });
}

const _options = [
  _PostOption(
    icon: Icons.home_outlined,
    title: 'List a Property',
    subtitle: 'Sell or rent a home, plot, or commercial space',
  ),
  _PostOption(
    icon: Icons.bed_outlined,
    title: 'Host a Stay',
    subtitle: 'Coming soon',
    enabled: false,
  ),
  _PostOption(
    icon: Icons.build_outlined,
    title: 'Add a Local Service',
    subtitle: 'Coming soon',
    enabled: false,
  ),
  _PostOption(
    icon: Icons.work_outline,
    title: 'Post a Job',
    subtitle: 'Coming soon',
    enabled: false,
  ),
];

/// The "+" button's bottom sheet — same list-with-icon-box pattern
/// ZippeeHomes uses, but Malkiyat is a single-vertical (real estate) app
/// so only "List a Property" actually does anything; the rest are shown
/// as disabled placeholders rather than pretending they work.
Future<void> showPostOptionsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const Text(
                'What would you like to post?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ..._options.map((option) => _OptionTile(
                    option: option,
                    onTap: option.enabled
                        ? () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
                            );
                          }
                        : null,
                  )),
            ],
          ),
        ),
      );
    },
  );
}

class _OptionTile extends StatelessWidget {
  final _PostOption option;
  final VoidCallback? onTap;

  const _OptionTile({required this.option, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: enabled ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icon,
                color: enabled ? AppTheme.primaryColor : AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: enabled ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            if (enabled) const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
