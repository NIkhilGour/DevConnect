import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/screens/addPost.dart';
import 'package:devconnect/tabs/screens/drawerscreen.dart';
import 'package:devconnect/tabs/screens/groupscreen.dart';
import 'package:devconnect/tabs/screens/homeScreen.dart';
import 'package:devconnect/tabs/screens/postrequestscreen.dart';
import 'package:devconnect/tabs/screens/profilescren.dart';
import 'package:devconnect/tabs/screens/searchscreen.dart';
import 'package:devconnect/weblayout/webscreens/web_group_page.dart';
import 'package:devconnect/weblayout/widgets/sidepanel.dart';
import 'package:devconnect/weblayout/widgets/web_add_post.dart';
import 'package:flutter/material.dart';

class WebTabs extends StatefulWidget {
  const WebTabs({super.key});

  @override
  State<WebTabs> createState() => _WebTabsState();
}

class _WebTabsState extends State<WebTabs> {
  int? userId;
  int addpostIndex = 0;
  final PageController pageController = PageController(initialPage: 0);

  Map<String, dynamic>? _postData;

  Future<void> _handleAddPost() async {
    final result = await showDialog(
      fullscreenDialog: false,
      context: context,
      builder: (context) {
        return Dialog(alignment: Alignment.topCenter, child: WebAddPost());
      },
    );

    if (addpostIndex == 1) {
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );

      setState(() {
        addpostIndex = 0;
      });
    }
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _postData = result;
      });
    }
  }

  void _loadUserId() async {
    final userid = await SharedPreferencesService.getInt('userId');
    setState(() => userId = userid);
  }

  @override
  void initState() {
    _loadUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final islesswidth = width < 1000;
    List<Widget> widgets = [
      Homescreen(
        ontap: () {
          _handleAddPost();
        },
        publishData: _postData,
      ),
      Text('This is Post Screen'),
      Text('This is Add Post Screen'),
      WebGroupPage(),
      ProfileScreen(userid: userId!),
    ];
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// left side panel
          Sidepanel(
            goToPage: (index, isAddPost) {
              if (isAddPost) {
                setState(() {
                  addpostIndex = 1;
                });
                _handleAddPost();
              } else {
                print(index);
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease,
                );
              }
            },
            showAddpostline: addpostIndex == 1 ? true : false,
          ),
          // main feed
          Expanded(
            flex: 3, // gives more space
            child: PageView.builder(
              controller: pageController,
              itemCount: widgets.length,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Center(
                  child: Container(
                    color: const Color(0xfff5f5f5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 25,
                    ),
                    child: widgets[index],
                  ),
                );
              },
            ),
          ),

          /// right suggestion/drawer panel
          SizedBox(
            width: islesswidth ? 190 : 250,
            child: Drawerscreen(
              isweb: true,
              ontap: () {
                pageController.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
