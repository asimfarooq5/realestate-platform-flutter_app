import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/property_detail_screen.dart';
import 'package:malkiyat_app/presentation/widgets/property_card.dart';
import 'package:malkiyat_app/presentation/widgets/app_search_bar.dart';

enum _Purpose { all, rent, buy }

/// Map-first property browser — search bar, purpose/city filters, and a
/// list/map toggle, mirroring ZippeeHomes' Explore tab. No auth required;
/// this is a browsing screen like Home.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PropertyBloc _bloc = sl<PropertyBloc>();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  bool _showMap = true;
  _Purpose _purpose = _Purpose.all;
  String? _cityId;
  String? _cityName;

  // Roughly centers Pakistan.
  static const _initialCenter = LatLng(30.3753, 69.3451);

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadCities());
    _runSearch();
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _runSearch() {
    _bloc.add(LoadProperties(
      limit: 50,
      cityId: _cityId,
      status: switch (_purpose) {
        _Purpose.all => null,
        _Purpose.rent => 'FOR_RENT',
        _Purpose.buy => 'FOR_SALE',
      },
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 10),
            _buildPurposeToggle(),
            const SizedBox(height: 10),
            _buildFilterRow(),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<PropertyBloc, PropertyState>(
                bloc: _bloc,
                builder: (context, state) {
                  final properties = state is PropertiesLoaded ? state.properties : const <Property>[];
                  final total = state is PropertiesLoaded ? state.total : properties.length;

                  if (_showMap) {
                    return _buildMap(properties, total, state is PropertyLoading);
                  }
                  return _buildList(properties, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          Expanded(
            child: AppSearchBar(
              controller: _searchController,
              hint: 'City, area, or keyword',
              onSubmitted: _runSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: _Purpose.values.map((p) {
            final selected = p == _purpose;
            final label = switch (p) {
              _Purpose.all => 'All',
              _Purpose.rent => 'Rent',
              _Purpose.buy => 'Buy',
            };
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _purpose = p);
                  _runSearch();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<PropertyBloc, PropertyState>(
              bloc: _bloc,
              buildWhen: (previous, current) => current is CitiesLoaded,
              builder: (context, state) {
                final cities = state is CitiesLoaded ? state.cities : const <City>[];
                return GestureDetector(
                  onTap: () => _pickCity(cities),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border, width: 1.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(_cityName ?? 'Pakistan', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          _toggleButton(
            icon: _showMap ? Icons.view_list_rounded : Icons.map_outlined,
            label: _showMap ? 'List' : 'Map',
            onTap: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border, width: 1.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.navy),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCity(List<City> cities) async {
    final selected = await showModalBottomSheet<City?>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All of Pakistan'),
              onTap: () => Navigator.pop(context, null),
            ),
            ...cities.map((city) => ListTile(
                  title: Text(city.name),
                  onTap: () => Navigator.pop(context, city),
                )),
          ],
        ),
      ),
    );
    setState(() {
      _cityId = selected?.id;
      _cityName = selected?.name;
    });
    _runSearch();
  }

  Widget _buildMap(List<Property> properties, int total, bool loading) {
    final withCoords = properties.where((p) => p.latitude != null && p.longitude != null).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 5.2,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.malkiyat.app',
            ),
            MarkerLayer(
              markers: withCoords.map((property) {
                return Marker(
                  point: LatLng(property.latitude!, property.longitude!),
                  width: 100,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PropertyDetailScreen(slug: property.slug)),
                    ),
                    child: _PriceBubble(property: property),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        if (!loading)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(999)),
              child: Text(
                '$total properties',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          right: 12,
          child: Column(
            children: [
              _zoomButton(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
              const SizedBox(height: 8),
              _zoomButton(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
            ],
          ),
        ),
        if (loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppTheme.navy.withValues(alpha: 0.15), blurRadius: 8)],
        ),
        child: Icon(icon, color: AppTheme.navy),
      ),
    );
  }

  Widget _buildList(List<Property> properties, PropertyState state) {
    if (state is PropertyLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (properties.isEmpty) {
      return const Center(
        child: Text('No properties found', style: TextStyle(color: AppTheme.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: properties.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: PropertyCard(property: properties[index]),
      ),
    );
  }
}

class _PriceBubble extends StatelessWidget {
  final Property property;

  const _PriceBubble({required this.property});

  String _shortPrice(double price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final suffix = property.status == 'FOR_RENT' ? '/mo' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: AppTheme.navy.withValues(alpha: 0.3), blurRadius: 6)],
      ),
      child: Text(
        '${_shortPrice(property.price)}$suffix',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
