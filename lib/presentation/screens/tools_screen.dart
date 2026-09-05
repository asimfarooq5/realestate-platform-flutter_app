import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/installment_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/beam_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/building_checklist_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/column_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/concrete_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/construction_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/interview_questions_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/rcc_slab_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/smart_tools_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/steel_weight_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/unit_converter_screen.dart';

/// "Milkiyat Tools" hub — a growing set of small, real utilities for buyers
/// and sellers. Add new tools here as their own screen + a _ToolTile entry.
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
            icon: Icons.construction_outlined,
            title: 'Construction Calculator',
            subtitle: 'Estimate house construction cost by area and finish level',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConstructionCalculatorScreen())),
          ),
          _ToolTile(
            icon: Icons.checklist_rtl,
            title: 'Building Checklist',
            subtitle: 'Track every stage from land to move-in',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuildingChecklistScreen())),
          ),
          _ToolTile(
            icon: Icons.foundation_outlined,
            title: 'Concrete Calculator',
            subtitle: 'Cement, sand, and aggregate quantity for a pour',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConcreteCalculatorScreen())),
          ),
          _ToolTile(
            icon: Icons.grid_on_outlined,
            title: 'RCC Slab Calculator',
            subtitle: 'Concrete and reinforcement steel for a slab',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RccSlabCalculatorScreen())),
          ),
          _ToolTile(
            icon: Icons.view_column,
            title: 'Column Calculator',
            subtitle: 'Concrete and reinforcement steel for RCC columns',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColumnCalculatorScreen())),
          ),
          _ToolTile(
            icon: Icons.horizontal_rule,
            title: 'Beam Calculator',
            subtitle: 'Concrete and reinforcement steel for RCC beams',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeamCalculatorScreen())),
          ),
          _ToolTile(
            icon: Icons.view_column_outlined,
            title: 'Steel Weight Calculator',
            subtitle: 'Calculate rebar weight by diameter and length',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SteelWeightCalculatorScreen())),
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
