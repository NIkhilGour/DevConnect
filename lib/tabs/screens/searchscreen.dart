import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/apiServices/allpostApi.dart';
import 'package:devconnect/tabs/apiServices/searapi.dart';
import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/userdetails.dart';
import 'package:devconnect/tabs/screens/profilescren.dart';
import 'package:devconnect/tabs/widgets/postcontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool isSearchingUser = false;
  bool isSearchingPost = false;
  int? userId;
  List<Post>? post;
  List<UserProfile>? userProfile;
  @override
  void initState() {
    super.initState();
    _loadUserId();
    _tabController = TabController(length: 2, vsync: this);
    // Auto focus when screen opens
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadUserId() async {
    final userid =
        await SharedPreferencesService.getInt('userId'); // Cache this
    setState(() {
      userId = userid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 800;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(isMobile ? Icons.arrow_back : Icons.close)),
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search posts or users...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) async {
                    final currentTab = _tabController.index;
                    if (currentTab == 0) {
                      setState(() {
                        isSearchingPost = true;
                      });

                      List<Post> postlist = await searchPost(_controller.text);

                      setState(() {
                        isSearchingPost = false;
                        post = postlist;
                      });
                    } else {
                      setState(() {
                        isSearchingUser = true;
                      });

                      List<UserProfile> userlist =
                          await searchUser(_controller.text,context);

                      setState(() {
                        isSearchingUser = false;
                        userProfile = userlist;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isSearchingPost
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : post != null
                  ? post!.isEmpty
                      ? Center(
                          child: Text('Nothing to show'),
                        )
                      : ListView.builder(
                          itemCount: post!.length,
                          itemBuilder: (context, index) {
                            return Postcontainer(
                              onConnect: () {
                                ref
                                    .watch(projectsNotifierProvider.notifier)
                                    .toggleConnectionStatus(post![index].id!,context);
                              },
                              onComment: () {},
                              onLike: () {
                                ref
                                    .watch(projectsNotifierProvider.notifier)
                                    .toggleLikePostInNotifier(post![index].id!);
                              },
                              isliking: ref
                                  .watch(likeLoadingProvider(post![index].id!)),
                              isLiked: post![index].likes?.any(
                                      (like) => like.user?.id == userId) ??
                                  false,
                              post: post![index],
                            );
                          },
                        )
                  : Center(child: Text("Post search results go here")),
          isSearchingUser
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : userProfile != null
                  ? userProfile!.isEmpty
                      ? Center(
                          child: Text('Nothing to show'),
                        )
                      : ListView.builder(
                          itemCount: userProfile!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ProfileScreen(
                                          userid:
                                              userProfile![index].user!.id!);
                                    },
                                  ));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30.r,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              userProfile![index]
                                                  .profilePictureUrl!),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userProfile![index].name!,
                                            style: GoogleFonts.poppins(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            userProfile![index].bio!,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                  : Center(child: Text("User search results go here")),
        ],
      ),
    );
  }
}
