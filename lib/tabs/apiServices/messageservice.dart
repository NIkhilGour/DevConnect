import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/tabs/model/message.dart';
import 'package:http/http.dart' as http;

class MessageService {
  static const _base = 'https://devconnect-backend-2-0c3c.onrender.com';

  static Future<List<Message>> getMessagesByGroupId(int groupId) async {
    final token = await JWTService.gettoken();
    final res = await http.get(
      Uri.parse('$_base/group/$groupId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) throw Exception('Failed to load messages');
    final data = jsonDecode(res.body) as List;
    return data
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // static Future<Message> sendMessageToGroup(String groupId, Message msg) async {
  //   final res = await http.post(
  //     Uri.parse('$_base/messages/$groupId'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(msg.toJson()),
  //   );
  //   if (res.statusCode != 200 && res.statusCode != 201) {
  //     throw Exception('Failed to send message');
  //   }
  //   return Message.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  // }
}
