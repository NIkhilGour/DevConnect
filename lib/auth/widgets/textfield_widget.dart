import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextfieldWidget extends StatelessWidget {
  const TextfieldWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.validator,
    this.obscureText = false,
  });

  final String title;
  final String subtitle;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.r, left: 16.r, right: 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.r)),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                validator: validator,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8.r),
                  hintText: subtitle,
                  border:
                      const UnderlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
