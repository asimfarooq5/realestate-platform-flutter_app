import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// The single search-bar look used across Home, Explore, and Messages —
/// icon + text + a circular orange action button, on a filled pill.
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onActionTap;
  final IconData actionIcon;

  const AppSearchBar({
    super.key,
    this.controller,
    required this.hint,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onActionTap,
    this.actionIcon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: readOnly
                ? GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      hint,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  )
                : TextField(
                    controller: controller,
                    onTap: onTap,
                    onChanged: onChanged,
                    onSubmitted: (_) => onSubmitted?.call(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: hint,
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
          ),
          GestureDetector(
            onTap: onActionTap ?? onSubmitted ?? onTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
              child: Icon(actionIcon, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
