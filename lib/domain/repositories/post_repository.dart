import 'package:wello_frontend/domain/entities/post.dart';
import 'package:wello_frontend/domain/entities/comment.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts({required String token, int page = 0, int size = 10});
  Future<List<Post>> getUserPosts({
    required String token,
    required int userId,
    int page = 0,
    int size = 10,
  });
  Future<List<Post>> getPostsByTag({
    required String token,
    required String tag,
    int page = 0,
    int size = 10,
  });
  Future<Post> createPost({
    required String token,
    required String? content,
    required String? imageUrl,
  });
  Future<void> reactPost({
    required String token,
    required int postId,
    required String type,
  });
  
  // Comments
  Future<List<Comment>> getComments({required String token, required int postId});
  Future<Comment> addComment({
    required String token,
    required int postId,
    required String content,
  });

  Future<Post> editPost({
    required String token,
    required int postId,
    required String? content,
    required String? imageUrl,
  });
  Future<void> deletePost({
    required String token,
    required int postId,
  });
}

