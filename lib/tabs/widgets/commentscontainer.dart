import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/error_screen.dart';
import 'package:devconnect/tabs/apiServices/commentapi.dart';

import 'package:devconnect/tabs/widgets/addcommentcontainer.dart';
import 'package:devconnect/tabs/widgets/commentslistcontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Commentscontainer extends ConsumerStatefulWidget {
  const Commentscontainer({
    super.key,
    required this.postId,
    required this.scrollController,
  });
  final int postId;
  final ScrollController scrollController;
  @override
  ConsumerState<Commentscontainer> createState() => _CommentscontainerState();
}

class _CommentscontainerState extends ConsumerState<Commentscontainer> {
  @override
  Widget build(BuildContext context) {
    final commentsData = ref.watch(commentsProvider(widget.postId));
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isMobile ? 20.r : 20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: isMobile ? 10.h : 10),
          Text(
            'Comments',
            style: GoogleFonts.roboto(fontSize: isMobile ? 18.sp : 18),
          ),
          SizedBox(height: isMobile ? 10.h : 10),
          Expanded(
            child: commentsData.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(child: Text('No Comments Available'));
                }
                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: comments.length,
                  itemBuilder: (context, index) => Commentslistcontainer(
                    postId: widget.postId,
                    comments: comments[index],
                  ),
                );
              },
              error: (_, __) => ErrorScreen(
                message: 'Error loading comments',
                onRetry: () async {
                  final token = await JWTService.gettoken();
                  if (context.mounted) {
                    await JWTService.validateTokenAndRedirect(context, token!);
                  }

                  ref.refresh(commentsProvider(widget.postId));
                },
              ),
              loading: () =>
                  Center(child: CircularProgressIndicator(color: seedcolor)),
            ),
          ),
          AddCommentContainer(postId: widget.postId),
        ],
      ),
    );
  }
}
