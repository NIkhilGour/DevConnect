import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';

import 'package:devconnect/tabs/model/like.dart';
import 'package:http/http.dart' as http;

Future<Like> likePost(int postId) async {
  final token = await JWTService.gettoken();

  final response = await http.post(
    Uri.parse(
        'https://devconnect-backend-2-0c3c.onrender.com/user/like/$postId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> result = await jsonDecode(response.body);
    final Like like = Like.fromJson(result);
    return like;
  } else {
    throw Exception('Failed to like ');
  }
}

Future<void> unlikePost(int postId) async {
  final token = await JWTService.gettoken();

  final response = await http.delete(
    Uri.parse(
        'https://devconnect-backend-2-0c3c.onrender.com/user/like/$postId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
  } else {
    throw Exception('Failed to unlike ');
  }
}
