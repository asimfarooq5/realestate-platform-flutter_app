part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationStarted extends ChatState {
  final Conversation conversation;

  const ConversationStarted(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

class MessagesLoaded extends ChatState {
  final String conversationId;
  final List<ChatMessage> messages;

  const MessagesLoaded(this.conversationId, this.messages);

  @override
  List<Object?> get props => [conversationId, messages];
}

class CommunityPostsLoaded extends ChatState {
  final List<CommunityPost> posts;

  const CommunityPostsLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
