import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/property_list_screen.dart';

class CitiesSection extends StatefulWidget {
  const CitiesSection({super.key});

  @override
  State<CitiesSection> createState() => _CitiesSectionState();
}

class _CitiesSectionState extends State<CitiesSection> {
  // A dedicated bloc instance — the home screen's sections (featured,
  // nearby, cities) used to share one global PropertyBloc, so whichever
  // section's fetch resolved last would blank out the others (they only
  // render for their own state type and fall back to a loading placeholder
  // for everything else).
  final PropertyBloc _bloc = sl<PropertyBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadCities());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Popular Cities',
            style: TextStyle(
              fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppTheme.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Cities Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<PropertyBloc, PropertyState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is CitiesLoaded) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: state.cities.take(6).length,
                  itemBuilder: (context, index) {
                    final city = state.cities[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyListScreen(
                              title: 'Properties in ${city.name}',
                              cityId: city.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryDark,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background pattern
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Icon(
                                Icons.location_city,
                                size: 80,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    city.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${city.propertyCount} Properties',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              // Loading state
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(18),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
