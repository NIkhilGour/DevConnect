import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/model/group.dart';
import 'package:http/http.dart' as http;

Future<List<Group>> getJoinedGroups() async {
  try {
    final token = await JWTService.gettoken();
    final userid =
        await SharedPreferencesService.getInt('userId'); // Cache this
    final response = await http.get(
      Uri.parse('https://devconnect-backend-2-0c3c.onrender.com/group/$userid'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> result = jsonDecode(response.body);
      print(result);
      final List<Group> groups = [];
      for (int i = 0; i < result.length; i++) {
        Group group = Group.fromJson(result[i]);
        groups.add(group);
      }

      return groups;
    } else {
      throw Error();
    }
  } catch (e, st) {
    throw AsyncError(e, st);
  }
}
