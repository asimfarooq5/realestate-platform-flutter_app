import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';
import 'package:malkiyat_app/presentation/screens/property_detail_screen.dart';

/// Inquiries the current user has sent to sellers/agents — the closest
/// existing concept to ZippeeHomes' "Messages" tab. There's no real-time
/// chat backend yet, so this is a one-way inquiry log rather than a
/// conversation view.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! Authenticated) {
            return _buildGuestView(context);
          }
          return _buildInquiriesList(context);
        },
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Sign in to see your messages',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthLandingScreen())),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInquiriesList(BuildContext context) {
    context.read<PropertyBloc>().add(LoadInquiries());
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        if (state is InquiriesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PropertyError) {
          return Center(child: Text(state.message));
        }
        if (state is InquiriesLoaded) {
          if (state.inquiries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text('Inquiries you send on a listing show up here', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<PropertyBloc>().add(LoadInquiries()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.inquiries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final inquiry = state.inquiries[index];
                return GestureDetector(
                  onTap: inquiry.propertySlug == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PropertyDetailScreen(slug: inquiry.propertySlug!)),
                          ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.hairline),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(Icons.home_outlined, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inquiry.propertyTitle ?? 'Property inquiry',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                inquiry.message,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(status: inquiry.status),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'PENDING' => AppTheme.warningColor,
      'RESPONDED' => AppTheme.successColor,
      _ => AppTheme.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(
        status[0] + status.substring(1).toLowerCase(),
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
