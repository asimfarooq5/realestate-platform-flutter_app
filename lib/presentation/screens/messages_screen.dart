import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/property_model.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/property/property_bloc.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';
import 'package:malkiyat_app/presentation/screens/property_detail_screen.dart';

/// Inquiries the current user has sent to sellers/agents, presented as a
/// chat-style list (search, All/Unread filter, avatar + preview + time)
/// to match ZippeeHomes' Messages tab. There's no real-time chat backend
/// yet — this is a one-way inquiry log, not a conversation thread, so
/// "unread" here just means "awaiting a response" (status PENDING).
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchController = TextEditingController();
  bool _unreadOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return _buildGuestView(context);
            }
            return _buildInquiries(context);
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Messages', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          const Text('Your chats', style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppTheme.border)),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search...', isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _filterPill('All', !_unreadOnly, () => setState(() => _unreadOnly = false)),
              const SizedBox(width: 10),
              _filterPill('Unread', _unreadOnly, () => setState(() => _unreadOnly = true)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _filterPill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
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
          ),
        ),
      ],
    );
  }

  Widget _buildInquiries(BuildContext context) {
    context.read<PropertyBloc>().add(LoadInquiries());
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        if (state is InquiriesLoading) {
          return Column(children: [_buildHeader(), const Expanded(child: Center(child: Text('Loading chats...', style: TextStyle(color: AppTheme.textMuted))))]);
        }
        if (state is PropertyError) {
          return Column(children: [_buildHeader(), Expanded(child: Center(child: Text(state.message)))]);
        }
        if (state is InquiriesLoaded) {
          final query = _searchController.text.trim().toLowerCase();
          final filtered = state.inquiries.where((inquiry) {
            if (_unreadOnly && inquiry.status != 'PENDING') return false;
            if (query.isEmpty) return true;
            return (inquiry.propertyTitle ?? '').toLowerCase().contains(query) ||
                inquiry.message.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
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
                      )
                    : RefreshIndicator(
                        onRefresh: () async => context.read<PropertyBloc>().add(LoadInquiries()),
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _ChatRow(inquiry: filtered[index]),
                        ),
                      ),
              ),
            ],
          );
        }
        return Column(children: [_buildHeader()]);
      },
    );
  }
}

String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

class _ChatRow extends StatelessWidget {
  final Inquiry inquiry;

  const _ChatRow({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final unread = inquiry.status == 'PENDING';
    return GestureDetector(
      onTap: inquiry.propertySlug == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PropertyDetailScreen(slug: inquiry.propertySlug!)),
              ),
      child: Container(
        color: unread ? AppTheme.warningBg.withValues(alpha: 0.4) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppTheme.navy, shape: BoxShape.circle),
              child: const Icon(Icons.home_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inquiry.propertyTitle ?? 'Property inquiry',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    inquiry.message,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_relativeTime(inquiry.createdAt), style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
