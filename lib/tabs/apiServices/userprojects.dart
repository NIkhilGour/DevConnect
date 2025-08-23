import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/tabs/model/post.dart';
import 'package:http/http.dart' as http;

Future<List<Post>> fetchUserProjects(int userId) async {
  try {
    final token = await JWTService.gettoken();
    final response = await http.get(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/user/userProjects/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> result = jsonDecode(response.body);
      final posts = result.map((e) => Post.fromJson(e)).toList();
      return posts;
    } else {
      throw Error();
    }
  } catch (e, st) {
    throw AsyncError(e, st);
  }
}
