import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool _isOn = false;
  String? _error;

  @override
  void dispose() {
    if (_isOn) {
      TorchLight.disableTorch();
    }
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_isOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isOn = !_isOn;
        _error = null;
      });
    } on Exception {
      setState(() => _error = 'This device has no flashlight, or another app is using the camera.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isOn ? Colors.white : null,
      appBar: AppBar(
        title: const Text('Flashlight'),
        backgroundColor: _isOn ? Colors.white : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOn ? AppTheme.accentColor : AppTheme.primaryColor.withValues(alpha: 0.08),
                  boxShadow: _isOn ? [BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 4)] : null,
                ),
                child: Icon(
                  _isOn ? Icons.flashlight_on : Icons.flashlight_off,
                  size: 60,
                  color: _isOn ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(_isOn ? 'Tap to turn off' : 'Tap to turn on', style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 12.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
