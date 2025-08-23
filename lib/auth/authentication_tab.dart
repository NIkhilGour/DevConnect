import 'dart:math';

import 'package:devconnect/auth/login.dart';
import 'package:devconnect/auth/signup.dart';
import 'package:devconnect/core/colors.dart';
import 'package:flutter/material.dart';

class AuthenticationTab extends StatefulWidget {
  const AuthenticationTab({super.key});

  @override
  State<AuthenticationTab> createState() => _AuthenticationTabState();
}

class _AuthenticationTabState extends State<AuthenticationTab> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundcolor,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final flipAnimation = Tween(begin: pi, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: flipAnimation,
              child: child,
              builder: (context, child) {
                final isUnder = (ValueKey(isLogin) != child?.key);
                final value = isUnder
                    ? min(flipAnimation.value, pi / 2)
                    : flipAnimation.value;
                return Transform(
                  transform: Matrix4.rotationY(value),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          child: isLogin
              ? Login(
                  onClick: () {
                    setState(() {
                      isLogin = false;
                    });
                  },
                )
              : Signup(
                  onClick: () {
                    setState(() {
                      isLogin = true;
                    });
                  },
                ),
        ),
      ),
    );
  }
}
