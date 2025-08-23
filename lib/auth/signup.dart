import 'dart:async';

import 'package:devconnect/auth/apiServices/signupApi.dart';
import 'package:devconnect/auth/userdetails.dart';
import 'package:devconnect/auth/widgets/textfield_widget.dart';
import 'package:devconnect/core/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  const Signup({super.key, required this.onClick});
  final void Function() onClick;

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailcontroller = TextEditingController();

  final TextEditingController passwordcontroller = TextEditingController();

  String errormsg = '';

  bool isauthenticating = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void signup(String email, String password) async {
    setState(() {
      isauthenticating = true;
    });

    try {
      final response = await signupApi(email, password);

      if (response == null) {
        setState(() {
          isauthenticating = false;
          errormsg = 'Failed to create account';
        });
      } else {
        setState(() {
          isauthenticating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account Create Please login to continue')),
          );
        }
      }
    } catch (e) {
      setState(() {
        isauthenticating = false;
        errormsg = "Something Went Wrong";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    final Widget signUpWigdet = SingleChildScrollView(
      child: Container(
        height: isMobile ? 500.h : 500,
        width: isMobile ? screenWidth * 0.8 : 450,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 204, 198, 230),
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'Welcome',
                style: GoogleFonts.redHatText(
                  fontSize: isMobile ? 25.sp : 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Please enter your details to create',
                style: TextStyle(fontSize: isMobile ? 14.sp : 14),
              ),
              SizedBox(height: isMobile ? 10.h : 10),
              TextfieldWidget(
                title: 'Email address',
                subtitle: 'Enter your email',
                controller: emailcontroller,
                validator: validateEmail,
              ),
              TextfieldWidget(
                title: 'Password',
                subtitle: 'Enter password',
                controller: passwordcontroller,
                obscureText: true,
                validator: validatePassword,
              ),
              SizedBox(height: isMobile ? 20.h : 20),
              Padding(
                padding: EdgeInsets.all(isMobile ? 8.0.r : 8),
                child: isauthenticating
                    ? CircularProgressIndicator(color: seedcolor)
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(seedcolor),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signup(
                              emailcontroller.text,
                              passwordcontroller.text,
                            );
                          }
                        },
                        child: Center(
                          child: Text(
                            'Sign up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? '),
                  GestureDetector(
                    onTap: widget.onClick,
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: seedcolor,
                      ),
                    ),
                  ),
                ],
              ),
              if (errormsg != '')
                Text(errormsg, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );

    return isMobile
        ? signUpWigdet
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
                        Icon(
                          CupertinoIcons.globe,
                          color: Colors.white,
                          size: 70,
                        ),
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
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ------------- LOGIN CARD (same) --------------
              Expanded(flex: 2, child: Center(child: signUpWigdet)),
            ],
          );
  }
}
