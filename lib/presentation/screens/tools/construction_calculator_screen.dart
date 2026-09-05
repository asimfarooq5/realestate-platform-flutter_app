import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

enum _FinishLevel { grayStructure, semiFinished, fullyFinished }

extension on _FinishLevel {
  String get label => switch (this) {
        _FinishLevel.grayStructure => 'Gray Structure',
        _FinishLevel.semiFinished => 'Semi-Finished',
        _FinishLevel.fullyFinished => 'Fully Finished',
      };

  /// Typical Pakistan construction cost per sqft (PKR) — a starting
  /// estimate; the rate field stays editable since prices vary by city.
  double get defaultRatePerSqft => switch (this) {
        _FinishLevel.grayStructure => 2800,
        _FinishLevel.semiFinished => 3800,
        _FinishLevel.fullyFinished => 5200,
      };
}

class ConstructionCalculatorScreen extends StatefulWidget {
  const ConstructionCalculatorScreen({super.key});

  @override
  State<ConstructionCalculatorScreen> createState() => _ConstructionCalculatorScreenState();
}

class _ConstructionCalculatorScreenState extends State<ConstructionCalculatorScreen> {
  final _areaController = TextEditingController();
  final _rateController = TextEditingController();
  _FinishLevel _level = _FinishLevel.grayStructure;
  double? _totalCost;

  @override
  void initState() {
    super.initState();
    _rateController.text = _level.defaultRatePerSqft.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _areaController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculate() {
    final area = double.tryParse(_areaController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    setState(() => _totalCost = area > 0 && rate > 0 ? area * rate : null);
  }

  String _fmt(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Construction Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimate the cost of constructing a house based on covered area and finish level.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            const Text('Finish Level', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _FinishLevel.values.map((level) {
                final selected = level == _level;
                return ChoiceChip(
                  label: Text(level.label),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _level = level;
                    _rateController.text = level.defaultRatePerSqft.toStringAsFixed(0);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Covered Area (sqft)', hintText: 'e.g. 1800', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Rate per Sqft (PKR)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
            ),
            if (_totalCost != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated Construction Cost', style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('PKR ${_fmt(_totalCost!)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This is a rough estimate. Actual cost depends on design, location, and material choices.',
                style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
