part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ChatEvent {}

class StartConversation extends ChatEvent {
  final String otherUserId;
  final String? propertyId;
  final String message;

  const StartConversation({required this.otherUserId, this.propertyId, required this.message});

  @override
  List<Object?> get props => [otherUserId, propertyId, message];
}

class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendChatMessage extends ChatEvent {
  final String conversationId;
  final String text;

  const SendChatMessage(this.conversationId, this.text);

  @override
  List<Object?> get props => [conversationId, text];
}

class LoadCommunityPosts extends ChatEvent {}
