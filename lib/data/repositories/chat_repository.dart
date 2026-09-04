import 'package:malkiyat_app/data/datasources/remote/api_client.dart';
import 'package:malkiyat_app/data/models/chat_model.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  Future<List<Conversation>> getConversations() => _apiClient.getConversations();

  Future<Conversation> startConversation({
    required String otherUserId,
    String? propertyId,
    required String message,
  }) {
    return _apiClient.startConversation(
      otherUserId: otherUserId,
      propertyId: propertyId,
      message: message,
    );
  }

  Future<List<ChatMessage>> getMessages(String conversationId) =>
      _apiClient.getMessages(conversationId);

  Future<ChatMessage> sendMessage(String conversationId, String text) =>
      _apiClient.sendChatMessage(conversationId, text);

  Future<List<CommunityPost>> getCommunityPosts() => _apiClient.getCommunityPosts();
}
