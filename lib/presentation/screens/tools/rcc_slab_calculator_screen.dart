import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

enum _Unit { feet, meter }

class RccSlabCalculatorScreen extends StatefulWidget {
  const RccSlabCalculatorScreen({super.key});

  @override
  State<RccSlabCalculatorScreen> createState() => _RccSlabCalculatorScreenState();
}

class _RccSlabCalculatorScreenState extends State<RccSlabCalculatorScreen> {
  _Unit _unit = _Unit.feet;

  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _thicknessController = TextEditingController(text: '6');

  final _cementRatioController = TextEditingController(text: '1');
  final _sandRatioController = TextEditingController(text: '2');
  final _aggregateRatioController = TextEditingController(text: '4');
  final _bagWeightController = TextEditingController(text: '50');

  final _mainBarSpacingController = TextEditingController(text: '6');
  final _distBarSpacingController = TextEditingController(text: '8');
  final _mainBarDiaController = TextEditingController(text: '10');
  final _distBarDiaController = TextEditingController(text: '10');
  final _meshCountController = TextEditingController(text: '1');

  final _steelPriceController = TextEditingController(text: '0');
  final _cementPriceController = TextEditingController(text: '0');
  final _sandPriceController = TextEditingController(text: '0');
  final _aggregatePriceController = TextEditingController(text: '0');
  final _labourPriceController = TextEditingController(text: '0');

  _SlabResult? _result;

  @override
  void dispose() {
    for (final c in [
      _lengthController,
      _widthController,
      _thicknessController,
      _cementRatioController,
      _sandRatioController,
      _aggregateRatioController,
      _bagWeightController,
      _mainBarSpacingController,
      _distBarSpacingController,
      _mainBarDiaController,
      _distBarDiaController,
      _meshCountController,
      _steelPriceController,
      _cementPriceController,
      _sandPriceController,
      _aggregatePriceController,
      _labourPriceController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _unitChanged(_Unit unit) {
    setState(() {
      // Swap the defaults shown for thickness/spacing to the new unit's scale.
      if (unit == _Unit.feet && _unit == _Unit.meter) {
        _thicknessController.text = '6';
        _mainBarSpacingController.text = '6';
        _distBarSpacingController.text = '8';
      } else if (unit == _Unit.meter && _unit == _Unit.feet) {
        _thicknessController.text = '150';
        _mainBarSpacingController.text = '150';
        _distBarSpacingController.text = '200';
      }
      _unit = unit;
    });
  }

  void _calculate() {
    final length = double.tryParse(_lengthController.text) ?? 0;
    final width = double.tryParse(_widthController.text) ?? 0;
    final thickness = double.tryParse(_thicknessController.text) ?? 0;
    if (length <= 0 || width <= 0 || thickness <= 0) return;

    // Normalize everything to meters and millimeters internally.
    final lengthM = _unit == _Unit.feet ? length * 0.3048 : length;
    final widthM = _unit == _Unit.feet ? width * 0.3048 : width;
    final thicknessM = _unit == _Unit.feet ? thickness * 0.0254 : thickness / 1000;

    final mainSpacingRaw = double.tryParse(_mainBarSpacingController.text) ?? 6;
    final distSpacingRaw = double.tryParse(_distBarSpacingController.text) ?? 8;
    final mainSpacingMm = _unit == _Unit.feet ? mainSpacingRaw * 25.4 : mainSpacingRaw;
    final distSpacingMm = _unit == _Unit.feet ? distSpacingRaw * 25.4 : distSpacingRaw;

    final cementRatio = double.tryParse(_cementRatioController.text) ?? 1;
    final sandRatio = double.tryParse(_sandRatioController.text) ?? 2;
    final aggregateRatio = double.tryParse(_aggregateRatioController.text) ?? 4;
    final totalRatio = cementRatio + sandRatio + aggregateRatio;
    if (totalRatio <= 0) return;

    // --- Concrete quantity ---
    final wetVolumeM3 = lengthM * widthM * thicknessM;
    final dryVolumeM3 = wetVolumeM3 * 1.54;
    final cementVolumeM3 = dryVolumeM3 * (cementRatio / totalRatio);
    final sandVolumeM3 = dryVolumeM3 * (sandRatio / totalRatio);
    final aggregateVolumeM3 = dryVolumeM3 * (aggregateRatio / totalRatio);

    const cementDensityKgPerM3 = 1440.0;
    final cementWeightKg = cementVolumeM3 * cementDensityKgPerM3;
    final bagWeight = double.tryParse(_bagWeightController.text) ?? 50;
    final cementBags = bagWeight > 0 ? cementWeightKg / bagWeight : 0.0;

    // --- Reinforcement (two-way mesh) ---
    final mainBarDia = double.tryParse(_mainBarDiaController.text) ?? 10;
    final distBarDia = double.tryParse(_distBarDiaController.text) ?? 10;
    final meshCount = double.tryParse(_meshCountController.text) ?? 1;

    final mainBarCount = (widthM * 1000 / mainSpacingMm).floor() + 1;
    final distBarCount = (lengthM * 1000 / distSpacingMm).floor() + 1;
    final totalMainBarLengthM = mainBarCount * lengthM;
    final totalDistBarLengthM = distBarCount * widthM;

    // Standard rebar weight formula: W (kg/m) = d² / 162, d in mm.
    final mainBarWeightKg = (mainBarDia * mainBarDia / 162) * totalMainBarLengthM * meshCount;
    final distBarWeightKg = (distBarDia * distBarDia / 162) * totalDistBarLengthM * meshCount;
    final totalSteelWeightKg = mainBarWeightKg + distBarWeightKg;

    // --- Costs ---
    final volumeToDisplayUnit = _unit == _Unit.feet ? (1 / (0.3048 * 0.3048 * 0.3048)) : 1.0;
    final areaToDisplayUnit = _unit == _Unit.feet ? (1 / (0.3048 * 0.3048)) : 1.0;

    final steelPrice = double.tryParse(_steelPriceController.text) ?? 0;
    final cementPrice = double.tryParse(_cementPriceController.text) ?? 0;
    final sandPrice = double.tryParse(_sandPriceController.text) ?? 0;
    final aggregatePrice = double.tryParse(_aggregatePriceController.text) ?? 0;
    final labourPrice = double.tryParse(_labourPriceController.text) ?? 0;

    final steelCost = totalSteelWeightKg * steelPrice;
    final cementCost = cementBags * cementPrice;
    final sandCost = (sandVolumeM3 * volumeToDisplayUnit) * sandPrice;
    final aggregateCost = (aggregateVolumeM3 * volumeToDisplayUnit) * aggregatePrice;
    final labourCost = (lengthM * widthM * areaToDisplayUnit) * labourPrice;

    setState(() {
      _result = _SlabResult(
        concreteVolume: wetVolumeM3 * volumeToDisplayUnit,
        cementBags: cementBags,
        sandVolume: sandVolumeM3 * volumeToDisplayUnit,
        aggregateVolume: aggregateVolumeM3 * volumeToDisplayUnit,
        steelWeight: totalSteelWeightKg,
        steelCost: steelCost,
        cementCost: cementCost,
        sandCost: sandCost,
        aggregateCost: aggregateCost,
        labourCost: labourCost,
        totalCost: steelCost + cementCost + sandCost + aggregateCost + labourCost,
      );
    });
  }

  String get _volumeUnit => _unit == _Unit.feet ? 'CFT' : 'm³';
  String get _lengthUnit => _unit == _Unit.feet ? 'ft' : 'm';
  String get _thicknessUnit => _unit == _Unit.feet ? 'inch' : 'mm';
  String get _spacingUnit => _unit == _Unit.feet ? 'inch' : 'mm';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RCC Slab Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimate concrete and reinforcement steel quantity for an RCC slab.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _sectionLabel('Unit'),
            _chipRow(options: const {'Feet': _Unit.feet, 'Meter': _Unit.meter}, selected: _unit, onSelected: _unitChanged),
            const SizedBox(height: 20),
            _sectionLabel('Dimension of Slab'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_lengthController, 'Length ($_lengthUnit)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_widthController, 'Width ($_lengthUnit)')),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(_thicknessController, 'Slab Thickness ($_thicknessUnit)'),
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
            _numberField(_bagWeightController, 'Cement Bag Weight (kg)'),
            const SizedBox(height: 20),
            _sectionLabel('Space Between Two Steel Bars'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_mainBarSpacingController, 'Main Bar Spacing ($_spacingUnit)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_mainBarDiaController, 'Main Bar Dia (mm)')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_distBarSpacingController, 'Dist. Bar Spacing ($_spacingUnit)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_distBarDiaController, 'Dist. Bar Dia (mm)')),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(_meshCountController, "No's of Slab Mesh (e.g. 2 for top + bottom)"),
            const SizedBox(height: 20),
            _sectionLabel('Cost (optional)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_steelPriceController, 'Steel 1kg Price')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_cementPriceController, '1 Cement Bag Price')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_sandPriceController, 'Sand 1$_volumeUnit Price')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_aggregatePriceController, 'Aggregate 1$_volumeUnit Price')),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(_labourPriceController, 'Labour / ${_unit == _Unit.feet ? 'sq.ft' : 'sq.m'} Cost'),
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
                    _resultRow('Sand Cost', 'PKR ${_result!.sandCost.toStringAsFixed(0)}'),
                    _resultRow('Aggregate Cost', 'PKR ${_result!.aggregateCost.toStringAsFixed(0)}'),
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

class _SlabResult {
  final double concreteVolume;
  final double cementBags;
  final double sandVolume;
  final double aggregateVolume;
  final double steelWeight;
  final double steelCost;
  final double cementCost;
  final double sandCost;
  final double aggregateCost;
  final double labourCost;
  final double totalCost;

  _SlabResult({
    required this.concreteVolume,
    required this.cementBags,
    required this.sandVolume,
    required this.aggregateVolume,
    required this.steelWeight,
    required this.steelCost,
    required this.cementCost,
    required this.sandCost,
    required this.aggregateCost,
    required this.labourCost,
    required this.totalCost,
  });
}
