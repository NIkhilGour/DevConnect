import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';

import 'package:devconnect/tabs/model/group.dart';
import 'package:http/http.dart' as http;

Future<void> leaveGroup(int groupId, int userId) async {
  try {
    final token = await JWTService.gettoken();

    final response = await http.delete(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/group/remove/$groupId/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
    } else {
      throw Error();
    }
  } catch (e, st) {
    throw AsyncError(e, st);
  }
}
