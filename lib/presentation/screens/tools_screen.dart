import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/installment_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/construction_tools_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/interview_questions_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/smart_tools_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/unit_converter_screen.dart';

/// "Milkiyat Tools" hub — a growing set of small, real utilities for buyers
/// and sellers. Add new tools here as their own screen + a _ToolTile entry
/// (or into a category sub-hub like ConstructionToolsScreen).
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Malkiyat Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToolTile(
            icon: Icons.calculate_outlined,
            title: 'Installment Calculator',
            subtitle: 'Estimate your monthly installment before you commit',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstallmentCalculatorScreen())),
          ),
          _ToolTile(
            icon: Icons.engineering_outlined,
            title: 'Construction Tools',
            subtitle: 'Concrete, steel, slab, column, and beam calculators',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConstructionToolsScreen())),
          ),
          _ToolTile(
            icon: Icons.swap_horiz,
            title: 'Unit Convertor',
            subtitle: 'Convert between sqft, marla, kanal, and more',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitConverterScreen())),
          ),
          _ToolTile(
            icon: Icons.handyman_outlined,
            title: 'Smart Tools',
            subtitle: 'Level, Tape Measure, Flashlight, QR Scanner',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartToolsScreen())),
          ),
          _ToolTile(
            icon: Icons.record_voice_over_outlined,
            title: 'Interview Questions',
            subtitle: 'Common questions and tips for job interviews',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InterviewQuestionsScreen())),
          ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.hairline)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
