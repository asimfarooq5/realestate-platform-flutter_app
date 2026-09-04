import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/widgets/property_card.dart';
import 'package:malkiyat_app/presentation/widgets/loading_shimmer.dart';

class PropertyListScreen extends StatefulWidget {
  final String? title;
  final String? cityId;
  final String? type;
  final String? status;
  final bool? featured;

  const PropertyListScreen({
    super.key,
    this.title,
    this.cityId,
    this.type,
    this.status,
    this.featured,
  });

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  String? _selectedType;
  int? _bedrooms;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.type;
    _loadProperties(page: 1);
  }

  void _loadProperties({required int page}) {
    context.read<PropertyBloc>().add(
          LoadProperties(
            page: page,
            limit: 12,
            cityId: widget.cityId,
            type: _selectedType,
            status: widget.status,
            bedrooms: _bedrooms,
            featured: widget.featured,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const LoadingShimmer();
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
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
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
                  if (state.page < state.pages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadProperties(page: state.page + 1);
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
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadProperties(page: 1),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadProperties(page: 1);
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
