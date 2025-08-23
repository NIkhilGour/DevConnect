import 'package:cached_network_image/cached_network_image.dart';

import 'package:devconnect/core/colors.dart';
import 'package:devconnect/error_screen.dart';

import 'package:devconnect/splash_screen.dart';
import 'package:devconnect/tabs/apiServices/userdetails.dart';
import 'package:devconnect/tabs/screens/addPost.dart';
import 'package:devconnect/tabs/screens/drawerscreen.dart';
import 'package:devconnect/tabs/screens/groupscreen.dart';
import 'package:devconnect/tabs/screens/homeScreen.dart';
import 'package:devconnect/tabs/screens/postrequestscreen.dart';
import 'package:devconnect/tabs/screens/searchscreen.dart';
import 'package:devconnect/weblayout/webtabs.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Tabs extends ConsumerStatefulWidget {
  const Tabs({super.key});

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<Tabs> {
  final PageController controller = PageController();
  int index = 0;

  Map<String, dynamic>? _postData;

  Future<void> _handleAddPost() async {
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return Addpost();
      },
    ));

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _postData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    final userdata = ref.watch(userdetailsprovider);
    List<Widget> screens = [
      Homescreen(
          publishData: _postData,
          ontap: () {
            _handleAddPost();
          }),
      Groupscreen(
        selectgrouToChat: (group) {},
      )
    ];

    return userdata.when(
      loading: () {
        return SplashScreen();
      },
      error: (error, stackTrace) {
        return ErrorScreen(
          message: 'Unable to load user details',
          onRetry: () {
            ref.refresh(userdetailsprovider);
          },
        );
      },
      data: (data) {
        return isMobile
            ? Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: backgroundcolor,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(),
                          ));
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            'Search',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  leading: Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: data.profilePictureUrl!,
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return Postrequestscreen();
                              },
                            ));
                          },
                          icon: Icon(
                            Icons.person_add,
                            size: 35.r,
                          )),
                    )
                  ],
                ),
                drawer: Drawer(
                  child: Drawerscreen(
                    ontap: () {},
                    isweb: false,
                  ),
                ),
                body: PageView.builder(
                  itemCount: screens.length,
                  controller: controller,
                  physics:
                      NeverScrollableScrollPhysics(), // Prevent swipe navigation
                  itemBuilder: (context, index) => screens[index],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: index,
                  selectedItemColor: seedcolor,
                  onTap: (value) {
                    setState(() {
                      index = value;
                      controller.animateToPage(
                        value,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add, color: Colors.transparent),
                      label: '', // Dummy for center FAB
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.group), label: 'Group'),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(
                    Icons.add,
                  ),
                  onPressed: () {
                    _handleAddPost();
                  },
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
              )
            : WebTabs();
      },
    );
  }
}
