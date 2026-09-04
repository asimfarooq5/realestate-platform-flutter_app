import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:malkiyat_app/data/models/chat_model.dart';
import 'package:malkiyat_app/data/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<StartConversation>(_onStartConversation);
    on<LoadMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendChatMessage);
    on<LoadCommunityPosts>(_onLoadCommunityPosts);
  }

  Future<void> _onLoadConversations(LoadConversations event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final conversations = await _chatRepository.getConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(_friendlyError(e)));
    }
  }

  Future<void> _onStartConversation(StartConversation event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final conversation = await _chatRepository.startConversation(
        otherUserId: event.otherUserId,
        propertyId: event.propertyId,
        message: event.message,
      );
      emit(ConversationStarted(conversation));
    } catch (e) {
      emit(ChatError(_friendlyError(e)));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    try {
      final messages = await _chatRepository.getMessages(event.conversationId);
      emit(MessagesLoaded(event.conversationId, messages));
    } catch (e) {
      emit(ChatError(_friendlyError(e)));
    }
  }

  Future<void> _onSendChatMessage(SendChatMessage event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.sendMessage(event.conversationId, event.text);
      final messages = await _chatRepository.getMessages(event.conversationId);
      emit(MessagesLoaded(event.conversationId, messages));
    } catch (e) {
      emit(ChatError(_friendlyError(e)));
    }
  }

  Future<void> _onLoadCommunityPosts(LoadCommunityPosts event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final posts = await _chatRepository.getCommunityPosts();
      emit(CommunityPostsLoaded(posts));
    } catch (e) {
      emit(ChatError(_friendlyError(e)));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('401')) return 'Please sign in to continue';
    if (msg.contains('SocketException') || msg.contains('Connection failed') || msg.contains('Connection refused')) {
      return 'Could not connect to the server. Check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
