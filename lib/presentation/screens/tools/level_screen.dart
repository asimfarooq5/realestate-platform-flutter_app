import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// A bubble/spirit level using the device accelerometer — for checking if
/// a surface (floor, shelf, frame) is flat during construction/inspection.
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  double _x = 0;
  double _y = 0;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        // Low-pass smoothing so the bubble doesn't jitter.
        _x = _x * 0.8 + event.x * 0.2;
        _y = _y * 0.8 + event.y * 0.2;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiltX = (_x / 9.8).clamp(-1.0, 1.0);
    final tiltY = (_y / 9.8).clamp(-1.0, 1.0);
    final isFlat = _x.abs() < 0.15 && _y.abs() < 0.15;
    final angleDegrees = math.sqrt(_x * _x + _y * _y) / 9.8 * 90;

    return Scaffold(
      appBar: AppBar(title: const Text('Level')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.hairline, width: 2),
                      color: Colors.white,
                    ),
                  ),
                  Container(width: 2, height: 260, color: AppTheme.hairline),
                  Container(width: 260, height: 2, color: AppTheme.hairline),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.border, width: 1.5)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    transform: Matrix4.translationValues(tiltX * 90, tiltY * 90, 0),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isFlat ? Colors.green : AppTheme.accentColor).withValues(alpha: 0.85),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isFlat ? 'Level' : '${angleDegrees.toStringAsFixed(1)}° off',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isFlat ? Colors.green : AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text('Lay the phone flat on the surface you want to check.', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
