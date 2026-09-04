import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/chat_model.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/chat/chat_bloc.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';
import 'package:malkiyat_app/presentation/screens/chat_screen.dart';
import 'package:malkiyat_app/presentation/screens/community_screen.dart';

/// Chat list — a pinned "Malkiyat Community" row (announcements) plus the
/// user's real 1:1 conversations, matching ZippeeHomes' Messages tab.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatBloc _bloc = sl<ChatBloc>();
  final _searchController = TextEditingController();
  bool _unreadOnly = false;

  @override
  void dispose() {
    _bloc.close();
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
            return _buildConversations(context);
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
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
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

  Widget _buildConversations(BuildContext context) {
    _bloc.add(LoadConversations());
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is ChatLoading) {
          return Column(children: [_buildHeader(), const Expanded(child: Center(child: Text('Loading chats...', style: TextStyle(color: AppTheme.textMuted))))]);
        }
        if (state is ChatError) {
          return Column(children: [_buildHeader(), Expanded(child: Center(child: Text(state.message)))]);
        }

        final query = _searchController.text.trim().toLowerCase();
        List<Conversation> conversations = state is ConversationsLoaded ? state.conversations : const [];
        conversations = conversations.where((c) {
          if (_unreadOnly && c.unreadCount == 0) return false;
          if (query.isEmpty) return true;
          return (c.otherUser?.name ?? '').toLowerCase().contains(query) ||
              (c.lastMessage ?? '').toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                children: [
                  if (!_unreadOnly && query.isEmpty) _buildCommunityRow(context),
                  ...conversations.map((c) => _ConversationRow(conversation: c)),
                  if (conversations.isEmpty && (_unreadOnly || query.isNotEmpty))
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('No matching chats', style: TextStyle(color: AppTheme.textMuted))),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommunityRow(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen())),
      child: Container(
        color: AppTheme.warningBg.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: BorderRadius.circular(14),
                image: const DecorationImage(image: AssetImage('assets/icons/app_icon.png'), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Malkiyat Community', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  SizedBox(height: 3),
                  Text('Announcements & updates', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  final Conversation conversation;

  const _ConversationRow({required this.conversation});

  String _relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCount > 0;
    final name = conversation.otherUser?.name ?? conversation.otherUser?.email ?? 'User';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conversation.id, otherUserName: name)),
      ),
      child: Container(
        color: unread ? AppTheme.warningBg.withValues(alpha: 0.4) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: AppTheme.primaryColor, child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (conversation.propertyTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(conversation.propertyTitle!, style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryColor, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 3),
                  Text(conversation.lastMessage ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_relativeTime(conversation.lastMessageAt), style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                if (unread) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(999)),
                    child: Text('${conversation.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
