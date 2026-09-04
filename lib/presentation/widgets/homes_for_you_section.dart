import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/property_list_screen.dart';
import 'package:malkiyat_app/presentation/widgets/horizontal_property_card.dart';
import 'package:malkiyat_app/presentation/widgets/loading_shimmer.dart';

enum _QuickFilter {
  all(label: 'All Homes', icon: Icons.home_outlined),
  rent(label: 'For Rent', icon: Icons.vpn_key_outlined),
  sale(label: 'For Sale', icon: Icons.sell_outlined),
  land(label: 'Land', icon: Icons.straighten_outlined),
  commercial(label: 'Commercial', icon: Icons.business_center_outlined);

  final String label;
  final IconData icon;
  const _QuickFilter({required this.label, required this.icon});
}

enum _SortOption { newest, priceLow, priceHigh }

/// The home screen's main content: popular-search shortcuts, quick
/// category filters, and a "Homes for you" list — mirrors ZippeeHomes'
/// Real Estate landing screen (popular searches pills, All Homes/For
/// Rent/For Sale/Land/Commercial chips, sortable results list).
class HomesForYouSection extends StatefulWidget {
  const HomesForYouSection({super.key});

  @override
  State<HomesForYouSection> createState() => _HomesForYouSectionState();
}

class _HomesForYouSectionState extends State<HomesForYouSection> {
  final PropertyBloc _bloc = sl<PropertyBloc>();
  _QuickFilter _filter = _QuickFilter.all;
  _SortOption _sort = _SortOption.newest;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadCities());
    _load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _load({bool loadMore = false}) {
    if (!loadMore) {
      _page = 1;
    }
    _bloc.add(LoadProperties(
      page: _page,
      limit: 8,
      status: switch (_filter) {
        _QuickFilter.rent => 'FOR_RENT',
        _QuickFilter.sale => 'FOR_SALE',
        _ => null,
      },
      type: switch (_filter) {
        _QuickFilter.land => 'PLOT',
        _QuickFilter.commercial => 'COMMERCIAL',
        _ => null,
      },
    ));
  }

  List<Property> _sorted(List<Property> properties) {
    final list = [...properties];
    switch (_sort) {
      case _SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case _SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPopularSearches(),
        const SizedBox(height: 16),
        _buildQuickFilters(),
        const SizedBox(height: 16),
        _buildHeaderRow(),
        const SizedBox(height: 12),
        _buildList(),
      ],
    );
  }

  Widget _buildPopularSearches() {
    return BlocBuilder<PropertyBloc, PropertyState>(
      bloc: _bloc,
      buildWhen: (previous, current) => current is CitiesLoaded,
      builder: (context, state) {
        final cities = state is CitiesLoaded ? state.cities : const <City>[];
        if (cities.isEmpty) return const SizedBox.shrink();
        final popular = cities.take(6).toList();
        return SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: popular.length,
            itemBuilder: (context, index) {
              final city = popular[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyListScreen(title: city.name, cityId: city.id),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(city.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickFilters() {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _QuickFilter.values.length,
        itemBuilder: (context, index) {
          final filter = _QuickFilter.values[index];
          final selected = filter == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() => _filter = filter);
                _load();
              },
              child: Container(
                width: 84,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.accentColor.withValues(alpha: 0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? AppTheme.accentColor : AppTheme.hairline, width: selected ? 1.5 : 1),
                ),
                child: Column(
                  children: [
                    Icon(filter.icon, size: 22, color: selected ? AppTheme.accentColor : AppTheme.navy),
                    const SizedBox(height: 6),
                    Text(
                      filter.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppTheme.accentColor : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Homes for you',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: AppTheme.textPrimary),
              ),
            ],
          ),
          PopupMenuButton<_SortOption>(
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(999)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sort', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: _SortOption.newest, child: Text('Newest')),
              PopupMenuItem(value: _SortOption.priceLow, child: Text('Price: Low to High')),
              PopupMenuItem(value: _SortOption.priceHigh, child: Text('Price: High to Low')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<PropertyBloc, PropertyState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is PropertyLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [PropertyCardShimmer(), SizedBox(height: 12), PropertyCardShimmer()]),
          );
        }
        if (state is PropertiesLoaded) {
          final sorted = _sorted(state.properties);
          if (sorted.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(child: Text('No homes match this filter yet', style: TextStyle(color: AppTheme.textMuted))),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Showing ${sorted.length} of ${state.total} homes',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                ...sorted.map((property) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HorizontalPropertyCard(property: property),
                    )),
                if (state.page < state.pages)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: OutlinedButton(
                      onPressed: () {
                        _page += 1;
                        _load(loadMore: true);
                      },
                      child: const Text('Load more homes'),
                    ),
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
