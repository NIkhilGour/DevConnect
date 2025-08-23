import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/user.dart';
import 'package:devconnect/tabs/model/userdetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

Future<List<UserProfile>> searchUser(String keyword) async {
  final token = await JWTService.gettoken();

  try {
    final response = await http.get(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/search/user?keyword=$keyword'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      List<UserProfile> userProfileList = [];

      for (int i = 0; i < result.length; i++) {
        UserProfile userProfile = UserProfile.fromJson(result[i]);
        userProfileList.add(userProfile);
      }

      return userProfileList;
    } else {
      throw Error();
    }
  } catch (e) {
    throw Error();
  }
}

Future<List<Post>> searchPost(String keyword) async {
  final token = await JWTService.gettoken();

  try {
    final response = await http.get(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/search/post?keyword=$keyword'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final result = await jsonDecode(response.body);
      List<Post> postlist = [];

      for (int i = 0; i < result.length; i++) {
        Post post = Post.fromJson(result[i]);
        postlist.add(post);
      }

      return postlist;
    } else {
      throw Error();
    }
  } catch (e) {
    throw Error();
  }
}
