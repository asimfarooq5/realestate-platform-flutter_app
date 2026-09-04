import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
abstract class ChatUser with _$ChatUser {
  const factory ChatUser({
    required String id,
    String? name,
    required String email,
  }) = _ChatUser;

  factory ChatUser.fromJson(Map<String, dynamic> json) => _$ChatUserFromJson(json);
}

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    @JsonKey(name: 'other_user') ChatUser? otherUser,
    @JsonKey(name: 'property_id') String? propertyId,
    @JsonKey(name: 'property_title') String? propertyTitle,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String text,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}

@freezed
abstract class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    required String title,
    required String body,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) => _$CommunityPostFromJson(json);
}
