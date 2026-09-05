import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/tools/beam_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/bricks_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/building_checklist_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/column_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/concrete_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/construction_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/rcc_slab_calculator_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/steel_weight_calculator_screen.dart';

/// Construction-site calculators — cost estimating and material/rebar
/// quantity tools, grouped separately from the general Milkiyat Tools.
class ConstructionToolsScreen extends StatelessWidget {
  const ConstructionToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      (icon: Icons.construction_outlined, title: 'Construction Calculator', subtitle: 'Estimate house construction cost by area and finish level', screen: const ConstructionCalculatorScreen()),
      (icon: Icons.foundation_outlined, title: 'Concrete Calculator', subtitle: 'Cement, sand, and aggregate quantity for a pour', screen: const ConcreteCalculatorScreen()),
      (icon: Icons.grid_on_outlined, title: 'RCC Slab Calculator', subtitle: 'Concrete and reinforcement steel for a slab', screen: const RccSlabCalculatorScreen()),
      (icon: Icons.view_column, title: 'Column Calculator', subtitle: 'Concrete and reinforcement steel for RCC columns', screen: const ColumnCalculatorScreen()),
      (icon: Icons.horizontal_rule, title: 'Beam Calculator', subtitle: 'Concrete and reinforcement steel for RCC beams', screen: const BeamCalculatorScreen()),
      (icon: Icons.view_column_outlined, title: 'Steel Weight Calculator', subtitle: 'Calculate rebar weight by diameter and length', screen: const SteelWeightCalculatorScreen()),
      (icon: Icons.window_outlined, title: 'Bricks Calculator', subtitle: 'Number of bricks, cement, and sand for a wall', screen: const BricksCalculatorScreen()),
      (icon: Icons.checklist_rtl, title: 'Building Checklist', subtitle: 'Track every stage from land to move-in', screen: const BuildingChecklistScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Construction Tools')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.hairline)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                child: Icon(tool.icon, color: AppTheme.primaryColor),
              ),
              title: Text(tool.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(tool.subtitle, style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => tool.screen)),
            ),
          );
        },
      ),
    );
  }
}
