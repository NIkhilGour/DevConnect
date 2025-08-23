import 'package:devconnect/auth/authentication_tab.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/splash_screen.dart';
import 'package:devconnect/tabs/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await JWTService.gettoken();
  print(token);
  runApp(ScreenUtilInit(
      designSize: Size(411.4285, 866.2857),
      child: ProviderScope(
        child: MaterialApp(home: token == null ? AuthenticationTab() : Tabs()),
      )));
}
