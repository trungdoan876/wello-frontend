import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wello_frontend/core/constants/api_endpoints.dart';
import 'package:wello_frontend/data/models/responses/post_model.dart';
import 'package:wello_frontend/domain/entities/comment.dart';

class PostRemoteDataSource {
  final http.Client client = http.Client();

  Future<List<PostModel>> getPosts({
    required String token,
    int page = 0,
    int size = 10,
  }) async {
    final url = Uri.parse('${ApiEndpoints.posts}?page=$page&size=$size');
    return _fetchPosts(url, token);
  }

  Future<List<PostModel>> getUserPosts({
    required String token,
    required int userId,
    int page = 0,
    int size = 10,
  }) async {
    final url = Uri.parse('${ApiEndpoints.posts}/user/$userId?page=$page&size=$size');
    return _fetchPosts(url, token);
  }

  Future<List<PostModel>> getPostsByTag({
    required String token,
    required String tag,
    int page = 0,
    int size = 10,
  }) async {
    final url = Uri.parse('${ApiEndpoints.posts}/tag/$tag?page=$page&size=$size');
    return _fetchPosts(url, token);
  }

  Future<List<PostModel>> _fetchPosts(Uri url, String token) async {
    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List content = data['content'] ?? [];
      return content.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<PostModel> createPost({
    required String token,
    required String? content,
    required String? imageUrl,
  }) async {
    final url = Uri.parse(ApiEndpoints.posts);

    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return PostModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<void> reactPost({
    required String token,
    required int postId,
    required String type,
  }) async {
    final url = Uri.parse(ApiEndpoints.reactPost(postId, type));
    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to react to post');
    }
  }

  // Comments
  Future<List<Comment>> getComments({
    required String token,
    required int postId,
  }) async {
    final url = Uri.parse('${ApiEndpoints.posts}/$postId/comments');

    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Comment> addComment({
    required String token,
    required int postId,
    required String content,
  }) async {
    final url = Uri.parse('${ApiEndpoints.posts}/$postId/comment');

    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment');
    }
  }
}
