import 'package:devconnect/auth/authentication_tab.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/error_screen.dart';
import 'package:devconnect/tabs/apiServices/allpostApi.dart';
import 'package:devconnect/tabs/apiServices/publishpost.dart';
import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/widgets/postcontainer.dart';
import 'package:devconnect/weblayout/widgets/web_search_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key, required this.ontap, required this.publishData});
  final Function() ontap;
  final Map<String, dynamic>? publishData;

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  int? userId;
  bool _isPublishing = false;
  bool _isCompleted = false;
  bool _hasPublished = false;

  void _loadUserId() async {
    final userid = await SharedPreferencesService.getInt('userId');
    setState(() => userId = userid);
  }

  void _startPublishing(Map data) async {
    setState(() {
      _isPublishing = true;
      _isCompleted = false;
    });

    try {
      await publishPostApi(
        data['description'],
        data['github'],
        data['skills'],
        data['file'],
        context,
      );

      setState(() {
        _isPublishing = false;
        _isCompleted = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isCompleted = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to publish: $e')));
      }
      setState(() {
        _isPublishing = false;
        _isCompleted = false;
      });
    }
  }

  @override
  void initState() {
    _loadUserId();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Homescreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.publishData != null &&
        !_isPublishing &&
        !_isCompleted &&
        !_hasPublished) {
      _hasPublished = true;
      _startPublishing(widget.publishData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    final allpost = ref.watch(projectsNotifierProvider);

    ref.listen<AsyncValue<List<Post>>>(projectsNotifierProvider, (
      prev,
      next,
    ) async {
      next.whenOrNull(
        error: (err, st) async {
          if (err == 'Token expired') {
            await JWTService.deletetoken();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AuthenticationTab();
                  },
                ),
                (route) => false,
              );
            }
          }
        },
      );
    });
    return allpost.when(
      error: (error, _) {
        return ErrorScreen(
          message: 'Unable to load Posts',
          onRetry: () {
            ref.refresh(projectsNotifierProvider);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: seedcolor)),
      data: (post) {
        return Column(
          children: [
            if (!isMobile) WebSearchHeader(),
            SizedBox(height: isMobile ? 10.h : 10),
            if (_isPublishing || _isCompleted)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12.w : 12,
                  vertical: isMobile ? 8.h : 8,
                ),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 12.r : 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 12.r : 12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _isCompleted
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            )
                          : SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: seedcolor,
                              ),
                            ),
                      SizedBox(width: isMobile ? 12.w : 12),
                      Text(
                        _isCompleted ? 'Post published!' : 'Finishing up...',
                        style: TextStyle(
                          fontSize: isMobile ? 16.sp : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              color: Colors.white,
              height: isMobile ? 70.h : 70,
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 10.r : 10),
              child: GestureDetector(
                onTap: widget.ontap,
                child: Container(
                  height: isMobile ? 40.h : 40,
                  decoration: BoxDecoration(
                    color: backgroundcolor,
                    borderRadius: BorderRadius.circular(isMobile ? 10.r : 10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12.r : 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_square, color: seedcolor),
                          SizedBox(width: isMobile ? 10.w : 10),
                          Text(
                            'Start a post',
                            style: TextStyle(fontSize: isMobile ? 20.sp : 20),
                          ),
                        ],
                      ),
                      Icon(Icons.language_outlined, color: seedcolor),
                    ],
                  ),
                ),
              ),
            ),
            post.isEmpty
                ? const Center(child: Text('No Project Available'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: post.length,
                      itemBuilder: (context, index) {
                        return Postcontainer(
                          onConnect: () => ref
                              .watch(projectsNotifierProvider.notifier)
                              .toggleConnectionStatus(post[index].id!, context),
                          onComment: () {},
                          onLike: () => ref
                              .watch(projectsNotifierProvider.notifier)
                              .toggleLikePostInNotifier(post[index].id!),
                          isliking: ref.watch(
                            likeLoadingProvider(post[index].id!),
                          ),
                          isLiked:
                              post[index].likes?.any(
                                (like) => like.user?.id == userId,
                              ) ??
                              false,
                          post: post[index],
                        );
                      },
                    ),
                  ),
          ],
        );
      },
    );
  }
}
