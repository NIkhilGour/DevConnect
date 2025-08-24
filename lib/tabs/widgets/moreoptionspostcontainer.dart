import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/screens/chatscreen.dart';
import 'package:devconnect/tabs/widgets/creategroupdialog.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class Moreoptionspostcontainer extends StatelessWidget {
  const Moreoptionspostcontainer({
    super.key,
    required this.ondelete,
    required this.post,
    required this.userId,
  });
  final Function() ondelete;
  final Post post;
  final int userId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ismobile = screenWidth < 800;
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: ismobile ? 15.h : 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            (post.isconnected == 'APPROVED' ||
                    userId == post.userProfile!.user!.id!)
                ? post.group != null
                      ? (post.group!.members!.contains(userId))
                            ? GestureDetector(
                                onTap: () {
                                  ismobile
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return Chatscreen(
                                                isgroupscreen: false,
                                                userId: userId,
                                                isforjoin: false,
                                                group: post.group!,
                                              );
                                            },
                                          ),
                                        )
                                      : showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: Chatscreen(
                                                  isgroupscreen: false,
                                                  userId: userId,
                                                  isforjoin: false,
                                                  group: post.group!,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: ismobile ? 30.r : 30,
                                    ),
                                    SizedBox(width: ismobile ? 12.w : 12),
                                    Text(
                                      'Open chat',
                                      style: TextStyle(
                                        fontSize: ismobile ? 17.sp : 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Chatscreen(
                                          isgroupscreen: false,
                                          isforjoin: true,
                                          group: post.group!,
                                          userId: userId,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: ismobile ? 30.r : 30,
                                    ),
                                    SizedBox(width: ismobile ? 12.w : 12),
                                    Text(
                                      'Join Group',
                                      style: TextStyle(
                                        fontSize: ismobile ? 17.sp : 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                      : GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CreateGroupDialog(post: post);
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.people, size: ismobile ? 30.r : 30),
                              SizedBox(width: ismobile ? 12.w : 12),
                              Text(
                                'Create Group',
                                style: TextStyle(
                                  fontSize: ismobile ? 17.sp : 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                : Row(
                    children: [
                      Icon(
                        Icons.connect_without_contact_rounded,
                        size: ismobile ? 30.r : 30,
                      ),
                      SizedBox(width: ismobile ? 12.w : 12),
                      Text(
                        'Connect to post',
                        style: TextStyle(
                          fontSize: ismobile ? 17.sp : 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
            Row(
              children: [
                Icon(Icons.archive_outlined, size: ismobile ? 30.r : 30),
                SizedBox(width: ismobile ? 12.w : 12),
                Text(
                  'Save',
                  style: TextStyle(
                    fontSize: ismobile ? 17.sp : 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.share, size: ismobile ? 30.r : 30),
                SizedBox(width: ismobile ? 12.w : 12),
                Text(
                  'Share',
                  style: TextStyle(
                    fontSize: ismobile ? 17.sp : 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                ondelete();
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(Icons.delete, size: ismobile ? 30.r : 30),
                  SizedBox(width: ismobile ? 12.w : 12),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: ismobile ? 17.sp : 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
