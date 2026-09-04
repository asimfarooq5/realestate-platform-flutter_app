import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/data/models/chat_model.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/blocs/chat/chat_bloc.dart';

/// A single 1:1 conversation. No WebSocket yet, so it polls for new
/// messages every few seconds while open — good enough for a first
/// version without standing up real-time infrastructure.
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;

  const ChatScreen({super.key, required this.conversationId, required this.otherUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatBloc _bloc = sl<ChatBloc>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _load());
  }

  void _load() {
    _bloc.add(LoadMessages(widget.conversationId));
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _bloc.add(SendChatMessage(widget.conversationId, text));
    _textController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _bloc.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = (context.read<AuthBloc>().state as Authenticated).user.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is MessagesLoaded && state.conversationId == widget.conversationId) {
                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final previous = index > 0 ? state.messages[index - 1] : null;
                      final showDate = previous == null || !_isSameDay(previous.createdAt, message.createdAt);
                      final isMe = message.senderId == myId;
                      return Column(
                        children: [
                          if (showDate) _DateDivider(date: message.createdAt),
                          _MessageBubble(message: message, isMe: isMe),
                        ],
                      );
                    },
                  );
                }
                if (state is ChatError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(999)),
                child: TextField(
                  controller: _textController,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Message ${widget.otherUserName}',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final label = '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppTheme.border)),
          child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  String _time(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.navy : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isMe ? null : Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text, style: TextStyle(color: isMe ? Colors.white : AppTheme.textPrimary, fontSize: 14.5)),
            const SizedBox(height: 4),
            Text(
              _time(message.createdAt),
              style: TextStyle(color: isMe ? Colors.white70 : AppTheme.textMuted, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}
