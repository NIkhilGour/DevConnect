import 'package:devconnect/core/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/retry.dart';

class SidePanelTab extends StatelessWidget {
  const SidePanelTab(
      {super.key,
      required this.icon,
      required this.name,
      required this.ontap,
      required this.showline});
  final IconData icon;
  final String name;
  final Function() ontap;
  final bool showline;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          spacing: 5,
          children: [
            showline
                ? Container(
                    height: 20,
                    width: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: seedcolor),
                  )
                : SizedBox(
                    width: 4,
                  ),
            Row(
              spacing: 10,
              children: [
                Icon(
                  icon,
                  color: showline ? seedcolor : Colors.black,
                ),
                Text(
                  name,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 18),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
