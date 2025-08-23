import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<Map<dynamic, dynamic>?> setUserDetails({
  required Map<String, dynamic> userProfile,
  File? profilePictureFile,
  required String token,
}) async {
  final uri = Uri.parse(
      'https://devconnect-backend-2-0c3c.onrender.com/user/userdetails');
  final request = http.MultipartRequest('POST', uri);

  // Add Authorization header if needed
  request.headers['Authorization'] = 'Bearer $token';

  // Add userProfile as a JSON part
  request.files.add(http.MultipartFile.fromString(
    'userProfile',
    jsonEncode(userProfile),
    contentType: MediaType('application', 'json'),
    filename: 'userProfile.json',
  ));

  // Add image if available
  if (profilePictureFile != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'profilepicture',
      profilePictureFile.path,
    ));
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}
