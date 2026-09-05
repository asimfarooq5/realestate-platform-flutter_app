import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

const Map<String, List<String>> _checklistSections = {
  'Before You Start': [
    'Verify land ownership documents (Fard/registry)',
    'Confirm the plot is free of legal disputes',
    'Get the site levels and boundary checked',
    'Finalize the building plan with an architect',
    'Get municipal/development authority approval for the map',
  ],
  'Structure': [
    'Foundation and DPC (damp-proof course)',
    'Grey structure — columns, beams, slabs',
    'Brickwork and plastering',
    'Roof waterproofing',
    'Electrical and plumbing rough-in',
  ],
  'Finishing': [
    'Flooring (tiles/marble)',
    'Doors and windows',
    'Paint — interior and exterior',
    'Kitchen and bathroom fittings',
    'Electrical fixtures and switches',
  ],
  'Before Moving In': [
    'Utility connections (electricity, gas, water)',
    'Final structural inspection',
    'Pest control treatment',
    'Change of ownership records updated',
  ],
};

class BuildingChecklistScreen extends StatefulWidget {
  const BuildingChecklistScreen({super.key});

  @override
  State<BuildingChecklistScreen> createState() => _BuildingChecklistScreenState();
}

class _BuildingChecklistScreenState extends State<BuildingChecklistScreen> {
  static const _prefsKey = 'building_checklist_done';
  Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? [];
    if (mounted) setState(() => _done = saved.toSet());
  }

  Future<void> _toggle(String item, bool checked) async {
    setState(() {
      if (checked) {
        _done.add(item);
      } else {
        _done.remove(item);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _done.toList());
  }

  int get _totalItems => _checklistSections.values.fold(0, (sum, list) => sum + list.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Building Checklist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.checklist_rtl, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text('${_done.length} of $_totalItems completed', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
              ],
            ),
          ),
          ..._checklistSections.entries.map((section) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.hairline)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(section.key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  ...section.value.map((item) => CheckboxListTile(
                        value: _done.contains(item),
                        onChanged: (checked) => _toggle(item, checked ?? false),
                        title: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13.5,
                            decoration: _done.contains(item) ? TextDecoration.lineThrough : null,
                            color: _done.contains(item) ? AppTheme.textMuted : AppTheme.textPrimary,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppTheme.primaryColor,
                        dense: true,
                      )),
                  const SizedBox(height: 4),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
