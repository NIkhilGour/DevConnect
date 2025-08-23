import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';

import 'package:devconnect/tabs/model/group.dart';
import 'package:http/http.dart' as http;

Future<Group> createGroup(int postId, String name) async {
  try {
    final token = await JWTService.gettoken();

    final response = await http.post(
        Uri.parse(
            'https://devconnect-backend-2-0c3c.onrender.com/group/create/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({"name": name}));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      Group group = Group.fromJson(result);

      return group;
    } else {
      throw Error();
    }
  } catch (e, st) {
    throw AsyncError(e, st);
  }
}
