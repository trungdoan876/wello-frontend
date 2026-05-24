import 'package:wello_frontend/data/data_source/chat_remote_data_source.dart';

class ChatRepository {
  final ChatRemoteDataSource _remote;

  ChatRepository({ChatRemoteDataSource? remote})
    : _remote = remote ?? ChatRemoteDataSource();

  Future<Map<String, dynamic>> createOrGetConversation({
    required int recipientUserId,
    required String token,
  }) async {
    return _remote.createOrGetConversation(
      recipientUserId: recipientUserId,
      token: token,
    );
  }

  Future<List<dynamic>> getMessages({
    required int conversationId,
    required String token,
  }) async {
    return _remote.getMessages(conversationId: conversationId, token: token);
  }

  Future<List<dynamic>> getConversations({required String token}) async {
    return _remote.getConversations(token: token);
  }

  Future<Map<String, dynamic>> sendMessageToConversation({
    required int conversationId,
    required String token,
    required int recipientUserId,
    String? textContent,
    String? imageBase64,
  }) async {
    return _remote.sendMessageToConversation(
      conversationId: conversationId,
      token: token,
      recipientUserId: recipientUserId,
      textContent: textContent,
      imageBase64: imageBase64,
    );
  }

  Future<Map<String, dynamic>> sendMessageToUser({
    required int recipientUserId,
    required String token,
    String? textContent,
    String? imageBase64,
  }) async {
    return _remote.sendMessageToUser(
      recipientUserId: recipientUserId,
      token: token,
      textContent: textContent,
      imageBase64: imageBase64,
    );
  }

  Future<Map<String, dynamic>> markConversationRead({
    required int conversationId,
    required String token,
  }) async {
    return _remote.markConversationRead(
      conversationId: conversationId,
      token: token,
    );
  }
}
