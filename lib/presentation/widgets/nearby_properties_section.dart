import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/services/location_service.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/widgets/property_card.dart';
import 'package:malkiyat_app/presentation/widgets/loading_shimmer.dart';

/// Nearby listings, sorted by distance from the device's current location.
/// Requests location permission on first mount; if the user denies it (or
/// location is off), the section just doesn't render — the rest of the
/// home screen is unaffected.
class NearbyPropertiesSection extends StatefulWidget {
  const NearbyPropertiesSection({super.key});

  @override
  State<NearbyPropertiesSection> createState() => _NearbyPropertiesSectionState();
}

class _NearbyPropertiesSectionState extends State<NearbyPropertiesSection> {
  final PropertyBloc _bloc = sl<PropertyBloc>();
  final LocationService _locationService = sl<LocationService>();
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _loadNearby() async {
    final position = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (position == null) {
      setState(() => _permissionDenied = true);
      return;
    }
    _bloc.add(LoadProperties(
      limit: 6,
      nearLat: position.latitude,
      nearLng: position.longitude,
    ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Near You',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 320,
          child: BlocBuilder<PropertyBloc, PropertyState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is PropertyLoading || state is PropertyInitial) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(width: 280, child: PropertyCardShimmer()),
                    );
                  },
                );
              }

              if (state is PropertiesLoaded) {
                if (state.properties.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.properties.length,
                  itemBuilder: (context, index) {
                    final property = state.properties[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(width: 280, child: PropertyCard(property: property)),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
