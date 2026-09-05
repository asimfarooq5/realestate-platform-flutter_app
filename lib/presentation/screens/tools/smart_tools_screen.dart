import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/tools/flashlight_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/level_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/qr_scanner_screen.dart';
import 'package:malkiyat_app/presentation/screens/tools/tape_measure_screen.dart';

class SmartToolsScreen extends StatelessWidget {
  const SmartToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      (icon: Icons.architecture_outlined, title: 'Level', subtitle: 'Check if a surface is flat', screen: const LevelScreen()),
      (icon: Icons.straighten_outlined, title: 'Tape Measure', subtitle: 'Measure real-world distance using AR', screen: const TapeMeasureScreen()),
      (icon: Icons.flashlight_on_outlined, title: 'Flashlight', subtitle: 'Turn on the camera flash', screen: const FlashlightScreen()),
      (icon: Icons.qr_code_scanner_outlined, title: 'QR Scanner', subtitle: 'Scan property QR codes or barcodes', screen: const QrScannerScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Tools')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.95),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => tool.screen)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.hairline)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                    child: Icon(tool.icon, color: AppTheme.primaryColor, size: 26),
                  ),
                  const Spacer(),
                  Text(tool.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(tool.subtitle, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
