import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/di/injection.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/chat/chat_bloc.dart';

/// Read-only announcement feed — regular users can't post here (matches
/// the "tap a member name to message them privately" pattern: public
/// posting stays admin-only, everything else is a real 1:1 chat).
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ChatBloc _bloc = sl<ChatBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadCommunityPosts());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Malkiyat Community', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text('Announcements & updates', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
          ],
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          if (state is CommunityPostsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No announcements yet', style: TextStyle(color: AppTheme.textMuted)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.imageUrl != null)
                        Image.network(
                          post.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(post.body, style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
