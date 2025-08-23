import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/api_url.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:http/http.dart' as http;

Future<void> deletepost(int postId) async {
  try {
    final token = await JWTService.gettoken();

    final response = await http.delete(
      Uri.parse('$apiurl/user/project/$postId'),
      headers: {'Authorization': 'Bearer $token'},
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
