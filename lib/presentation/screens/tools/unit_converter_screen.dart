import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// Area-unit conversion factors, all relative to square feet — the units
/// buyers/sellers actually deal with in Pakistan (marla, kanal included).
const Map<String, double> _sqftPerUnit = {
  'Square Feet': 1,
  'Square Yards': 9,
  'Square Meters': 10.7639,
  'Marla': 225,
  'Kanal': 4500,
  'Acre': 43560,
};

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final _valueController = TextEditingController(text: '1');
  String _fromUnit = 'Marla';
  String _toUnit = 'Square Feet';

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  double get _result {
    final value = double.tryParse(_valueController.text) ?? 0;
    final sqft = value * _sqftPerUnit[_fromUnit]!;
    return sqft / _sqftPerUnit[_toUnit]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unit Convertor')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Convert between the area units used in property listings.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            _unitDropdown('From', _fromUnit, (v) => setState(() => _fromUnit = v!)),
            const SizedBox(height: 12),
            Center(
              child: IconButton(
                icon: const Icon(Icons.swap_vert, color: AppTheme.accentColor),
                onPressed: () => setState(() {
                  final temp = _fromUnit;
                  _fromUnit = _toUnit;
                  _toUnit = temp;
                }),
              ),
            ),
            const SizedBox(height: 4),
            _unitDropdown('To', _toUnit, (v) => setState(() => _toUnit = v!)),
            const SizedBox(height: 28),
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
                  Text('${_valueController.text.isEmpty ? '0' : _valueController.text} $_fromUnit =', style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${_result.toStringAsFixed(4)} $_toUnit', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: _sqftPerUnit.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
      onChanged: onChanged,
    );
  }
}
