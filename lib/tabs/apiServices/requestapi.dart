import 'dart:async';
import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/model/request.dart';

import 'package:http/http.dart' as http;

Future<List<Request>> getAllRequest() async {
  final token = await JWTService.gettoken();
  final userId = await SharedPreferencesService.getInt('userId');

  try {
    final response = await http.get(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/request/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      List<Request> req = [];
      for (int i = 0; i < result.length; i++) {
        final Request r = Request.fromJson(result[i]);
        req.add(r);
      }

      return req;
    } else {
      throw Error();
    }
  } catch (e, st) {
    throw AsyncError(e, st);
  }
}

Future<void> acceptrequest(int requestId) async {
  final token = await JWTService.gettoken();

  try {
    final response = await http.put(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/request/$requestId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Error();
    }
  } catch (e, st) {
    throw AsyncError(e, st);
  }
}

Future<void> deleterequest(int requestId) async {
  final token = await JWTService.gettoken();

  try {
    final response = await http.delete(
      Uri.parse(
          'https://devconnect-backend-2-0c3c.onrender.com/request/$requestId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
    } else {
      throw Error();
    }
  } catch (e, st) {
    throw AsyncError(e, st);
  }
}
