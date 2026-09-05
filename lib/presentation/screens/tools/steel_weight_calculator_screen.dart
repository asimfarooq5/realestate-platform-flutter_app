import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

const _standardBarDiameters = [6, 8, 10, 12, 16, 20, 25, 32, 36];

class SteelWeightCalculatorScreen extends StatefulWidget {
  const SteelWeightCalculatorScreen({super.key});

  @override
  State<SteelWeightCalculatorScreen> createState() => _SteelWeightCalculatorScreenState();
}

class _SteelWeightCalculatorScreenState extends State<SteelWeightCalculatorScreen> {
  int _diameter = 12;
  final _lengthController = TextEditingController(text: '12');
  final _quantityController = TextEditingController(text: '1');
  double? _totalWeight;

  @override
  void dispose() {
    _lengthController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _calculate() {
    final lengthMeters = double.tryParse(_lengthController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    if (lengthMeters <= 0 || quantity <= 0) {
      setState(() => _totalWeight = null);
      return;
    }
    // Standard rebar weight formula: W (kg/m) = d² / 162, d in mm.
    final weightPerMeter = (_diameter * _diameter) / 162;
    setState(() => _totalWeight = weightPerMeter * lengthMeters * quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Steel Weight Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calculate the weight of reinforcement steel bars (rebar).', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            const Text('Bar Diameter (mm)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _standardBarDiameters.map((d) {
                final selected = d == _diameter;
                return ChoiceChip(
                  label: Text('$d mm'),
                  selected: selected,
                  onSelected: (_) => setState(() => _diameter = d),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _lengthController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Length per Bar (meters)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Bars', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
            ),
            if (_totalWeight != null) ...[
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
                    const Text('Total Weight', style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${_totalWeight!.toStringAsFixed(2)} kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
