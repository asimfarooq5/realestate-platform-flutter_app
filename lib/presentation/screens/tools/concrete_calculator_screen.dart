import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

enum _Shape { slab, round }
enum _Unit { meter, feet }

class ConcreteCalculatorScreen extends StatefulWidget {
  const ConcreteCalculatorScreen({super.key});

  @override
  State<ConcreteCalculatorScreen> createState() => _ConcreteCalculatorScreenState();
}

class _ConcreteCalculatorScreenState extends State<ConcreteCalculatorScreen> {
  _Shape _shape = _Shape.slab;
  _Unit _unit = _Unit.meter;

  final _cementRatioController = TextEditingController(text: '1');
  final _sandRatioController = TextEditingController(text: '2');
  final _aggregateRatioController = TextEditingController(text: '4');

  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _diameterController = TextEditingController();

  final _bagWeightController = TextEditingController(text: '50');
  final _bagPriceController = TextEditingController(text: '0');
  final _labourCostController = TextEditingController(text: '0');

  _ConcreteResult? _result;

  @override
  void dispose() {
    for (final c in [
      _cementRatioController,
      _sandRatioController,
      _aggregateRatioController,
      _lengthController,
      _widthController,
      _heightController,
      _diameterController,
      _bagWeightController,
      _bagPriceController,
      _labourCostController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double get _toMeters => _unit == _Unit.meter ? 1 : 0.3048;

  void _calculate() {
    final cementRatio = double.tryParse(_cementRatioController.text) ?? 1;
    final sandRatio = double.tryParse(_sandRatioController.text) ?? 2;
    final aggregateRatio = double.tryParse(_aggregateRatioController.text) ?? 4;
    final totalRatio = cementRatio + sandRatio + aggregateRatio;
    if (totalRatio <= 0) return;

    double wetVolumeM3;
    double planAreaM2;
    if (_shape == _Shape.slab) {
      final l = (double.tryParse(_lengthController.text) ?? 0) * _toMeters;
      final b = (double.tryParse(_widthController.text) ?? 0) * _toMeters;
      final h = (double.tryParse(_heightController.text) ?? 0) * _toMeters;
      if (l <= 0 || b <= 0 || h <= 0) return;
      wetVolumeM3 = l * b * h;
      planAreaM2 = l * b;
    } else {
      final d = (double.tryParse(_diameterController.text) ?? 0) * _toMeters;
      final h = (double.tryParse(_heightController.text) ?? 0) * _toMeters;
      if (d <= 0 || h <= 0) return;
      final r = d / 2;
      wetVolumeM3 = math.pi * r * r * h;
      planAreaM2 = math.pi * r * r;
    }

    // Dry volume accounts for the void space that gets filled once water
    // is added — the standard 1.54 factor used in construction estimating.
    final dryVolumeM3 = wetVolumeM3 * 1.54;
    final cementVolumeM3 = dryVolumeM3 * (cementRatio / totalRatio);
    final sandVolumeM3 = dryVolumeM3 * (sandRatio / totalRatio);
    final aggregateVolumeM3 = dryVolumeM3 * (aggregateRatio / totalRatio);

    const cementDensityKgPerM3 = 1440.0;
    final cementWeightKg = cementVolumeM3 * cementDensityKgPerM3;
    final bagWeight = double.tryParse(_bagWeightController.text) ?? 50;
    final bagPrice = double.tryParse(_bagPriceController.text) ?? 0;
    final cementBags = bagWeight > 0 ? cementWeightKg / bagWeight : 0.0;
    final cementCost = cementBags * bagPrice;

    final labourRate = double.tryParse(_labourCostController.text) ?? 0;
    final areaInDisplayUnit = _unit == _Unit.meter ? planAreaM2 : planAreaM2 / (0.3048 * 0.3048);
    final labourCost = labourRate * areaInDisplayUnit;

    final toDisplayVolume = _unit == _Unit.meter ? 1.0 : (1 / math.pow(0.3048, 3)).toDouble();

    setState(() {
      _result = _ConcreteResult(
        concreteVolume: wetVolumeM3 * toDisplayVolume,
        cementBags: cementBags,
        cementCost: cementCost,
        sandVolume: sandVolumeM3 * toDisplayVolume,
        aggregateVolume: aggregateVolumeM3 * toDisplayVolume,
        labourCost: labourCost,
      );
    });
  }

  String get _volumeUnitLabel => _unit == _Unit.meter ? 'm³' : 'CFT';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Concrete Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calculate cement, sand, and aggregate quantity for a concrete pour.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _sectionLabel('Shape'),
            _chipRow(
              options: const {'Slab / Cube': _Shape.slab, 'Round': _Shape.round},
              selected: _shape,
              onSelected: (v) => setState(() => _shape = v),
            ),
            const SizedBox(height: 16),
            _sectionLabel('Unit'),
            _chipRow(
              options: const {'Meter': _Unit.meter, 'Feet': _Unit.feet},
              selected: _unit,
              onSelected: (v) => setState(() => _unit = v),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Mix Ratio (Cement : Sand : Aggregate)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_cementRatioController, 'Cement')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_sandRatioController, 'Sand')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_aggregateRatioController, 'Aggregate')),
              ],
            ),
            const SizedBox(height: 20),
            _sectionLabel(_shape == _Shape.slab ? 'Dimensions' : 'Dimensions (Diameter & Height)'),
            const SizedBox(height: 8),
            if (_shape == _Shape.slab) ...[
              Row(
                children: [
                  Expanded(child: _numberField(_lengthController, 'Length (${_unit == _Unit.meter ? 'm' : 'ft'})')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(_widthController, 'Width (${_unit == _Unit.meter ? 'm' : 'ft'})')),
                ],
              ),
              const SizedBox(height: 12),
              _numberField(_heightController, 'Height (${_unit == _Unit.meter ? 'm' : 'ft'})'),
            ] else ...[
              _numberField(_diameterController, 'Diameter (${_unit == _Unit.meter ? 'm' : 'ft'})'),
              const SizedBox(height: 12),
              _numberField(_heightController, 'Height (${_unit == _Unit.meter ? 'm' : 'ft'})'),
            ],
            const SizedBox(height: 20),
            _sectionLabel('Cost (optional)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_bagWeightController, 'Cement Bag (kg)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_bagPriceController, 'Bag Price (PKR)')),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(_labourCostController, 'Labour Cost per ${_unit == _Unit.meter ? 'sq.m' : 'sq.ft'} (PKR)'),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculate, child: const Text('Calculate'))),
            if (_result != null) ...[
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
                    _resultRow('Concrete Volume', '${_result!.concreteVolume.toStringAsFixed(3)} $_volumeUnitLabel'),
                    _resultRow('Cement Bags', _result!.cementBags.toStringAsFixed(2)),
                    _resultRow('Cement Cost', 'PKR ${_result!.cementCost.toStringAsFixed(0)}'),
                    _resultRow('Sand', '${_result!.sandVolume.toStringAsFixed(3)} $_volumeUnitLabel'),
                    _resultRow('Aggregate', '${_result!.aggregateVolume.toStringAsFixed(3)} $_volumeUnitLabel'),
                    _resultRow('Labour Cost', 'PKR ${_result!.labourCost.toStringAsFixed(0)}', isLast: true),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w700));

  Widget _chipRow<T>({required Map<String, T> options, required T selected, required ValueChanged<T> onSelected}) {
    return Wrap(
      spacing: 8,
      children: options.entries.map((e) {
        return ChoiceChip(label: Text(e.key), selected: e.value == selected, onSelected: (_) => onSelected(e.value));
      }).toList(),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
    );
  }

  Widget _resultRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }
}

class _ConcreteResult {
  final double concreteVolume;
  final double cementBags;
  final double cementCost;
  final double sandVolume;
  final double aggregateVolume;
  final double labourCost;

  _ConcreteResult({
    required this.concreteVolume,
    required this.cementBags,
    required this.cementCost,
    required this.sandVolume,
    required this.aggregateVolume,
    required this.labourCost,
  });
}
