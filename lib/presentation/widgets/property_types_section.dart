import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/constants/app_constants.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/property_list_screen.dart';

class PropertyTypesSection extends StatelessWidget {
  const PropertyTypesSection({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'HOUSE':
        return Icons.home;
      case 'APARTMENT':
        return Icons.apartment;
      case 'PLOT':
        return Icons.landscape;
      case 'COMMERCIAL':
        return Icons.business;
      case 'VILLA':
        return Icons.villa;
      case 'FARM_HOUSE':
        return Icons.agriculture;
      default:
        return Icons.home;
    }
  }

  String _getDisplayName(String type) {
    return type.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Property Types',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppConstants.propertyTypes.length,
            itemBuilder: (context, index) {
              final type = AppConstants.propertyTypes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyListScreen(
                        title: _getDisplayName(type),
                        type: type,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getIconForType(type),
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDisplayName(type),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
