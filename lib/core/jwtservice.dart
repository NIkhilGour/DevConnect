import 'package:devconnect/auth/authentication_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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

  static bool isExpired(String token) {
    bool isTokenExpired = JwtDecoder.isExpired(token);
    return isTokenExpired;
  }

  static Future<void> validateTokenAndRedirect(context, String token) async {
    if (isExpired(token)) {
      await deletetoken();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login again to continue')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AuthenticationTab();
          },
        ),
        (route) => false,
      );
    }
  }

  static Future<void> redirect(context) async {
    await deletetoken();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Please login again to continue')));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AuthenticationTab();
        },
      ),
      (route) => false,
    );
  }
}
