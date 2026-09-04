import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/property_list_screen.dart';
import 'package:malkiyat_app/presentation/widgets/property_card.dart';
import 'package:malkiyat_app/presentation/widgets/loading_shimmer.dart';

class FeaturedPropertiesSection extends StatefulWidget {
  const FeaturedPropertiesSection({super.key});

  @override
  State<FeaturedPropertiesSection> createState() =>
      _FeaturedPropertiesSectionState();
}

class _FeaturedPropertiesSectionState extends State<FeaturedPropertiesSection> {
  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(
          const LoadProperties(featured: true, limit: 4),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Properties',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PropertyListScreen(
                        title: 'Featured Properties',
                        featured: true,
                      ),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Properties List
        SizedBox(
          height: 320,
          child: BlocBuilder<PropertyBloc, PropertyState>(
            builder: (context, state) {
              if (state is PropertyLoading) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 280,
                        child: PropertyCardShimmer(),
                      ),
                    );
                  },
                );
              }

              if (state is PropertiesLoaded) {
                if (state.properties.isEmpty) {
                  return const Center(
                    child: Text('No featured properties available'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.properties.length,
                  itemBuilder: (context, index) {
                    final property = state.properties[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 280,
                        child: PropertyCard(property: property),
                      ),
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
