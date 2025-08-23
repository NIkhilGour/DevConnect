import 'package:devconnect/core/jwtservice.dart';
import 'package:http/http.dart' as http;

Future<void> connectToPost(int postId) async {
  final token = await JWTService.gettoken();
  final response = await http.post(
    Uri.parse('https://devconnect-backend-2-0c3c.onrender.com/request/$postId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print(response.statusCode);

  if (response.statusCode != 200) {
    throw Exception("Failed to connect to post");
  }
}
