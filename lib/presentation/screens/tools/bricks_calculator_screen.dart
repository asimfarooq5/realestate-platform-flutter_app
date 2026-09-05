import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

enum _Mode { dimension, volume, circular }
enum _Unit { feet, meter }

class BricksCalculatorScreen extends StatefulWidget {
  const BricksCalculatorScreen({super.key});

  @override
  State<BricksCalculatorScreen> createState() => _BricksCalculatorScreenState();
}

class _BricksCalculatorScreenState extends State<BricksCalculatorScreen> {
  _Mode _mode = _Mode.dimension;
  _Unit _unit = _Unit.feet;

  final _lengthController = TextEditingController();
  final _heightController = TextEditingController();
  final _thicknessController = TextEditingController(text: '9');
  final _diameterController = TextEditingController();
  final _volumeController = TextEditingController();
  final _deductionController = TextEditingController(text: '0');

  final _brickLengthController = TextEditingController(text: '9');
  final _brickWidthController = TextEditingController(text: '4.5');
  final _brickThicknessController = TextEditingController(text: '3');
  final _brickPriceController = TextEditingController(text: '0');

  final _bagWeightController = TextEditingController(text: '50');
  final _bagPriceController = TextEditingController(text: '0');
  final _wallCountController = TextEditingController(text: '1');
  final _mortarCementController = TextEditingController(text: '1');
  final _mortarSandController = TextEditingController(text: '5');

  _BrickResult? _result;

  @override
  void dispose() {
    for (final c in [
      _lengthController,
      _heightController,
      _thicknessController,
      _diameterController,
      _volumeController,
      _deductionController,
      _brickLengthController,
      _brickWidthController,
      _brickThicknessController,
      _brickPriceController,
      _bagWeightController,
      _bagPriceController,
      _wallCountController,
      _mortarCementController,
      _mortarSandController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _modeChanged(_Mode mode) => setState(() => _mode = mode);

  void _unitChanged(_Unit unit) {
    setState(() {
      if (unit == _Unit.meter && _unit == _Unit.feet) {
        _thicknessController.text = '200';
        _brickLengthController.text = '200';
        _brickWidthController.text = '100';
        _brickThicknessController.text = '100';
      } else if (unit == _Unit.feet && _unit == _Unit.meter) {
        _thicknessController.text = '9';
        _brickLengthController.text = '9';
        _brickWidthController.text = '4.5';
        _brickThicknessController.text = '3';
      }
      _unit = unit;
    });
  }

  void _calculate() {
    // Brick-with-mortar dimensions are always in inches (feet mode) or mm (meter mode).
    final brickL = double.tryParse(_brickLengthController.text) ?? 0;
    final brickW = double.tryParse(_brickWidthController.text) ?? 0;
    final brickT = double.tryParse(_brickThicknessController.text) ?? 0;
    if (brickL <= 0 || brickW <= 0 || brickT <= 0) return;

    final brickLM = _unit == _Unit.feet ? brickL * 0.0254 : brickL / 1000;
    final brickWM = _unit == _Unit.feet ? brickW * 0.0254 : brickW / 1000;
    final brickTM = _unit == _Unit.feet ? brickT * 0.0254 : brickT / 1000;
    final brickVolumeM3 = brickLM * brickWM * brickTM;

    double wetWallVolumeM3;
    final deduction = double.tryParse(_deductionController.text) ?? 0;
    final areaToM2 = _unit == _Unit.feet ? (0.3048 * 0.3048) : 1.0;
    final deductionM2 = deduction * areaToM2;

    switch (_mode) {
      case _Mode.dimension:
        final length = double.tryParse(_lengthController.text) ?? 0;
        final height = double.tryParse(_heightController.text) ?? 0;
        final thickness = double.tryParse(_thicknessController.text) ?? 0;
        if (length <= 0 || height <= 0 || thickness <= 0) return;
        final lengthM = _unit == _Unit.feet ? length * 0.3048 : length;
        final heightM = _unit == _Unit.feet ? height * 0.3048 : height;
        final thicknessM = _unit == _Unit.feet ? thickness * 0.0254 : thickness / 1000;
        final netAreaM2 = (lengthM * heightM) - deductionM2;
        wetWallVolumeM3 = netAreaM2 * thicknessM;
      case _Mode.circular:
        final diameter = double.tryParse(_diameterController.text) ?? 0;
        final height = double.tryParse(_heightController.text) ?? 0;
        final thickness = double.tryParse(_thicknessController.text) ?? 0;
        if (diameter <= 0 || height <= 0 || thickness <= 0) return;
        final diameterM = _unit == _Unit.feet ? diameter * 0.0254 : diameter / 1000;
        final heightM = _unit == _Unit.feet ? height * 0.3048 : height;
        final thicknessM = _unit == _Unit.feet ? thickness * 0.0254 : thickness / 1000;
        final circumferenceM = math.pi * diameterM;
        final netAreaM2 = (circumferenceM * heightM) - deductionM2;
        wetWallVolumeM3 = netAreaM2 * thicknessM;
      case _Mode.volume:
        final volume = double.tryParse(_volumeController.text) ?? 0;
        if (volume <= 0) return;
        wetWallVolumeM3 = _unit == _Unit.feet ? volume * math.pow(0.3048, 3).toDouble() : volume;
    }

    if (wetWallVolumeM3 <= 0) return;

    final numberOfBricks = wetWallVolumeM3 / brickVolumeM3;

    // The brick dimensions already include the mortar joint, so mortar is
    // the leftover space once the bricks' own (unjointed) volume is
    // removed — approximated at the standard 30% of brickwork volume used
    // when only the with-mortar brick size is known.
    final wetMortarVolumeM3 = wetWallVolumeM3 * 0.30;
    final dryMortarVolumeM3 = wetMortarVolumeM3 * 1.30;

    final cementRatio = double.tryParse(_mortarCementController.text) ?? 1;
    final sandRatio = double.tryParse(_mortarSandController.text) ?? 5;
    final totalRatio = cementRatio + sandRatio;
    if (totalRatio <= 0) return;

    final cementVolumeM3 = dryMortarVolumeM3 * (cementRatio / totalRatio);
    final sandVolumeM3 = dryMortarVolumeM3 * (sandRatio / totalRatio);

    const cementDensityKgPerM3 = 1440.0;
    final cementWeightKg = cementVolumeM3 * cementDensityKgPerM3;
    final bagWeight = double.tryParse(_bagWeightController.text) ?? 50;
    final cementBagsPerWall = bagWeight > 0 ? cementWeightKg / bagWeight : 0.0;

    final wallCount = double.tryParse(_wallCountController.text) ?? 1;
    final bagPrice = double.tryParse(_bagPriceController.text) ?? 0;
    final brickPrice = double.tryParse(_brickPriceController.text) ?? 0;

    final volumeToDisplayUnit = _unit == _Unit.feet ? (1 / math.pow(0.3048, 3)).toDouble() : 1.0;

    final totalVolume = wetWallVolumeM3 * wallCount * volumeToDisplayUnit;
    final totalBricks = numberOfBricks * wallCount;
    final totalCementBags = cementBagsPerWall * wallCount;
    final totalSand = sandVolumeM3 * wallCount * volumeToDisplayUnit;

    setState(() {
      _result = _BrickResult(
        totalVolume: totalVolume,
        brickCost: totalBricks * brickPrice,
        cementBags: totalCementBags,
        cementCost: totalCementBags * bagPrice,
        sandVolume: totalSand,
        numberOfBricks: totalBricks,
      );
    });
  }

  String get _volumeUnit => _unit == _Unit.feet ? 'CFT' : 'm³';
  String get _lengthUnit => _unit == _Unit.feet ? 'ft' : 'm';
  String get _thicknessUnit => _unit == _Unit.feet ? 'inch' : 'mm';
  String get _brickUnit => _unit == _Unit.feet ? 'inch' : 'mm';
  String get _areaUnit => _unit == _Unit.feet ? 'sq.ft' : 'sq.m';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bricks Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calculate the number of bricks, cement, and sand needed for a wall.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _sectionLabel('Mode'),
            _chipRow(options: const {'By Dimension': _Mode.dimension, 'By Volume': _Mode.volume, 'Circular Wall': _Mode.circular}, selected: _mode, onSelected: _modeChanged),
            const SizedBox(height: 12),
            _sectionLabel('Unit'),
            _chipRow(options: const {'Feet': _Unit.feet, 'Meter': _Unit.meter}, selected: _unit, onSelected: _unitChanged),
            const SizedBox(height: 20),
            if (_mode == _Mode.dimension) ...[
              _sectionLabel('Dimension of Wall'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _numberField(_lengthController, 'Length ($_lengthUnit)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(_heightController, 'Height ($_lengthUnit)')),
                ],
              ),
              const SizedBox(height: 12),
              _numberField(_thicknessController, 'Thickness ($_thicknessUnit)'),
              const SizedBox(height: 12),
              _numberField(_deductionController, 'Subtract Window/Door Area ($_areaUnit)'),
            ] else if (_mode == _Mode.circular) ...[
              _sectionLabel('Dimension of Circular Wall'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _numberField(_diameterController, 'Diameter ($_brickUnit)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(_heightController, 'Height ($_lengthUnit)')),
                ],
              ),
              const SizedBox(height: 12),
              _numberField(_thicknessController, 'Thickness ($_thicknessUnit)'),
              const SizedBox(height: 12),
              _numberField(_deductionController, 'Subtract Window/Door Area ($_areaUnit)'),
            ] else ...[
              _sectionLabel('Wall Volume'),
              const SizedBox(height: 8),
              _numberField(_volumeController, 'Volume ($_volumeUnit)'),
            ],
            const SizedBox(height: 20),
            _sectionLabel('Dimension of Brick With Mortar'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_brickLengthController, 'Length ($_brickUnit)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_brickWidthController, 'Width ($_brickUnit)')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_brickThicknessController, 'Thickness ($_brickUnit)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_brickPriceController, '1 Brick Price')),
              ],
            ),
            const SizedBox(height: 20),
            _sectionLabel('Mortar Ratio (Cement : Sand)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numberField(_mortarCementController, 'Cement')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_mortarSandController, 'Sand')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_bagWeightController, '1 Cement Bag (kg)')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_wallCountController, 'No. of Walls')),
              ],
            ),
            const SizedBox(height: 12),
            _numberField(_bagPriceController, '1 Cement Bag Price'),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculate, child: const Text('Calculate'))),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _resultRow('Total Volume', '${_result!.totalVolume.toStringAsFixed(3)} $_volumeUnit'),
                    _resultRow('Brick Cost', 'PKR ${_result!.brickCost.toStringAsFixed(0)}'),
                    _resultRow('Cement Bags', _result!.cementBags.toStringAsFixed(2)),
                    _resultRow('Cement Cost', 'PKR ${_result!.cementCost.toStringAsFixed(0)}'),
                    _resultRow('Sand', '${_result!.sandVolume.toStringAsFixed(3)} $_volumeUnit'),
                    _resultRow('Number of Bricks', _result!.numberOfBricks.toStringAsFixed(0), isLast: true),
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
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }
}

class _BrickResult {
  final double totalVolume;
  final double brickCost;
  final double cementBags;
  final double cementCost;
  final double sandVolume;
  final double numberOfBricks;

  _BrickResult({
    required this.totalVolume,
    required this.brickCost,
    required this.cementBags,
    required this.cementCost,
    required this.sandVolume,
    required this.numberOfBricks,
  });
}
