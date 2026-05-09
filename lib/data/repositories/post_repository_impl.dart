import 'package:wello_frontend/data/data_source/post_remote_data_source.dart';
import 'package:wello_frontend/domain/entities/post.dart';
import 'package:wello_frontend/domain/entities/comment.dart';
import 'package:wello_frontend/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;

  PostRepositoryImpl(this.remote);

  @override
  Future<List<Post>> getPosts({required String token, int page = 0, int size = 10}) {
    return remote.getPosts(token: token, page: page, size: size);
  }

  @override
  Future<List<Post>> getUserPosts({
    required String token,
    required int userId,
    int page = 0,
    int size = 10,
  }) {
    return remote.getUserPosts(token: token, userId: userId, page: page, size: size);
  }

  @override
  Future<List<Post>> getPostsByTag({
    required String token,
    required String tag,
    int page = 0,
    int size = 10,
  }) {
    return remote.getPostsByTag(token: token, tag: tag, page: page, size: size);
  }

  @override
  Future<Post> createPost({
    required String token,
    required String? content,
    required String? imageUrl,
  }) {
    return remote.createPost(
      token: token,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> reactPost({
    required String token,
    required int postId,
    required String type,
  }) {
    return remote.reactPost(token: token, postId: postId, type: type);
  }

  @override
  Future<List<Comment>> getComments({required String token, required int postId}) {
    return remote.getComments(token: token, postId: postId);
  }

  @override
  Future<Comment> addComment({
    required String token,
    required int postId,
    required String content,
  }) {
    return remote.addComment(token: token, postId: postId, content: content);
  }
}
