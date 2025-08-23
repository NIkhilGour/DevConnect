import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/tabs/model/group.dart';
import 'package:http/http.dart' as http;

Future<Group> joinGroupApi(int groupId, int userId) async {
  try {
    final token = await JWTService.gettoken();

    final response = await http.post(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/group/join/$groupId/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

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
