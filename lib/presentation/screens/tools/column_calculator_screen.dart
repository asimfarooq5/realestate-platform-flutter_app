import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

enum _Shape { rectangular, round }
enum _Unit { feet, meter }

class ColumnCalculatorScreen extends StatefulWidget {
  const ColumnCalculatorScreen({super.key});

  @override
  State<ColumnCalculatorScreen> createState() => _ColumnCalculatorScreenState();
}

class _ColumnCalculatorScreenState extends State<ColumnCalculatorScreen> {
  _Shape _shape = _Shape.rectangular;
  _Unit _unit = _Unit.feet;

  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _diameterController = TextEditingController();
  final _heightController = TextEditingController(text: '12');

  final _longBarCountController = TextEditingController(text: '4');
  final _longBarDiaController = TextEditingController(text: '16');
  final _tieDiaController = TextEditingController(text: '8');
  final _tieSpacingController = TextEditingController(text: '6');

  final _cementRatioController = TextEditingController(text: '1');
  final _sandRatioController = TextEditingController(text: '2');
  final _aggregateRatioController = TextEditingController(text: '4');
  final _bagWeightController = TextEditingController(text: '50');
  final _bagPriceController = TextEditingController(text: '0');
  final _columnCountController = TextEditingController(text: '1');
  final _labourPriceController = TextEditingController(text: '0');
  final _steelPriceController = TextEditingController(text: '0');

  _ColumnResult? _result;

  @override
  void dispose() {
    for (final c in [
      _lengthController,
      _widthController,
      _diameterController,
      _heightController,
      _longBarCountController,
      _longBarDiaController,
      _tieDiaController,
      _tieSpacingController,
      _cementRatioController,
      _sandRatioController,
      _aggregateRatioController,
      _bagWeightController,
      _bagPriceController,
      _columnCountController,
      _labourPriceController,
      _steelPriceController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _unitChanged(_Unit unit) {
    setState(() {
      if (unit == _Unit.meter && _unit == _Unit.feet) {
        _heightController.text = '3.5';
        _tieSpacingController.text = '150';
      } else if (unit == _Unit.feet && _unit == _Unit.meter) {
        _heightController.text = '12';
        _tieSpacingController.text = '6';
      }
      _unit = unit;
    });
  }

  void _calculate() {
    final heightRaw = double.tryParse(_heightController.text) ?? 0;
    final heightM = _unit == _Unit.feet ? heightRaw * 0.3048 : heightRaw;

    double crossSectionM2;
    double perimeterM;
    if (_shape == _Shape.rectangular) {
      final lengthRaw = double.tryParse(_lengthController.text) ?? 0;
      final widthRaw = double.tryParse(_widthController.text) ?? 0;
      if (lengthRaw <= 0 || widthRaw <= 0 || heightM <= 0) return;
      final lengthM = _unit == _Unit.feet ? lengthRaw * 0.0254 : lengthRaw / 100;
      final widthM = _unit == _Unit.feet ? widthRaw * 0.0254 : widthRaw / 100;
      crossSectionM2 = lengthM * widthM;
      perimeterM = 2 * (lengthM + widthM);
    } else {
      final diaRaw = double.tryParse(_diameterController.text) ?? 0;
      if (diaRaw <= 0 || heightM <= 0) return;
      final diaM = _unit == _Unit.feet ? diaRaw * 0.0254 : diaRaw / 100;
      final radius = diaM / 2;
      crossSectionM2 = math.pi * radius * radius;
      perimeterM = math.pi * diaM;
    }

    final tieSpacingRaw = double.tryParse(_tieSpacingController.text) ?? 6;
    final tieSpacingM = _unit == _Unit.feet ? (tieSpacingRaw * 25.4) / 1000 : tieSpacingRaw / 1000;

    final cementRatio = double.tryParse(_cementRatioController.text) ?? 1;
    final sandRatio = double.tryParse(_sandRatioController.text) ?? 2;
    final aggregateRatio = double.tryParse(_aggregateRatioController.text) ?? 4;
    final totalRatio = cementRatio + sandRatio + aggregateRatio;
    if (totalRatio <= 0) return;

    final columnCount = double.tryParse(_columnCountController.text) ?? 1;

    // --- Concrete quantity (per column, then × count) ---
    final wetVolumeM3 = crossSectionM2 * heightM;
    final dryVolumeM3 = wetVolumeM3 * 1.54;
    final cementVolumeM3 = dryVolumeM3 * (cementRatio / totalRatio);
    final sandVolumeM3 = dryVolumeM3 * (sandRatio / totalRatio);
    final aggregateVolumeM3 = dryVolumeM3 * (aggregateRatio / totalRatio);

    const cementDensityKgPerM3 = 1440.0;
    final cementWeightKg = cementVolumeM3 * cementDensityKgPerM3;
    final bagWeight = double.tryParse(_bagWeightController.text) ?? 50;
    final cementBagsPerColumn = bagWeight > 0 ? cementWeightKg / bagWeight : 0.0;

    // --- Steel: longitudinal bars (full height) + ties (wrapped at spacing) ---
    final longBarCount = double.tryParse(_longBarCountController.text) ?? 4;
    final longBarDia = double.tryParse(_longBarDiaController.text) ?? 16;
    final tieDia = double.tryParse(_tieDiaController.text) ?? 8;

    final longitudinalLengthM = longBarCount * heightM;
    final longitudinalWeightKg = (longBarDia * longBarDia / 162) * longitudinalLengthM;

    final tieCount = (heightM / tieSpacingM).floor() + 1;
    final totalTieLengthM = tieCount * perimeterM;
    final tieWeightKg = (tieDia * tieDia / 162) * totalTieLengthM;

    final steelWeightPerColumn = longitudinalWeightKg + tieWeightKg;

    // --- Totals across all columns ---
    final totalConcreteVolumeM3 = wetVolumeM3 * columnCount;
    final totalCementBags = cementBagsPerColumn * columnCount;
    final totalSandVolumeM3 = sandVolumeM3 * columnCount;
    final totalAggregateVolumeM3 = aggregateVolumeM3 * columnCount;
    final totalSteelWeightKg = steelWeightPerColumn * columnCount;

    final volumeToDisplayUnit = _unit == _Unit.feet ? (1 / (0.3048 * 0.3048 * 0.3048)) : 1.0;
    final bagPrice = double.tryParse(_bagPriceController.text) ?? 0;
    final labourPrice = double.tryParse(_labourPriceController.text) ?? 0;
    final steelPrice = double.tryParse(_steelPriceController.text) ?? 0;

    final displayVolume = totalConcreteVolumeM3 * volumeToDisplayUnit;
    final cementCost = totalCementBags * bagPrice;
    final labourCost = displayVolume * labourPrice;
    final steelCost = totalSteelWeightKg * steelPrice;

    setState(() {
      _result = _ColumnResult(
        concreteVolume: displayVolume,
        cementBags: totalCementBags,
        sandVolume: totalSandVolumeM3 * volumeToDisplayUnit,
        aggregateVolume: totalAggregateVolumeM3 * volumeToDisplayUnit,
        steelWeight: totalSteelWeightKg,
        cementCost: cementCost,
        labourCost: labourCost,
        steelCost: steelCost,
        totalCost: cementCost + labourCost + steelCost,
      );
    });
  }

  String get _volumeUnit => _unit == _Unit.feet ? 'CFT' : 'm³';
  String get _lateralUnit => _unit == _Unit.feet ? 'inch' : 'cm';
  String get _heightUnit => _unit == _Unit.feet ? 'ft' : 'm';
  String get _spacingUnit => _unit == _Unit.feet ? 'inch' : 'mm';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Column Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimate concrete and reinforcement steel quantity for RCC columns.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _sectionLabel('Shape'),
            _chipRow(options: const {'Rectangular': _Shape.rectangular, 'Round': _Shape.round}, selected: _shape, onSelected: (v) => setState(() => _shape = v)),
            const SizedBox(height: 12),
            _sectionLabel('Unit'),
            _chipRow(options: const {'Feet': _Unit.feet, 'Meter': _Unit.meter}, selected: _unit, onSelected: _unitChanged),
            const SizedBox(height: 20),
            _sectionLabel('Dimension of Column'),
            const SizedBox(height: 8),
            if (_shape == _Shape.rectangular)
              Row(
                children: [
                  Expanded(child: _numberField(_lengthController, 'Length ($_lateralUnit)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(_widthController, 'Width ($_lateralUnit)')),
                ],
              )
            else
              _numberField(_diameterController, 'Diameter ($_lateralUnit)'),
            const SizedBox(height: 12),
            _numberField(_heightController, 'Height ($_heightUnit)'),
            const SizedBox(height: 20),
            _sectionLabel('Steel Detail'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_longBarCountController, 'No. of Long Bars')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_longBarDiaController, 'Long Bar Dia (mm)')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_tieDiaController, 'Tie Dia (mm)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_tieSpacingController, 'Tie Spacing ($_spacingUnit)')),
              ],
            ),
            const SizedBox(height: 20),
            _sectionLabel('Concrete Ratio (Cement : Sand : Aggregate)'),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_bagWeightController, 'Cement Bag (kg)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_columnCountController, 'Number of Columns')),
              ],
            ),
            const SizedBox(height: 20),
            _sectionLabel('Cost (optional)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_bagPriceController, '1 Cement Bag Price')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_steelPriceController, '1kg Steel Price')),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(_labourPriceController, 'Labour Cost Per $_volumeUnit'),
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
                    _resultRow('Concrete Volume', '${_result!.concreteVolume.toStringAsFixed(3)} $_volumeUnit'),
                    _resultRow('Cement Bags', _result!.cementBags.toStringAsFixed(2)),
                    _resultRow('Sand', '${_result!.sandVolume.toStringAsFixed(3)} $_volumeUnit'),
                    _resultRow('Aggregate', '${_result!.aggregateVolume.toStringAsFixed(3)} $_volumeUnit'),
                    _resultRow('Steel Weight', '${_result!.steelWeight.toStringAsFixed(2)} kg'),
                    const Divider(height: 24),
                    _resultRow('Cement Cost', 'PKR ${_result!.cementCost.toStringAsFixed(0)}'),
                    _resultRow('Steel Cost', 'PKR ${_result!.steelCost.toStringAsFixed(0)}'),
                    _resultRow('Labour Cost', 'PKR ${_result!.labourCost.toStringAsFixed(0)}'),
                    const Divider(height: 24),
                    _resultRow('Total Cost', 'PKR ${_result!.totalCost.toStringAsFixed(0)}', isLast: true, emphasize: true),
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
      children: options.entries.map((e) => ChoiceChip(label: Text(e.key), selected: e.value == selected, onSelected: (_) => onSelected(e.value))).toList(),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
    );
  }

  Widget _resultRow(String label, String value, {bool isLast = false, bool emphasize = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: emphasize ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: emphasize ? FontWeight.w700 : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: emphasize ? 17 : 14)),
        ],
      ),
    );
  }
}

class _ColumnResult {
  final double concreteVolume;
  final double cementBags;
  final double sandVolume;
  final double aggregateVolume;
  final double steelWeight;
  final double cementCost;
  final double labourCost;
  final double steelCost;
  final double totalCost;

  _ColumnResult({
    required this.concreteVolume,
    required this.cementBags,
    required this.sandVolume,
    required this.aggregateVolume,
    required this.steelWeight,
    required this.cementCost,
    required this.labourCost,
    required this.steelCost,
    required this.totalCost,
  });
}
