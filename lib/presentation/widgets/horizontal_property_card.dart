import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';
import 'package:malkiyat_app/presentation/screens/property_detail_screen.dart';

/// Image-left / details-right card used in the "Homes for you" list —
/// distinct from PropertyCard's image-on-top layout, which is used in
/// horizontal-scrolling carousels (Featured, Nearby).
class HorizontalPropertyCard extends StatelessWidget {
  final Property property;

  const HorizontalPropertyCard({super.key, required this.property});

  String _formatPrice(double price) {
    if (price >= 10000000) return '${(price / 10000000).toStringAsFixed(2)} Cr';
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(2)} Lakh';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)} K';
    return price.toStringAsFixed(0);
  }

  bool _isFavorite(BuildContext context) {
    final state = context.read<PropertyBloc>().state;
    if (state is FavoriteToggled) return state.propertyId == property.id && state.isFavorite;
    if (state is FavoriteStatusLoaded) return state.propertyId == property.id && state.isFavorite;
    return false;
  }

  void _toggleFavorite(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthLandingScreen()));
      return;
    }
    context.read<PropertyBloc>().add(ToggleFavorite(property.id));
  }

  @override
  Widget build(BuildContext context) {
    final images = property.images ?? const [];
    final primaryImage = images.isEmpty
        ? null
        : images.firstWhere((img) => img.isPrimary, orElse: () => images.first);
    final isRent = property.status == 'FOR_RENT';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailScreen(slug: property.slug)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.hairline),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 110,
                height: 130,
                child: primaryImage != null
                    ? Image.network(
                        primaryImage.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surfaceAlt,
                          child: const Icon(Icons.image, color: AppTheme.textMuted),
                        ),
                      )
                    : Container(
                        color: AppTheme.surfaceAlt,
                        child: const Icon(Icons.image, color: AppTheme.textMuted),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRent ? AppTheme.primaryColor : AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isRent ? 'For rent' : 'For sale',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _toggleFavorite(context),
                        child: Icon(
                          _isFavorite(context) ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: _isFavorite(context) ? Colors.red : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${property.priceUnit} ${_formatPrice(property.price)}${isRent ? '/mo' : ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.title,
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: AppTheme.accentColor),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${property.area?.name ?? ''}, ${property.city?.name ?? ''}',
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (property.bedrooms != null) ...[
                        const Icon(Icons.bed_outlined, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text('${property.bedrooms}', style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                      ],
                      if (property.bathrooms != null) ...[
                        const Icon(Icons.bathroom_outlined, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text('${property.bathrooms}', style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceAlt,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          property.type,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
