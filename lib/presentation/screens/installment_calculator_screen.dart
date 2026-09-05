import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// "Milkiyat Tools" — a real, functional installment/EMI calculator, since
/// "Available on Installments" is already a property listing option.
class InstallmentCalculatorScreen extends StatefulWidget {
  const InstallmentCalculatorScreen({super.key});

  @override
  State<InstallmentCalculatorScreen> createState() => _InstallmentCalculatorScreenState();
}

class _InstallmentCalculatorScreenState extends State<InstallmentCalculatorScreen> {
  final _priceController = TextEditingController();
  final _downPaymentController = TextEditingController();
  final _yearsController = TextEditingController(text: '5');
  final _rateController = TextEditingController(text: '12');

  double? _monthlyInstallment;
  double? _totalPayable;

  @override
  void dispose() {
    _priceController.dispose();
    _downPaymentController.dispose();
    _yearsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculate() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final downPayment = double.tryParse(_downPaymentController.text) ?? 0;
    final years = double.tryParse(_yearsController.text) ?? 0;
    final annualRate = double.tryParse(_rateController.text) ?? 0;

    final principal = price - downPayment;
    if (principal <= 0 || years <= 0) {
      setState(() {
        _monthlyInstallment = null;
        _totalPayable = null;
      });
      return;
    }

    final months = years * 12;
    final monthlyRate = annualRate / 100 / 12;

    double monthly;
    if (monthlyRate == 0) {
      monthly = principal / months;
    } else {
      final factor = _pow(1 + monthlyRate, months);
      monthly = principal * monthlyRate * factor / (factor - 1);
    }

    setState(() {
      _monthlyInstallment = monthly;
      _totalPayable = monthly * months + downPayment;
    });
  }

  double _pow(double base, double exponent) {
    var result = 1.0;
    final n = exponent.round();
    for (var i = 0; i < n; i++) {
      result *= base;
    }
    return result;
  }

  String _fmt(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Installment Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimate your monthly installment for a property purchase.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            _field(_priceController, 'Property Price (PKR)', 'e.g. 15,000,000'),
            const SizedBox(height: 14),
            _field(_downPaymentController, 'Down Payment (PKR)', 'e.g. 3,000,000'),
            const SizedBox(height: 14),
            _field(_yearsController, 'Payment Period (years)', 'e.g. 5'),
            const SizedBox(height: 14),
            _field(_rateController, 'Annual Interest Rate (%)', 'e.g. 12'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),
            ),
            if (_monthlyInstallment != null) ...[
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
                    const Text('Estimated Monthly Installment', style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('PKR ${_fmt(_monthlyInstallment!)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                    const SizedBox(height: 14),
                    Text('Total Payable (incl. down payment): PKR ${_fmt(_totalPayable!)}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
    );
  }
}
