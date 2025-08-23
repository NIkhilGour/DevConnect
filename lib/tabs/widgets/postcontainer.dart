import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/apiServices/allpostApi.dart';

import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/screens/profilescren.dart';

import 'package:devconnect/tabs/widgets/commentscontainer.dart';

import 'package:devconnect/tabs/widgets/exapandabletext.dart';
import 'package:devconnect/tabs/widgets/moreoptionspostcontainer.dart';
import 'package:devconnect/tabs/widgets/skillsandgithubcontainer.dart';
import 'package:devconnect/tabs/widgets/videocontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Postcontainer extends ConsumerStatefulWidget {
  const Postcontainer(
      {super.key,
      required this.post,
      required this.onConnect,
      required this.onLike,
      required this.onComment,
      required this.isliking,
      required this.isLiked});
  final Post post;
  final Function() onConnect;
  final Function() onLike;
  final Function() onComment;
  final bool isliking;
  final bool isLiked;
  @override
  ConsumerState<Postcontainer> createState() => _PostcontainerState();
}

class _PostcontainerState extends ConsumerState<Postcontainer> {
  int? currentUserId;
  bool isProcessing = false;
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await SharedPreferencesService.getInt('userId');
    setState(() {
      currentUserId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ismobile = screenWidth < 800;
    return Padding(
      padding:
          EdgeInsets.only(top: ismobile ? 5.h : 5, bottom: ismobile ? 5.h : 5),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ProfileScreen(
                                    userid: widget.post.userProfile!.user!.id!);
                              },
                            ));
                          },
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(15), // Not fully circular
                            child: CachedNetworkImage(
                              imageUrl:
                                  widget.post.userProfile!.profilePictureUrl!,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(ismobile ? 8.r : 8),
                        child: SizedBox(
                          width: ismobile ? 130.w : 130,
                          child: Text(
                            widget.post.userProfile!.name!,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: ismobile ? 18.sp : 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SkillsAndGithubContainer(
                                  skills: widget.post.techSkills!,
                                  github: widget.post.github!,
                                );
                              },
                            );
                          },
                          icon: Image.asset(
                            'assets/icons/solution.png',
                            height: ismobile ? 27.h : 27,
                            width: ismobile ? 27.w : 27,
                            color: Colors.orange,
                          ))
                    ],
                  ),
                  if (widget.post.userProfile!.user!.id != currentUserId)
                    Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Container(
                          height: ismobile ? 40.h : 40,
                          width: ismobile ? 80.w : 80,
                          decoration: BoxDecoration(
                              color: Color(0xFF876FE8).withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(ismobile ? 12.r : 12)),
                          child: GestureDetector(
                            onTap: widget.onConnect,
                            child: Center(
                              child: widget.post.isconnected == null
                                  ? Text(
                                      'Connect',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: seedcolor),
                                    )
                                  : widget.post.isconnected == 'APPROVED'
                                      ? null
                                      : Icon(
                                          Icons.pending_outlined,
                                          color: seedcolor,
                                          size: ismobile ? 25.r : 25,
                                        ),
                            ),
                          ),
                        )),
                  SizedBox(
                    width: ismobile ? 5.w : 5,
                  ),
                  IconButton(
                    key: const ValueKey(
                        "moreOptionsBtn"), // give it a key to find later
                    onPressed: () {
                      if (ismobile) {
                        // Mobile -> bottom sheet
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Moreoptionspostcontainer(
                              post: widget.post,
                              userId: currentUserId!,
                              ondelete: () {
                                ref
                                    .watch(projectsNotifierProvider.notifier)
                                    .deletepostnotifier(widget.post.id!,context);
                              },
                            );
                          },
                        );
                      } else {
                        // Desktop -> popup menu aligned to button
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final RenderBox overlay = Overlay.of(context)
                            .context
                            .findRenderObject() as RenderBox;

                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(Offset.zero,
                                ancestor: overlay),
                            button.localToGlobal(
                                button.size.bottomRight(Offset(0.2, 0.1)),
                                ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );

                        showMenu(
                          context: context,
                          position: position,
                          items: [
                            PopupMenuItem(
                              padding: EdgeInsets.zero,
                              child: Moreoptionspostcontainer(
                                post: widget.post,
                                userId: currentUserId!,
                                ondelete: () {
                                  ref
                                      .watch(projectsNotifierProvider.notifier)
                                      .deletepostnotifier(widget.post.id!,context);
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                    icon: const Icon(Icons.more_vert_outlined),
                  )
                ]),
            Padding(
              padding: EdgeInsets.all(ismobile ? 8.r : 8),
              child: ExpandableText(
                trimLength: ismobile ? 100 : 200,
                text: widget.post.description!,
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
            ),
            if (widget.post.fileUrl != null)
              Padding(
                padding: EdgeInsets.only(
                    top: ismobile ? 8.h : 8, bottom: ismobile ? 8.h : 8),
                child: widget.post.fileType!.contains('image')
                    ? Center(
                        child: CachedNetworkImage(
                          imageUrl: widget.post.fileUrl!,
                          height: ismobile ? 300.h : 300,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Videocontainer(url: widget.post.fileUrl!),
              ),
            SizedBox(
              height: ismobile ? 5.h : 5,
            ),
            Container(
              height: ismobile ? 1.h : 1,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: ismobile ? 16.w : 16,
                  right: ismobile ? 16.w : 16,
                  top: ismobile ? 8.h : 8,
                  bottom: ismobile ? 8.h : 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.isliking ? null : widget.onLike,
                    child: Column(
                      children: [
                        Icon(
                          widget.isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_off_alt_outlined,
                          size: ismobile ? 20.r : 20,
                          color: widget.isLiked ? seedcolor : Colors.black,
                          fill: widget.isLiked ? 1 : 0,
                        ),
                        Row(
                          children: [
                            Text(
                              'Like',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            widget.post.likecout! > 0
                                ? Text(widget.post.likecout.toString())
                                : SizedBox()
                          ],
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ismobile
                          ? showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    child: DraggableScrollableSheet(
                                      initialChildSize: 0.50,
                                      minChildSize: 0.5,
                                      maxChildSize: 0.95,
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return Commentscontainer(
                                            postId: widget.post.id!,
                                            scrollController: scrollController);
                                      },
                                    ));
                              },
                            )
                          : showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  alignment: Alignment.bottomRight,
                                  child: SizedBox(
                                    width: 500,
                                    child: DraggableScrollableSheet(
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return Commentscontainer(
                                            postId: widget.post.id!,
                                            scrollController: scrollController);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: ismobile ? 20.r : 20,
                        ),
                        Text(
                          'Comment',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
