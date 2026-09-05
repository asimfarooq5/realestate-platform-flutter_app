import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/widgets/property_card.dart';
import 'package:malkiyat_app/presentation/widgets/loading_shimmer.dart';

/// Listings posted by verified agents / Malkiyat's own team (backend
/// `agency_only` filter) — a real distinction from ordinary owner-posted
/// listings, not a relabeled duplicate of Featured Properties.
class MarketedByMalkiyatSection extends StatefulWidget {
  const MarketedByMalkiyatSection({super.key});

  @override
  State<MarketedByMalkiyatSection> createState() => _MarketedByMalkiyatSectionState();
}

class _MarketedByMalkiyatSectionState extends State<MarketedByMalkiyatSection> {
  final PropertyBloc _bloc = sl<PropertyBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(const LoadProperties(agencyOnly: true, limit: 6));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is PropertyLoading) {
          return SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 280, child: PropertyCardShimmer()),
              ),
            ),
          );
        }
        // No agency-posted listings yet — hide the section rather than
        // showing an empty/awkward placeholder.
        if (state is! PropertiesLoaded || state.properties.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.verified, size: 18, color: AppTheme.accentColor),
                  const SizedBox(width: 6),
                  const Text(
                    'Marketed by Malkiyat',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 320,
              child: ListView.builder(
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
              ),
            ),
          ],
        );
      },
    );
  }
}
