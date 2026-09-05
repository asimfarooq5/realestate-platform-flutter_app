import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plus/arcore_flutter_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// A real AR-based distance measuring tool (ARCore plane detection —
/// Android only). Not a fake ruler overlay: it places two anchors in the
/// detected plane and measures the actual distance between them in world
/// space, the same approach apps like Google's Measure use.
class TapeMeasureScreen extends StatefulWidget {
  const TapeMeasureScreen({super.key});

  @override
  State<TapeMeasureScreen> createState() => _TapeMeasureScreenState();
}

class _TapeMeasureScreenState extends State<TapeMeasureScreen> {
  ArCoreController? _controller;
  ArCoreNode? _startNode;
  ArCoreNode? _endNode;
  String _status = 'Move your phone slowly to detect a surface, then tap to place the first point.';
  double? _distanceMeters;

  void _onViewCreated(ArCoreController controller) {
    _controller = controller;
    _controller?.onPlaneTap = _onPlaneTap;
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isEmpty) return;
    final hit = hits.first;

    if (_startNode == null) {
      _startNode = _mark(hit.pose.translation, Colors.orange);
      _controller?.addArCoreNode(_startNode!);
      setState(() => _status = 'First point placed. Tap the second point.');
    } else if (_endNode == null) {
      _endNode = _mark(hit.pose.translation, AppTheme.primaryColor);
      _controller?.addArCoreNode(_endNode!);
      _calculateDistance();
    }
  }

  ArCoreNode _mark(vector.Vector3 position, Color color) {
    final material = ArCoreMaterial(color: color, metallic: 0.6);
    final sphere = ArCoreSphere(materials: [material], radius: 0.02);
    return ArCoreNode(shape: sphere, position: position);
  }

  void _calculateDistance() {
    final start = _startNode?.position?.value;
    final end = _endNode?.position?.value;
    if (start == null || end == null) return;

    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final dz = end.z - start.z;
    final meters = math.sqrt(dx * dx + dy * dy + dz * dz);

    setState(() {
      _distanceMeters = meters;
      _status = 'Distance: ${meters.toStringAsFixed(2)} m (${(meters * 3.28084).toStringAsFixed(2)} ft)';
    });
  }

  void _reset() {
    if (_startNode != null) _controller?.removeNode(nodeName: _startNode!.name);
    if (_endNode != null) _controller?.removeNode(nodeName: _endNode!.name);
    setState(() {
      _startNode = null;
      _endNode = null;
      _distanceMeters = null;
      _status = 'Move your phone slowly to detect a surface, then tap to place the first point.';
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tape Measure'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _reset)],
      ),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onViewCreated,
            enableTapRecognizer: true,
            enablePlaneRenderer: true,
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _distanceMeters != null ? 20 : 14,
                  fontWeight: _distanceMeters != null ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
