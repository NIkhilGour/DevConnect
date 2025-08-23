import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/tabs/model/message.dart';
import 'package:devconnect/tabs/screens/profilescren.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.msg,
    required this.isSent,
  });

  final Message msg;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ismobile = screenWidth < 800;
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSent)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ProfileScreen(userid: msg.userProfile!.user!.id!);
                  },
                ));
              },
              child: CircleAvatar(
                radius: ismobile ? 20.r : 20,
                backgroundImage: CachedNetworkImageProvider(
                  msg.userProfile!.profilePictureUrl!,
                ),
              ),
            ),
          SizedBox(
            width: ismobile ? 2.w : 2,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: ismobile ? 6.h : 6),
            padding: EdgeInsets.all(ismobile ? 12.w : 12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.7),
            decoration: BoxDecoration(
              color:
                  isSent ? seedcolor.withOpacity(0.85) : Colors.grey.shade800,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(isSent
                    ? ismobile
                        ? 16.r
                        : 16
                    : 0),
                bottomRight: Radius.circular(isSent
                    ? 0
                    : ismobile
                        ? 16.r
                        : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.message ?? '',
                  style: TextStyle(
                      color: Colors.white, fontSize: ismobile ? 14.sp : 14),
                ),
                SizedBox(height: 6.h),
                Text(
                  _formatTime(msg.timestamp),
                  style: TextStyle(
                      color: Colors.white70, fontSize: ismobile ? 11.sp : 11),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 2.r,
          ),
          if (isSent)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ProfileScreen(userid: msg.userProfile!.user!.id!);
                  },
                ));
              },
              child: CircleAvatar(
                radius: ismobile ? 20.r : 20,
                backgroundImage: CachedNetworkImageProvider(
                  msg.userProfile!.profilePictureUrl!,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? ts) {
    if (ts == null) return '';
    final hh = ts.hour.toString().padLeft(2, '0');
    final mm = ts.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
