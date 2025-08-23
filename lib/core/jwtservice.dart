import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JWTService {
  static final storage = FlutterSecureStorage();

  static Future<void> addtoken(String token) async {
    await storage.write(key: 'jwt', value: token);
  }

  static Future<void> deletetoken() async {
    await storage.delete(key: 'jwt');
  }

  static Future<String?> gettoken() async {
    String? token = await storage.read(key: 'jwt');

    return token;
  }
}
