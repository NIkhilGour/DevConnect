import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/tabs/apiServices/commentapi.dart';
import 'package:devconnect/tabs/apiServices/userdetails.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCommentContainer extends ConsumerStatefulWidget {
  const AddCommentContainer({super.key, required this.postId});
  final int postId;
  @override
  ConsumerState<AddCommentContainer> createState() =>
      _AddCommentContainerState();
}

class _AddCommentContainerState extends ConsumerState<AddCommentContainer> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    final user = ref.watch(userdetailsprovider);
    return SizedBox(
      height: isMobile ? 60.h : 60,
      child: Padding(
        padding: EdgeInsets.only(
            top: isMobile ? 7.h : 7,
            bottom: isMobile ? 7.h : 7,
            left: isMobile ? 16.w : 16,
            right: isMobile ? 8.w : 8),
        child: Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 20.r : 20),
              child: CachedNetworkImage(
                  height: isMobile ? 40.h : 40,
                  width: isMobile ? 40.w : 40,
                  fit: BoxFit.cover,
                  imageUrl: user.value!.profilePictureUrl!),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: isMobile ? 10.w : 10, right: isMobile ? 10.w : 10),
              child: Container(
                width: isMobile ? 200.w : 200,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(isMobile ? 15.r : 15)),
                child: TextField(
                  controller: controller,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12.w : 12,
                        vertical: isMobile ? 10.h : 10),
                    hintText: "Add a comment...",
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: isMobile ? 10.w : 10),
              child: Container(
                height: isMobile ? 50.h : 50,
                width: isMobile ? 90.w : 90,
                decoration: BoxDecoration(
                    color: Color(0xFF876FE8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 12.r : 12)),
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(commentsProvider(widget.postId).notifier)
                        .addcomment(
                            widget.postId, controller.text, user.value!);

                    controller.clear();
                  },
                  child: Center(
                    child: Text(
                      'Comment',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: seedcolor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
