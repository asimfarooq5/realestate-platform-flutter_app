import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/property_detail_screen.dart';

/// Scans QR/barcodes — a Malkiyat property share-link jumps straight to
/// that listing, anything else is shown as raw text you can copy.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  String? _lastValue;
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    setState(() {
      _lastValue = value;
      _handled = true;
    });

    final slug = _extractPropertySlug(value);
    if (slug != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailScreen(slug: slug)),
      );
    }
  }

  String? _extractPropertySlug(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    final index = segments.indexOf('properties');
    if (index != -1 && index + 1 < segments.length) {
      return segments[index + 1];
    }
    return null;
  }

  void _reset() => setState(() {
        _handled = false;
        _lastValue = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(icon: const Icon(Icons.flash_on), onPressed: () => _controller.toggleTorch()),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(16)),
            ),
          ),
          if (_lastValue != null && _extractPropertySlug(_lastValue!) == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Scanned', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(_lastValue!, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: _lastValue!));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                              }
                            },
                            child: const Text('Copy'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(onPressed: _reset, child: const Text('Scan again')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
