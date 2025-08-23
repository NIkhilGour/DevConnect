import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/model/userdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final userdetailsprovider = FutureProvider<UserProfile>(
  (ref) async {
   return  getUserProfie();
  }
);

Future<UserProfile> getUserProfie() async{
  final token = await JWTService.gettoken();
    final id = await SharedPreferencesService.getInt('userId');
    final response = await http.get(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/user/userdetails/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = await jsonDecode(response.body);
      final UserProfile userProfile = UserProfile.fromJson(result);
      return userProfile;
    } else {
      throw Exception('Failed to fetch userdata');
    }
  }


Future<UserProfile> getOtherUserDetails(int userId,BuildContext context) async {
  final token = await JWTService.gettoken();
  if (context.mounted) {
    JWTService.validateTokenAndRedirect(context, token!);
  }
  final response = await http.get(
    Uri.parse(
        'https://devconnect-backend-2-0c3c.onrender.com/user/userdetails/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> result = await jsonDecode(response.body);
    final UserProfile userProfile = UserProfile.fromJson(result);
    return userProfile;
  } else {
    throw Exception('Failed to fetch userdata');
  }
}
