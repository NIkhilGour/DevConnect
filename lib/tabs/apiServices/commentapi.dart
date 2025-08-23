import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/tabs/model/comment.dart';

import 'package:devconnect/tabs/model/user.dart';
import 'package:devconnect/tabs/model/userdetails.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  CommentsNotifier(int postId) : super(const AsyncValue.loading()) {
    getallComments(postId);
  }

  Future<void> getallComments(int postId) async {
    state = const AsyncValue.loading();
    final token = await JWTService.gettoken();

    final response = await http.get(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/user/comments/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> result = await jsonDecode(response.body);

      List<Comment> comments = [];
      for (int i = 0; i < result.length; i++) {
        Comment comment = Comment.fromJson(result[i]);
        comments.add(comment);
      }

      state = AsyncValue.data(comments);
    } else {
      state = AsyncValue.error('Failed to fetch comments', StackTrace.current);
    }
  }

  Future<void> addcomment(
    int postId,
    String content,
    UserProfile userProfile,
  ) async {
    final token = await JWTService.gettoken();

    // 1. Create a proper optimistic comment
    final optimisticComment = Comment(
      id: -DateTime.now().millisecondsSinceEpoch, // Negative ID for optimistic
      content: content,
      userProfile: userProfile,

      // Add other required fields with dummy data if needed
    );

    print("🟠 Adding optimistic comment: ${optimisticComment.id}");

    // 2. Update state optimistically
    state = AsyncValue.data([...?state.value, optimisticComment]);

    try {
      final response = await http.post(
        Uri.parse(
            'https://devconnect-backend-2-0c3c.onrender.com/user/comment/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"content": content}),
      );

      if (response.statusCode == 200) {
        final realComment = Comment.fromJson(jsonDecode(response.body));
        print("🟢 Received real comment: ${realComment.id}");

        // 3. Replace optimistic comment with real one
        final updatedList = state.value
                ?.map((c) => c.id == optimisticComment.id ? realComment : c)
                .toList() ??
            [];

        state = AsyncValue.data(updatedList);
        print("🟢 Updated comments: ${updatedList.map((c) => c.id)}");
      } else {
        // 4. Rollback on failure
        final rolledBack =
            state.value?.where((c) => c.id != optimisticComment.id).toList() ??
                [];
        state = AsyncValue.data(rolledBack);
        print("🔴 Failed to add comment, rolled back");
      }
    } catch (e, st) {
      // 5. Rollback on error
      final rolledBack =
          state.value?.where((c) => c.id != optimisticComment.id).toList() ??
              [];
      state = AsyncValue.data(rolledBack);
      print("🔴 Error adding comment: $e, rolled back");
      rethrow;
    }
  }

  Future<void> deletecomment(int commentId) async {
    final token = await JWTService.gettoken();

    final currentState = state;

    List<Comment> currentcomments = [...?currentState.value];

    currentcomments.removeWhere(
      (element) {
        return element.id == commentId;
      },
    );

    state = AsyncValue.data(currentcomments);

    final response = await http.delete(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/user/comment/$commentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<Comment> currentcomments = [...?currentState.value];

      currentcomments.removeWhere(
        (element) {
          return element.id == commentId;
        },
      );

      state = AsyncValue.data(currentcomments);
    } else {
      state = currentState;
    }
  }
}

final commentsProvider = StateNotifierProvider.family<CommentsNotifier,
    AsyncValue<List<Comment>>, int>((ref, postId) {
  final notifier = CommentsNotifier(postId);

  return notifier;
});
