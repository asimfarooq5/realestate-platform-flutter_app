import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

enum _Unit { feet, meter }

class BeamCalculatorScreen extends StatefulWidget {
  const BeamCalculatorScreen({super.key});

  @override
  State<BeamCalculatorScreen> createState() => _BeamCalculatorScreenState();
}

class _BeamCalculatorScreenState extends State<BeamCalculatorScreen> {
  _Unit _unit = _Unit.feet;

  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _lengthController = TextEditingController();

  final _longBarCountController = TextEditingController(text: '4');
  final _longBarDiaController = TextEditingController(text: '16');
  final _stirrupDiaController = TextEditingController(text: '8');
  final _stirrupSpacingController = TextEditingController(text: '6');

  final _cementRatioController = TextEditingController(text: '1');
  final _sandRatioController = TextEditingController(text: '2');
  final _aggregateRatioController = TextEditingController(text: '4');
  final _bagWeightController = TextEditingController(text: '50');
  final _bagPriceController = TextEditingController(text: '0');
  final _beamCountController = TextEditingController(text: '1');
  final _labourPriceController = TextEditingController(text: '0');
  final _steelPriceController = TextEditingController(text: '0');

  _BeamResult? _result;

  @override
  void dispose() {
    for (final c in [
      _widthController,
      _heightController,
      _lengthController,
      _longBarCountController,
      _longBarDiaController,
      _stirrupDiaController,
      _stirrupSpacingController,
      _cementRatioController,
      _sandRatioController,
      _aggregateRatioController,
      _bagWeightController,
      _bagPriceController,
      _beamCountController,
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
        _stirrupSpacingController.text = '150';
      } else if (unit == _Unit.feet && _unit == _Unit.meter) {
        _stirrupSpacingController.text = '6';
      }
      _unit = unit;
    });
  }

  void _calculate() {
    final widthRaw = double.tryParse(_widthController.text) ?? 0;
    final heightRaw = double.tryParse(_heightController.text) ?? 0;
    final lengthRaw = double.tryParse(_lengthController.text) ?? 0;
    if (widthRaw <= 0 || heightRaw <= 0 || lengthRaw <= 0) return;

    // Normalize to meters/mm: Feet mode has W/H in inches and L in feet;
    // Meter mode has W/H in cm and L in meters.
    final widthM = _unit == _Unit.feet ? widthRaw * 0.0254 : widthRaw / 100;
    final heightM = _unit == _Unit.feet ? heightRaw * 0.0254 : heightRaw / 100;
    final lengthM = _unit == _Unit.feet ? lengthRaw * 0.3048 : lengthRaw;

    final stirrupSpacingRaw = double.tryParse(_stirrupSpacingController.text) ?? 6;
    final stirrupSpacingM = _unit == _Unit.feet ? (stirrupSpacingRaw * 25.4) / 1000 : stirrupSpacingRaw / 1000;

    final cementRatio = double.tryParse(_cementRatioController.text) ?? 1;
    final sandRatio = double.tryParse(_sandRatioController.text) ?? 2;
    final aggregateRatio = double.tryParse(_aggregateRatioController.text) ?? 4;
    final totalRatio = cementRatio + sandRatio + aggregateRatio;
    if (totalRatio <= 0) return;

    final beamCount = double.tryParse(_beamCountController.text) ?? 1;

    // --- Concrete quantity (per beam) ---
    final wetVolumeM3 = widthM * heightM * lengthM;
    final dryVolumeM3 = wetVolumeM3 * 1.54;
    final cementVolumeM3 = dryVolumeM3 * (cementRatio / totalRatio);
    final sandVolumeM3 = dryVolumeM3 * (sandRatio / totalRatio);
    final aggregateVolumeM3 = dryVolumeM3 * (aggregateRatio / totalRatio);

    const cementDensityKgPerM3 = 1440.0;
    final cementWeightKg = cementVolumeM3 * cementDensityKgPerM3;
    final bagWeight = double.tryParse(_bagWeightController.text) ?? 50;
    final cementBagsPerBeam = bagWeight > 0 ? cementWeightKg / bagWeight : 0.0;

    // --- Steel: longitudinal bars (full length) + stirrups (wrapped at spacing) ---
    final longBarCount = double.tryParse(_longBarCountController.text) ?? 4;
    final longBarDia = double.tryParse(_longBarDiaController.text) ?? 16;
    final stirrupDia = double.tryParse(_stirrupDiaController.text) ?? 8;

    final longitudinalWeightPerBeam = (longBarDia * longBarDia / 162) * (longBarCount * lengthM);

    final perimeterM = 2 * (widthM + heightM);
    final stirrupCount = (lengthM / stirrupSpacingM).floor() + 1;
    final stirrupWeightPerBeam = (stirrupDia * stirrupDia / 162) * (stirrupCount * perimeterM);

    final steelWeightPerBeam = longitudinalWeightPerBeam + stirrupWeightPerBeam;

    // --- Totals across all beams ---
    final volumeToDisplayUnit = _unit == _Unit.feet ? (1 / (0.3048 * 0.3048 * 0.3048)) : 1.0;
    final bagPrice = double.tryParse(_bagPriceController.text) ?? 0;
    final labourPrice = double.tryParse(_labourPriceController.text) ?? 0;
    final steelPrice = double.tryParse(_steelPriceController.text) ?? 0;

    final totalConcreteVolume = wetVolumeM3 * beamCount * volumeToDisplayUnit;
    final totalCementBags = cementBagsPerBeam * beamCount;
    final totalSandVolume = sandVolumeM3 * beamCount * volumeToDisplayUnit;
    final totalAggregateVolume = aggregateVolumeM3 * beamCount * volumeToDisplayUnit;
    final totalSteelWeight = steelWeightPerBeam * beamCount;
    final totalLongitudinalWeight = longitudinalWeightPerBeam * beamCount;
    final totalStirrupWeight = stirrupWeightPerBeam * beamCount;

    setState(() {
      _result = _BeamResult(
        concreteVolume: totalConcreteVolume,
        labourCost: totalConcreteVolume * labourPrice,
        cementBags: totalCementBags,
        cementCost: totalCementBags * bagPrice,
        sandVolume: totalSandVolume,
        aggregateVolume: totalAggregateVolume,
        totalSteelWeight: totalSteelWeight,
        steelCost: totalSteelWeight * steelPrice,
        longitudinalWeight: totalLongitudinalWeight,
        stirrupWeight: totalStirrupWeight,
        longitudinalBarCount: (longBarCount * beamCount).round(),
        stirrupCount: (stirrupCount * beamCount).round(),
        barLengthOnePiece: lengthM * (_unit == _Unit.feet ? 3.28084 : 1),
        stirrupLengthOnePiece: perimeterM * (_unit == _Unit.feet ? 3.28084 : 1),
      );
    });
  }

  String get _volumeUnit => _unit == _Unit.feet ? 'CFT' : 'm³';
  String get _lateralUnit => _unit == _Unit.feet ? 'inch' : 'cm';
  String get _lengthUnit => _unit == _Unit.feet ? 'ft' : 'm';
  String get _spacingUnit => _unit == _Unit.feet ? 'inch' : 'mm';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beam Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimate concrete and reinforcement steel quantity for RCC beams.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _sectionLabel('Unit'),
            _chipRow(options: const {'Feet': _Unit.feet, 'Meter': _Unit.meter}, selected: _unit, onSelected: _unitChanged),
            const SizedBox(height: 20),
            _sectionLabel('Dimension of Beam'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_widthController, 'Width ($_lateralUnit)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_heightController, 'Height ($_lateralUnit)')),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(_lengthController, 'Length ($_lengthUnit)'),
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
                Expanded(child: _numberField(_stirrupDiaController, 'Stirrups Dia (mm)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_stirrupSpacingController, 'Stirrups Spacing ($_spacingUnit)')),
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
                Expanded(child: _numberField(_beamCountController, 'Number of Beams')),
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
              _sectionLabel('Concrete Results'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _resultRow('Concrete Volume', '${_result!.concreteVolume.toStringAsFixed(3)} $_volumeUnit'),
                    _resultRow('Labour Cost', 'PKR ${_result!.labourCost.toStringAsFixed(0)}'),
                    _resultRow('Cement Bags', _result!.cementBags.toStringAsFixed(2)),
                    _resultRow('Cement Cost', 'PKR ${_result!.cementCost.toStringAsFixed(0)}'),
                    _resultRow('Sand', '${_result!.sandVolume.toStringAsFixed(3)} $_volumeUnit'),
                    _resultRow('Aggregate', '${_result!.aggregateVolume.toStringAsFixed(3)} $_volumeUnit', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Steel Results'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _resultRow('Total Steel Weight', '${_result!.totalSteelWeight.toStringAsFixed(2)} kg'),
                    _resultRow('Total Steel Ton', '${(_result!.totalSteelWeight / 1000).toStringAsFixed(4)} ton'),
                    _resultRow('Steel Cost', 'PKR ${_result!.steelCost.toStringAsFixed(0)}'),
                    _resultRow('Weight of Longitudinal Bars', '${_result!.longitudinalWeight.toStringAsFixed(2)} kg'),
                    _resultRow('Weight of Stirrups', '${_result!.stirrupWeight.toStringAsFixed(2)} kg'),
                    _resultRow('No. of Longitudinal Bars', '${_result!.longitudinalBarCount} pieces'),
                    _resultRow('No. of Stirrups', '${_result!.stirrupCount} pieces'),
                    _resultRow('Bar Length (1 Pc)', '${_result!.barLengthOnePiece.toStringAsFixed(2)} $_lengthUnit'),
                    _resultRow('Stirrup Length (1 Pc)', '${_result!.stirrupLengthOnePiece.toStringAsFixed(2)} $_lengthUnit', isLast: true),
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

  Widget _resultRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }
}

class _BeamResult {
  final double concreteVolume;
  final double labourCost;
  final double cementBags;
  final double cementCost;
  final double sandVolume;
  final double aggregateVolume;
  final double totalSteelWeight;
  final double steelCost;
  final double longitudinalWeight;
  final double stirrupWeight;
  final int longitudinalBarCount;
  final int stirrupCount;
  final double barLengthOnePiece;
  final double stirrupLengthOnePiece;

  _BeamResult({
    required this.concreteVolume,
    required this.labourCost,
    required this.cementBags,
    required this.cementCost,
    required this.sandVolume,
    required this.aggregateVolume,
    required this.totalSteelWeight,
    required this.steelCost,
    required this.longitudinalWeight,
    required this.stirrupWeight,
    required this.longitudinalBarCount,
    required this.stirrupCount,
    required this.barLengthOnePiece,
    required this.stirrupLengthOnePiece,
  });
}
