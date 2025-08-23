import 'dart:convert';
import 'package:devconnect/auth/model/skill.dart';
import 'package:http/http.dart' as http;

Future<List<Skill>?> getAllSkills(String token) async {
  try {
    final response = await http.get(
      Uri.parse('https://devconnect-backend-2-0c3c.onrender.com/user/skills'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> result = jsonDecode(response.body);
      return result.map((e) => Skill.fromJson(e)).toList();
    }

    return null;
  } catch (e) {
    throw Exception('Failed to load skills: $e');
  }
}
