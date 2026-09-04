import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';
import 'package:malkiyat_app/presentation/widgets/loading_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String slug;

  const PropertyDetailScreen({super.key, required this.slug});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _inquiryLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(LoadPropertyDetail(widget.slug));
  }

  void _checkFavorite(String propertyId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<PropertyBloc>().add(CheckFavoriteStatus(propertyId));
    }
  }

  void _toggleFavorite(String propertyId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save properties')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
      );
      return;
    }
    context.read<PropertyBloc>().add(ToggleFavorite(propertyId));
  }

  Future<void> _sendInquiry(Property property) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send an inquiry')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
      );
      return;
    }

    final user = (authState as Authenticated).user;
    setState(() => _inquiryLoading = true);
    try {
      await context.read<PropertyBloc>().sendInquiry(
            property.id,
            Inquiry(
              id: '',
              userId: user.id,
              propertyId: property.id,
              name: user.name ?? user.email,
              email: user.email,
              message:
                  'I am interested in this property. Please contact me with more details.',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inquiry sent! The owner will contact you soon.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send inquiry. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _inquiryLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const LoadingShimmer();
          }

          if (state is PropertyDetailLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkFavorite(state.property.id);
            });
            return _buildContent(state.property);
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
                    onPressed: () {
                      context.read<PropertyBloc>().add(
                            LoadPropertyDetail(widget.slug),
                          );
                    },
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

  Widget _buildContent(Property property) {
    final images = property.images ?? [];
    final primaryImage = images.isNotEmpty
        ? images.firstWhere((img) => img.isPrimary, orElse: () => images.first)
        : null;

    return CustomScrollView(
      slivers: [
        // Image Carousel
        SliverAppBar(
          expandedHeight: 300,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                if (images.isNotEmpty)
                  CarouselSlider(
                    items: images.map((image) {
                      return Image.network(
                        image.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 64),
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 64),
                    ),
                  ),
                // Image indicator
                if (images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _currentImageIndex,
                        count: images.length,
                        effect: const WormEffect(
                          dotWidth: 8,
                          dotHeight: 8,
                          activeDotColor: AppTheme.primaryColor,
                          dotColor: Colors.white70,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(property.id),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Share property
              },
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${property.priceUnit} ${_formatPrice(property.price)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.area?.name ?? ""}, ${property.city?.name ?? ""}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Property Features
                _buildFeatures(property),

                const SizedBox(height: 24),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  property.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Amenities
                if (property.amenities != null &&
                    property.amenities!.isNotEmpty)
                  _buildAmenities(property.amenities!),

                const SizedBox(height: 24),

                // Contact Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(property.contactPhone),
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _sendEmail(property.contactEmail),
                        icon: const Icon(Icons.email),
                        label: const Text('Email'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Send Inquiry
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _inquiryLoading
                        ? null
                        : () => _sendInquiry(property),
                    icon: _inquiryLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.message_outlined),
                    label: Text(
                      _inquiryLoading ? 'Sending...' : 'Send Inquiry',
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (property.bedrooms != null)
            _buildFeatureItem(
              Icons.bed_outlined,
              '${property.bedrooms} Beds',
            ),
          if (property.bathrooms != null)
            _buildFeatureItem(
              Icons.bathroom_outlined,
              '${property.bathrooms} Baths',
            ),
          _buildFeatureItem(
            Icons.square_foot,
            '${property.areaSize.toInt()} ${property.areaUnit}',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities(List<String> amenities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            return Chip(
              label: Text(amenity),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} Lakh';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} K';
    }
    return price.toStringAsFixed(0);
  }

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String? email) async {
    if (email == null) return;
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
