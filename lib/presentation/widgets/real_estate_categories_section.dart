import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/screens/property_list_screen.dart';

class _Category {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final String image;
  final String? status;
  final String? type;

  const _Category({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.image,
    this.status,
    this.type,
  });
}

const _categories = [
  _Category(
    title: 'Buy',
    subtitle: 'Houses, plots & more',
    icon: Icons.home_outlined,
    iconBg: Color(0xFF7C3AED),
    image: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80',
    status: 'FOR_SALE',
  ),
  _Category(
    title: 'Rent',
    subtitle: 'Find your next home',
    icon: Icons.vpn_key_outlined,
    iconBg: Color(0xFF2563EB),
    image: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=600&q=80',
    status: 'FOR_RENT',
  ),
  _Category(
    title: 'Commercial',
    subtitle: 'Offices & shops',
    icon: Icons.business_center_outlined,
    iconBg: Color(0xFF0E9F6E),
    image: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=600&q=80',
    type: 'COMMERCIAL',
  ),
];

/// Real-estate category cards on the home screen — replaces the generic
/// icon-row "property types" strip with photo cards, matching the
/// "Explore our marketplaces" layout ZippeeHomes uses (but scoped to real
/// estate categories, since Malkiyat is a single-vertical app).
class RealEstateCategoriesSection extends StatelessWidget {
  const RealEstateCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Explore properties',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final c = _categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyListScreen(
                        title: c.title,
                        status: c.status,
                        type: c.type,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 168,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.hairline),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              c.image,
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 110, color: AppTheme.surfaceAlt),
                            ),
                            Positioned(
                              left: 10,
                              bottom: -18,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: c.iconBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                ),
                                child: Icon(c.icon, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(
                                c.subtitle,
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
