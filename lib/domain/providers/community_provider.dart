import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/entities/post.dart';
import 'package:wello_frontend/domain/entities/comment.dart';
import 'package:wello_frontend/domain/repositories/post_repository.dart';

class CommunityProvider extends ChangeNotifier {
  final PostRepository _repository;

  List<Post> _posts = [];
  List<Post> _userPosts = [];
  List<Post> _taggedPosts = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;

  CommunityProvider(this._repository);

  List<Post> get posts => _posts;
  List<Post> get userPosts => _userPosts;
  List<Post> get taggedPosts => _taggedPosts;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _posts = [];
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';

      print('[COMMUNITY] Fetching page $_currentPage...');
      final newPosts = await _repository.getPosts(
        token: token,
        page: _currentPage,
        size: 10,
      );
      print('[COMMUNITY] Received ${newPosts.length} posts');

      if (newPosts.length < 10) {
        print('[COMMUNITY] No more posts to load');
        _hasMore = false;
      } else {
        _hasMore = true;
      }
      
      if (newPosts.isNotEmpty) {
        _posts.addAll(List<Post>.from(newPosts));
        _currentPage++;
      }
    } catch (e) {
      print('[COMMUNITY] Error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserPosts(int userId, {bool refresh = false}) async {
    if (refresh) {
      _userPosts = [];
    }
    _isLoading = true;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';

      final posts = await _repository.getUserPosts(
        token: token,
        userId: userId,
      );
      _userPosts = List<Post>.from(posts);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPostsByTag(String tag, {bool refresh = false}) async {
    if (refresh) {
      _taggedPosts = [];
      _isLoading = true;
      notifyListeners();
    }

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';

      final posts = await _repository.getPostsByTag(
        token: token,
        tag: tag,
      );
      _taggedPosts = List<Post>.from(posts);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String? content,
    File? imageFile,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';

      String? imageUrl;
      if (imageFile != null) {
        // Chuyển ảnh sang chuỗi Base64
        final bytes = await imageFile.readAsBytes();
        imageUrl = base64Encode(bytes);
      }

      final newPost = await _repository.createPost(
        token: token,
        content: content,
        imageUrl: imageUrl,
      );

      _posts.insert(0, newPost);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> reactPost(int postId, ReactionType reactionType) async {
    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';

      // Optimistic update
      _updatePostReaction(postId, reactionType);

      await _repository.reactPost(
        token: token,
        postId: postId,
        type: reactionType.name,
      );
    } catch (e) {
      // Revert if failed
      // For multi-reaction, revert is tricky without storing previous state.
      // For now, just show error.
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _updatePostReaction(int postId, ReactionType newReaction) {
    void updateList(List<Post> list) {
      final index = list.indexWhere((p) => p.idPost == postId);
      if (index != -1) {
        final post = list[index];
        final oldReaction = post.currentUserReaction;
        
        bool isLiked;
        int likesCountChange = 0;

        if (oldReaction == ReactionType.NONE) {
          // New reaction
          isLiked = true;
          likesCountChange = 1;
        } else if (oldReaction == newReaction) {
          // Removing same reaction
          isLiked = false;
          newReaction = ReactionType.NONE;
          likesCountChange = -1;
        } else {
          // Changing reaction type
          isLiked = true;
          likesCountChange = 0; // Already liked, just changing type
        }

        list[index] = post.copyWith(
          isLiked: isLiked,
          currentUserReaction: newReaction,
          likesCount: post.likesCount + likesCountChange,
        );
      }
    }

    updateList(_posts);
    updateList(_userPosts);
    updateList(_taggedPosts);
    notifyListeners();
  }

  // Comment management
  Future<List<Comment>> getComments(int postId) async {
    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';
      return await _repository.getComments(token: token, postId: postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Comment> addComment(int postId, String content) async {
    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';
      final comment = await _repository.addComment(
        token: token,
        postId: postId,
        content: content,
      );
      
      // Update comment count locally
      final index = _posts.indexWhere((p) => p.idPost == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          commentsCount: _posts[index].commentsCount + 1,
        );
        notifyListeners();
      }
      
      return comment;
    } catch (e) {
      rethrow;
    }
  }
}
