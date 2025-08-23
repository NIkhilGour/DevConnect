import 'package:devconnect/core/colors.dart';
import 'package:devconnect/weblayout/widgets/side_panel_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sidepanel extends StatefulWidget {
  const Sidepanel(
      {super.key, required this.goToPage, required this.showAddpostline});
  final Function(int index, bool isAddPost) goToPage;
  final bool showAddpostline;
  @override
  State<Sidepanel> createState() => _SidepanelState();
}

class _SidepanelState extends State<Sidepanel> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final islesswidth = width < 1000;
    return Container(
      width: islesswidth ? 150 : 250,
      color: backgroundcolor,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          SidePanelTab(
            icon: Icons.home,
            showline: index == 0,
            name: 'Home',
            ontap: () {
              setState(() {
                index = 0;
              });
              widget.goToPage(0, false);
            },
          ),
          SidePanelTab(
            icon: Icons.collections,
            showline: index == 1,
            name: 'Posts',
            ontap: () {
              setState(() {
                index = 1;
              });
              widget.goToPage(1, false);
            },
          ),
          SidePanelTab(
            icon: Icons.add,
            name: 'Add Post',
            showline: index == 2 && widget.showAddpostline,
            ontap: () {
              setState(() {
                index = 2;
              });
              widget.goToPage(2, true);
            },
          ),
          SidePanelTab(
            icon: Icons.group,
            showline: index == 3,
            name: 'Groups',
            ontap: () {
              setState(() {
                index = 3;
              });
              widget.goToPage(3, false);
            },
          ),
          SidePanelTab(
            icon: Icons.person,
            name: 'Profile',
            showline: index == 4,
            ontap: () {
              setState(() {
                index = 4;
              });
              widget.goToPage(4, false);
            },
          ),
        ],
      ),
    );
  }
}
