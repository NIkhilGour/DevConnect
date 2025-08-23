import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/apiServices/commentapi.dart';
import 'package:devconnect/tabs/model/comment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Commentslistcontainer extends ConsumerStatefulWidget {
  const Commentslistcontainer(
      {super.key, required this.comments, required this.postId});
  final Comment comments;
  final int postId;

  @override
  ConsumerState<Commentslistcontainer> createState() =>
      _CommentslistcontainerState();
}

class _CommentslistcontainerState extends ConsumerState<Commentslistcontainer> {
  int? userid;

  @override
  void initState() {
    loaduser();
    super.initState();
  }

  void loaduser() async {
    final user = await SharedPreferencesService.getInt('userId');

    setState(() {
      userid = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 20.r : 20),
              child: CachedNetworkImage(
                  height: isMobile ? 40.h : 40,
                  width: isMobile ? 40.h : 40,
                  fit: BoxFit.cover,
                  imageUrl: widget.comments.userProfile!.profilePictureUrl!),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: isMobile ? 10.w : 10, right: isMobile ? 10.w : 10),
              child: SizedBox(
                width: isMobile ? 270.w : 270,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comments.userProfile!.name!,
                      style: TextStyle(
                          fontSize: isMobile ? 16.sp : 16,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.comments.userProfile!.bio!,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: isMobile ? 5.h : 5,
                    ),
                    Text(
                      widget.comments.content!,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 16.sp : 16),
                    )
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              color: const Color.fromARGB(197, 0, 0, 0),
              onSelected: (value) {
                if (value == 'delete') {
                  ref
                      .watch(commentsProvider(widget.postId).notifier)
                      .deletecomment(widget.comments.id!);
                }
              },
              itemBuilder: (context) => [
                if (widget.comments.userProfile!.user!.id == userid)
                  PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          )
                        ],
                      )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
