import 'dart:math';

import 'package:devconnect/auth/apiServices/loginApi.dart';
import 'package:devconnect/auth/userdetails.dart';
import 'package:devconnect/auth/widgets/textfield_widget.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.onClick});
  final VoidCallback onClick;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errormsg = '';
  bool isauthenticating = false;

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isauthenticating = true);

      try {
        final response =
            await login(emailcontroller.text, passwordcontroller.text);

        if (response == null) {
          setState(() {
            isauthenticating = false;
            errormsg = 'Login Failed';
          });
        } else {
          setState(() => isauthenticating = false);
          if (response['isnewuser'] == true) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Userdetails(token: response['jwt']),
                ));
          } else {
            await SharedPreferencesService.setInt('userId', response['id']);
            await JWTService.addtoken(response['jwt']);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => Tabs(),
                ),
                (route) => false);
          }
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          isauthenticating = false;
          errormsg = "Something went Wrong";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    Widget loginWidget = Container(
      height: isMobile ? 500.h : 500,
      width: isMobile ? screenWidth * 0.8 : 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        gradient: LinearGradient(
          colors: [Color(0xFFCCC6E6), Colors.white, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: isMobile ? 25.h : 25),
            Container(
              height: isMobile ? 50.h : 50,
              width: isMobile ? 50.w : 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.globe,
                size: isMobile ? 40.r : 40,
                color: seedcolor,
              ),
            ),
            Text(
              'Welcome back',
              style: GoogleFonts.redHatText(
                fontSize: isMobile ? 25.sp : 25,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Please enter your details to sign in',
              style: TextStyle(fontSize: isMobile ? 14.sp : 14),
            ),
            SizedBox(height: isMobile ? 10.h : 10),
            TextfieldWidget(
              title: 'Email address',
              subtitle: 'Enter your email',
              controller: emailcontroller,
              validator: _emailValidator,
            ),
            TextfieldWidget(
              title: 'Password',
              subtitle: 'Enter password',
              controller: passwordcontroller,
              validator: _passwordValidator,
              obscureText: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('Forgot password?'),
              ),
            ),
            Padding(
              padding: isMobile ? EdgeInsets.all(8.0.r) : EdgeInsets.all(8),
              child: isauthenticating
                  ? CircularProgressIndicator(color: seedcolor)
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(seedcolor),
                        minimumSize: WidgetStatePropertyAll(
                          Size(double.infinity, isMobile ? 48.h : 48),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text('Sign in',
                          style: TextStyle(color: Colors.white)),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: widget.onClick,
                  child: Text('Create an account',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: seedcolor)),
                ),
              ],
            ),
            if (errormsg.isNotEmpty)
              Text(errormsg, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );

    return isMobile
        ? Center(child: loginWidget)
        : Row(
            spacing: 20,
            children: [
              // ------------ LEFT PANEL (web only) ------------
              Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF7F7FD5),
                        Color(0xFF86A8E7),
                        Color(0xFF91EAE4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.globe,
                            color: Colors.white, size: 70),
                        SizedBox(height: 20),
                        Text(
                          'DevConnect',
                          style: GoogleFonts.redHatDisplay(
                            fontSize: 38,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Connect • Collaborate • Grow',
                          style: GoogleFonts.redHatText(
                              fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ------------- LOGIN CARD (same) --------------
              Expanded(
                flex: 2,
                child: Center(child: loginWidget),
              ),
            ],
          );
  }
}
