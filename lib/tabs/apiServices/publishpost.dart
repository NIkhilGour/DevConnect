import 'dart:convert';
import 'dart:io';
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
  File? file,
) async {
  final token = await JWTService.gettoken();

  final uri =
      Uri.parse('https://devconnect-backend-2-0c3c.onrender.com/user/post');
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
    final mimeType = lookupMimeType(file.path);
    request.files.add(
      http.MultipartFile(
          'file', http.ByteStream(file.openRead()), await file.length(),
          filename: basename(file.path),
          contentType: MediaType.parse(mimeType!)),
    );
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
