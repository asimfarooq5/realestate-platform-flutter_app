import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/constants/property_taxonomy.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

/// Step 2 of posting a listing — detailed feature groups (main features,
/// rooms, nearby facilities, community facilities, other). Returns the
/// collected map via Navigator.pop when the caller saves/continues.
class PropertyFeaturesScreen extends StatefulWidget {
  final Map<String, dynamic>? initial;

  const PropertyFeaturesScreen({super.key, this.initial});

  @override
  State<PropertyFeaturesScreen> createState() => _PropertyFeaturesScreenState();
}

class _PropertyFeaturesScreenState extends State<PropertyFeaturesScreen> {
  final Set<String> _mainFeatures = {};
  final Set<String> _rooms = {};
  final Set<String> _nearby = {};
  final Set<String> _community = {};
  final _constructedYearController = TextEditingController();
  final _parkingSpacesController = TextEditingController();
  final _floorsController = TextEditingController();
  final _airportDistanceController = TextEditingController();
  final _otherMainController = TextEditingController();
  final _otherRoomsController = TextEditingController();
  final _otherNearbyController = TextEditingController();
  final _otherCommunityController = TextEditingController();
  final _otherFacilitiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      final main = initial['main_features'] as Map<String, dynamic>?;
      if (main != null) {
        _mainFeatures.addAll((main['selected'] as List?)?.cast<String>() ?? []);
        _constructedYearController.text = main['constructed_year']?.toString() ?? '';
        _parkingSpacesController.text = main['parking_spaces']?.toString() ?? '';
        _floorsController.text = main['floors']?.toString() ?? '';
        _otherMainController.text = main['other'] ?? '';
      }
      final rooms = initial['rooms'] as Map<String, dynamic>?;
      if (rooms != null) {
        _rooms.addAll((rooms['selected'] as List?)?.cast<String>() ?? []);
        _otherRoomsController.text = rooms['other'] ?? '';
      }
      final nearby = initial['nearby'] as Map<String, dynamic>?;
      if (nearby != null) {
        _nearby.addAll((nearby['selected'] as List?)?.cast<String>() ?? []);
        _airportDistanceController.text = nearby['distance_from_airport_km']?.toString() ?? '';
        _otherNearbyController.text = nearby['other'] ?? '';
      }
      final community = initial['community'] as Map<String, dynamic>?;
      if (community != null) {
        _community.addAll((community['selected'] as List?)?.cast<String>() ?? []);
        _otherCommunityController.text = community['other'] ?? '';
      }
      _otherFacilitiesController.text = initial['other_facilities'] ?? '';
    }
  }

  @override
  void dispose() {
    _constructedYearController.dispose();
    _parkingSpacesController.dispose();
    _floorsController.dispose();
    _airportDistanceController.dispose();
    _otherMainController.dispose();
    _otherRoomsController.dispose();
    _otherNearbyController.dispose();
    _otherCommunityController.dispose();
    _otherFacilitiesController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collect() {
    return {
      'main_features': {
        'selected': _mainFeatures.toList(),
        if (_constructedYearController.text.isNotEmpty) 'constructed_year': int.tryParse(_constructedYearController.text),
        if (_parkingSpacesController.text.isNotEmpty) 'parking_spaces': int.tryParse(_parkingSpacesController.text),
        if (_floorsController.text.isNotEmpty) 'floors': int.tryParse(_floorsController.text),
        if (_otherMainController.text.isNotEmpty) 'other': _otherMainController.text,
      },
      'rooms': {
        'selected': _rooms.toList(),
        if (_otherRoomsController.text.isNotEmpty) 'other': _otherRoomsController.text,
      },
      'nearby': {
        'selected': _nearby.toList(),
        if (_airportDistanceController.text.isNotEmpty) 'distance_from_airport_km': double.tryParse(_airportDistanceController.text),
        if (_otherNearbyController.text.isNotEmpty) 'other': _otherNearbyController.text,
      },
      'community': {
        'selected': _community.toList(),
        if (_otherCommunityController.text.isNotEmpty) 'other': _otherCommunityController.text,
      },
      if (_otherFacilitiesController.text.isNotEmpty) 'other_facilities': _otherFacilitiesController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Features')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Main Features'),
          _chipGroup(mainFeatureOptions, _mainFeatures),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _numberField(_constructedYearController, 'Constructed Year')),
              const SizedBox(width: 10),
              Expanded(child: _numberField(_parkingSpacesController, 'Parking Spaces')),
              const SizedBox(width: 10),
              Expanded(child: _numberField(_floorsController, 'Floors')),
            ],
          ),
          const SizedBox(height: 10),
          _otherField(_otherMainController, 'Other main features'),

          const SizedBox(height: 24),
          _sectionTitle('Rooms'),
          _chipGroup(roomOptions, _rooms),
          const SizedBox(height: 10),
          _otherField(_otherRoomsController, 'Other rooms'),

          const SizedBox(height: 24),
          _sectionTitle('Nearby Locations & Facilities'),
          _chipGroup(nearbyOptions, _nearby),
          const SizedBox(height: 10),
          _numberField(_airportDistanceController, 'Distance from Airport (km)'),
          const SizedBox(height: 10),
          _otherField(_otherNearbyController, 'Other nearby places'),

          const SizedBox(height: 24),
          _sectionTitle('Community Features'),
          _chipGroup(communityOptions, _community),
          const SizedBox(height: 10),
          _otherField(_otherCommunityController, 'Other community facilities'),

          const SizedBox(height: 24),
          _sectionTitle('Other Facilities'),
          _otherField(_otherFacilitiesController, 'Anything else worth mentioning'),

          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _collect()),
            child: const Text('Save Features'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
    );
  }

  Widget _chipGroup(List<String> options, Set<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option, style: const TextStyle(fontSize: 12.5)),
          selected: isSelected,
          onSelected: (value) => setState(() => value ? selected.add(option) : selected.remove(option)),
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          checkmarkColor: AppTheme.primaryColor,
        );
      }).toList(),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, isDense: true),
    );
  }

  Widget _otherField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, isDense: true),
    );
  }
}
