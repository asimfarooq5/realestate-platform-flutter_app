import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/services/recent_searches_store.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/widgets/property_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PropertyBloc _bloc = sl<PropertyBloc>();
  final RecentSearchesStore _recentSearches = sl<RecentSearchesStore>();
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _selectedType;
  String? _selectedCity;
  int? _bedrooms;
  List<String> _recent = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadCities());
    _loadRecent();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _runSearch();
    }
  }

  Future<void> _loadRecent() async {
    final recent = await _recentSearches.getAll();
    if (mounted) setState(() => _recent = recent);
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _runSearch({int page = 1}) {
    final query = _searchController.text.trim();
    if (page == 1) {
      _hasSearched = true;
      if (query.isNotEmpty) {
        _recentSearches.add(query).then((_) => _loadRecent());
      }
    }
    _bloc.add(
      LoadProperties(
        page: page,
        limit: 12,
        cityId: _selectedCity,
        type: _selectedType,
        bedrooms: _bedrooms,
        minPrice: _minPriceController.text.isEmpty
            ? null
            : double.tryParse(_minPriceController.text),
        maxPrice: _maxPriceController.text.isEmpty
            ? null
            : double.tryParse(_maxPriceController.text),
        search: query.isEmpty ? null : query,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search properties...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _runSearch(),
            ),
          ),
          onSubmitted: (value) => _runSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PropertiesLoaded) {
            if (state.properties.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No properties found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.properties.length + 1,
              itemBuilder: (context, index) {
                if (index == state.properties.length) {
                  // Load more when reaching the bottom
                  if (state.page < state.pages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _runSearch(page: state.page + 1);
                    });
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }
                final property = state.properties[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyCard(property: property),
                );
              },
            );
          }

          if (state is PropertyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _runSearch(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!_hasSearched && _recent.isNotEmpty) {
            return _buildRecentSearches();
          }

          return const Center(
            child: Text(
              'Enter a search term or use filters to find properties',
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () async {
                  await _recentSearches.clear();
                  _loadRecent();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recent.map((term) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = term;
                  _runSearch();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                      Text(term, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Property Type
                  const Text(
                    'Property Type',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'HOUSE',
                      'APARTMENT',
                      'PLOT',
                      'COMMERCIAL',
                      'VILLA',
                    ].map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // City
                  const Text(
                    'City',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<PropertyBloc, PropertyState>(
                    bloc: _bloc,
                    builder: (context, state) {
                      final cities = state is CitiesLoaded
                          ? state.cities
                          : const <City>[];
                      return DropdownButtonFormField<String>(
                        value: _selectedCity,
                        hint: const Text('All cities'),
                        isExpanded: true,
                        items: cities
                            .map<DropdownMenuItem<String>>(
                              (city) => DropdownMenuItem<String>(
                                value: city.id,
                                child: Text(city.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Bedrooms
                  const Text(
                    'Bedrooms',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [1, 2, 3, 4, 5].map((count) {
                      final isSelected = _bedrooms == count;
                      return ChoiceChip(
                        label: Text('$count+'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _bedrooms = selected ? count : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Price Range
                  const Text(
                    'Price Range (PKR)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            hintText: 'e.g. 500000',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max',
                            hintText: 'e.g. 50000000',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _runSearch();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
