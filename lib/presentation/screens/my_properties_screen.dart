import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/data/repositories/property_repository.dart';
import 'package:malkiyat_app/presentation/widgets/horizontal_property_card.dart';

/// Shows the current user's own listings. Pass isDraft: true for the
/// Drafts screen, leave it null (default) for "My Properties" (everything
/// the user has posted, published or not).
class MyPropertiesScreen extends StatefulWidget {
  final bool? isDraft;
  final String title;

  const MyPropertiesScreen({super.key, this.isDraft, this.title = 'My Properties'});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  late final Future<List<Property>> _future =
      sl<PropertyRepository>().getMyProperties(isDraft: widget.isDraft);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Property>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final properties = snapshot.data ?? [];
          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    widget.isDraft == true ? "No drafts yet" : "You haven't posted any listings yet",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => HorizontalPropertyCard(property: properties[index]),
          );
        },
      ),
    );
  }
}
