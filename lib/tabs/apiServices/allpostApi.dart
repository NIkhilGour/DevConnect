import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/apiServices/connecttopost.dart';
import 'package:devconnect/tabs/apiServices/deletepostApi.dart';
import 'package:devconnect/tabs/apiServices/likeApi.dart';
import 'package:devconnect/tabs/model/like.dart';
import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ProjectsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  ProjectsNotifier() : super(const AsyncValue.loading()) {
    fetchProjects();
  }

  final Set<int> _processingLikes = {};

  bool isPostProcessing(int postId) => _processingLikes.contains(postId);

  Future<void> fetchProjects() async {
    try {
      final token = await JWTService.gettoken();
      final response = await http.get(
        Uri.parse(
            'https://devconnect-backend-2-0c3c.onrender.com/user/projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> result = jsonDecode(response.body);
        final posts = result.map((e) => Post.fromJson(e)).toList();
        state = AsyncValue.data(posts);
      } else {
        state =
            AsyncValue.error('Failed to fetch projects', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletepostnotifier(int postId) async {
    final currentState = state;

    int index = -1;
    List<Post> posts = [];
    if (currentState is AsyncData<List<Post>>) {
      posts = [...currentState.value];
      index = posts.indexWhere((post) => post.id == postId);
    }
    print(index);
    posts.removeAt(index);
    state = AsyncValue.data(posts);

    try {
      await deletepost(postId);
    } catch (e) {
      state = currentState;
      print(e.toString());
    }
  }

  Future<void> toggleLikePostInNotifier(int postId) async {
    if (_processingLikes.contains(postId)) return;
    _processingLikes.add(postId);

    final currentState = state;

    if (currentState is AsyncData<List<Post>>) {
      final posts = [...currentState.value];
      final index = posts.indexWhere((post) => post.id == postId);
      if (index == -1) {
        _processingLikes.remove(postId);
        return;
      }

      final originalPost = posts[index];
      final userId = await SharedPreferencesService.getInt('userId');
      final alreadyLiked =
          originalPost.likes?.any((like) => like.user?.id == userId) ?? false;

      // Step 1: Optimistic UI update
      final optimisticLikes = [...?originalPost.likes];
      if (alreadyLiked) {
        optimisticLikes.removeWhere((like) => like.user?.id == userId);
      } else {
        optimisticLikes.add(Like(user: User(id: userId))); // dummy like
      }

      final optimisticPost = originalPost.copyWith(
        likes: optimisticLikes,
        likecout: (originalPost.likecout ?? 0) + (alreadyLiked ? -1 : 1),
      );

      posts[index] = optimisticPost;
      state = AsyncValue.data(posts);

      try {
        if (alreadyLiked) {
          print(state.value![index].likecout);
          await unlikePost(postId);
          print("state after unliked");
          print(state.value![index].likecout);
          // ✅ Don't reset state — optimistic update already handled UI
        } else {
          final newLike = await likePost(postId);

          final updatedLikes = [...optimisticLikes]
            ..removeWhere((like) => like.user?.id == userId)
            ..add(newLike);

          posts[index] = optimisticPost.copyWith(
            likes: updatedLikes,
          );

          state = AsyncValue.data(posts);
        }
      } catch (e) {
        // ❌ Revert on failure
        print("something wrong");
        posts[index] = originalPost;
        state = AsyncValue.data(posts);
      } finally {
        _processingLikes.remove(postId);
      }
    } else {
      _processingLikes.remove(postId);
    }
  }

  Future<void> toggleConnectionStatus(int postId) async {
    final currentState = state;
    if (currentState is! AsyncData<List<Post>>) return;

    final posts = [...currentState.value];
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final originalPost = posts[index];
    final currentStatus = originalPost.isconnected;

    // Optimistically update status
    String? optimisticStatus;
    if (currentStatus == null) {
      optimisticStatus = "PENDING";
    } else {
      optimisticStatus = null;
    }

    final updatedPost = originalPost.copyWith(isconnected: optimisticStatus);
    posts[index] = updatedPost;
    state = AsyncValue.data(posts);

    try {
      if (optimisticStatus == "PENDING") {
        await connectToPost(postId);
      } else {}
      // ✅ success, keep optimistic state
    } catch (e) {
      // ❌ failure, revert
      posts[index] = originalPost;
      state = AsyncValue.data(posts);
    }
  }
}

final likeLoadingProvider = Provider.family<bool, int>((ref, postId) {
  return ref.watch(projectsNotifierProvider.notifier).isPostProcessing(postId);
});

final projectsNotifierProvider =
    StateNotifierProvider<ProjectsNotifier, AsyncValue<List<Post>>>(
        (ref) => ProjectsNotifier());
