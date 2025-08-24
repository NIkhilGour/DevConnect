import 'dart:convert';
import 'dart:io';
import 'package:devconnect/core/api_url.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/skill.dart';

Future<Post> publishPostApi(
  String description,
  String github,
  List<Skill> skills,
  dynamic file,
) async {
  final token = await JWTService.gettoken();

  final uri = Uri.parse('$apiurl/user/post');
  final request = http.MultipartRequest('POST', uri);

  request.headers['Authorization'] = 'Bearer $token';

  final postMap = {
    'description': description,
    'github': github,
    'techSkills': skills.map((e) => e.toJson()).toList(),
  };

  print(jsonEncode(postMap));

  request.files.add(
    http.MultipartFile.fromString(
      'post',
      jsonEncode(postMap),
      contentType: MediaType('application', 'json'),
    ),
  );

  if (file != null) {
    if (kIsWeb) {
      // Web: use bytes directly

      final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes,
          filename: file.name,
          contentType: MediaType.parse(mimeType),
        ),
      );
    } else {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }
  }

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final result = jsonDecode(respStr);
    return Post.fromJson(result);
  } else {
    final error = await response.stream.bytesToString();
    print(error);
    throw Exception('Failed to publish post: $error');
  }
}
