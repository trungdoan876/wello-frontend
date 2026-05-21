import 'package:dio/dio.dart';
import 'package:wello_frontend/core/constants/api_endpoints.dart';

class ChatRemoteDataSource {
  final Dio _dio;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'CHAT_BASE_URL',
    defaultValue: ApiEndpoints.baseUrl,
  );
  static const String _chatConversationsPath = '/chat/conversations';
  static const String _chatMessagesPath = '/chat/messages';

  ChatRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          ) {
    // Add verbose logging for requests/responses to help debug 4xx/5xx issues
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  List<String> _candidateBaseUrls() {
    final baseUrl = _defaultBaseUrl;
    final candidates = <String>[baseUrl];

    if (baseUrl.contains(':8080')) {
      final uri = Uri.tryParse(baseUrl);
      if (uri != null) {
        final currentHost = uri.host;
        final fallbacks = ['10.0.2.2', 'localhost', '127.0.0.1', '10.0.3.2'];
        for (final host in fallbacks) {
          if (host != currentHost) {
            candidates.add(baseUrl.replaceFirst(currentHost, host));
          }
        }
      }
    }

    final unique = <String>[];
    for (final candidate in candidates) {
      if (!unique.contains(candidate)) unique.add(candidate);
    }
    return unique;
  }

  bool _isRetryableNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  void _logResponse(String label, Response<dynamic> resp) {
    print(
      '[ChatRemote] $label -> status=${resp.statusCode}, data=${resp.data}',
    );
  }

  Future<Response<dynamic>> _getWithFallback({
    required String path,
    required String token,
  }) async {
    DioException? lastErr;
    for (final baseUrl in _candidateBaseUrls()) {
      final url = '$baseUrl$path';
      try {
        print('[ChatRemote] GET try: $url');
        final resp = await _dio.get(
          url,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        _logResponse('GET $path', resp);
        return resp;
      } on DioException catch (e) {
        lastErr = e;
        if (_isRetryableNetworkError(e)) {
          print('[ChatRemote] GET retryable error on $url: ${e.type}');
          continue;
        }
        rethrow;
      }
    }
    throw lastErr ?? Exception('GET failed for $path');
  }

  Future<Response<dynamic>> _postWithFallback({
    required String path,
    required String token,
    Map<String, dynamic>? data,
  }) async {
    DioException? lastErr;
    for (final baseUrl in _candidateBaseUrls()) {
      final url = '$baseUrl$path';
      try {
        print('[ChatRemote] POST try: $url');
        final resp = await _dio.post(
          url,
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        _logResponse('POST $path', resp);
        return resp;
      } on DioException catch (e) {
        lastErr = e;
        if (_isRetryableNetworkError(e)) {
          print('[ChatRemote] POST retryable error on $url: ${e.type}');
          continue;
        }
        rethrow;
      }
    }
    throw lastErr ?? Exception('POST failed for $path');
  }

  Future<Map<String, dynamic>> createOrGetConversation({
    required int recipientUserId,
    required String token,
  }) async {
    final resp = await _postWithFallback(
      path: _chatConversationsPath,
      token: token,
      data: {'recipientUserId': recipientUserId},
    );
    _logResponse('createOrGetConversation', resp);
    return {'statusCode': resp.statusCode, 'data': resp.data};
  }

  Future<List<dynamic>> getConversations({required String token}) async {
    final resp = await _getWithFallback(
      path: _chatConversationsPath,
      token: token,
    );
    _logResponse('getConversations', resp);
    // Backend trả về List trực tiếp (không bọc trong {"data": [...]})
    final raw = resp.data;
    if (raw is List) return raw;
    return (raw['data'] as List<dynamic>?) ?? const [];
  }

  Future<List<dynamic>> getMessages({
    required int conversationId,
    required String token,
  }) async {
    final resp = await _getWithFallback(
      path: '$_chatConversationsPath/$conversationId/messages',
      token: token,
    );
    _logResponse('getMessages(conversationId=$conversationId)', resp);
    // Backend trả về List trực tiếp (không bọc trong {"data": [...]})
    final raw = resp.data;
    if (raw is List) return raw;
    return (raw['data'] as List<dynamic>?) ?? const [];
  }

  Future<Map<String, dynamic>> sendMessageToConversation({
    required int conversationId,
    required String token,
    required int recipientUserId,
    String? textContent,
    String? imageBase64,
  }) async {
    final body = <String, dynamic>{};
    if (textContent != null) {
      body['textContent'] = textContent;
      body['text_content'] = textContent;
    }
    if (imageBase64 != null) {
      body['imageBase64'] = imageBase64;
      body['image_base64'] = imageBase64;
    }

    try {
      final resp = await _postWithFallback(
        path: '$_chatConversationsPath/$conversationId/messages',
        token: token,
        data: body,
      );
      try {
        print(
          '[ChatRemote] POST /chat/conversations/$conversationId/messages -> ${resp.statusCode} ${resp.data}',
        );
      } catch (_) {}
      _logResponse(
        'sendMessageToConversation(conversationId=$conversationId)',
        resp,
      );
      return {'statusCode': resp.statusCode, 'data': resp.data};
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 409) {
        print(
          '[ChatRemote] conversation message conflict (409), fallback to direct send /chat/messages',
        );
        return sendMessageToUser(
          recipientUserId: recipientUserId,
          token: token,
          textContent: textContent,
          imageBase64: imageBase64,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessageToUser({
    required int recipientUserId,
    required String token,
    String? textContent,
    String? imageBase64,
  }) async {
    final body = <String, dynamic>{
      'recipientUserId': recipientUserId,
      'recipient_user_id': recipientUserId,
    };
    if (textContent != null) {
      body['textContent'] = textContent;
      body['text_content'] = textContent;
    }
    if (imageBase64 != null) {
      body['imageBase64'] = imageBase64;
      body['image_base64'] = imageBase64;
    }

    final resp = await _postWithFallback(
      path: _chatMessagesPath,
      token: token,
      data: body,
    );
    try {
      print(
        '[ChatRemote] POST /chat/messages -> ${resp.statusCode} ${resp.data}',
      );
    } catch (_) {}
    _logResponse('sendMessageToUser(recipientUserId=$recipientUserId)', resp);
    return {'statusCode': resp.statusCode, 'data': resp.data};
  }

  Future<Map<String, dynamic>> markConversationRead({
    required int conversationId,
    required String token,
  }) async {
    final path = '$_chatConversationsPath/$conversationId/mark-read';
    try {
      final resp = await _postWithFallback(path: path, token: token);
      _logResponse(
        'markConversationRead(conversationId=$conversationId)',
        resp,
      );
      return {'statusCode': resp.statusCode, 'data': resp.data};
    } catch (e) {
      print('[ChatRemote] markConversationRead error: $e');
      rethrow;
    }
  }
}
