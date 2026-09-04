import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/data/repositories/property_repository.dart';

/// Developer-marketed housing/commercial schemes — the backend already
/// supports these (app/models/property.py::Project); this is the first
/// client screen for them.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final Future<List<Project>> _future = sl<PropertyRepository>().getProjects();

  String _statusLabel(String status) => switch (status) {
        'ONGOING' => 'Ongoing',
        'COMPLETED' => 'Completed',
        _ => 'Upcoming',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: FutureBuilder<List<Project>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final projects = snapshot.data ?? [];
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apartment_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No projects listed yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final project = projects[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.hairline)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (project.coverImage != null)
                      Image.network(project.coverImage!, height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(project.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                                child: Text(_statusLabel(project.status), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10.5, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          if (project.developer != null) ...[
                            const SizedBox(height: 4),
                            Text('by ${project.developer}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
                          ],
                          if (project.city != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 13, color: AppTheme.accentColor),
                                const SizedBox(width: 3),
                                Text(project.city!.name, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ],
                          if (project.description != null) ...[
                            const SizedBox(height: 8),
                            Text(project.description!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                          if (project.priceStarting != null) ...[
                            const SizedBox(height: 8),
                            Text('Starting from PKR ${project.priceStarting!.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
