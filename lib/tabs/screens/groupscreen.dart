import 'package:devconnect/auth/authentication_tab.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/error_screen.dart';
import 'package:devconnect/tabs/apiServices/groupnotifier.dart';
import 'package:devconnect/tabs/model/group.dart';
import 'package:devconnect/tabs/screens/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Groupscreen extends ConsumerStatefulWidget {
  const Groupscreen({super.key, required this.selectgrouToChat});
  final Function(Group group) selectgrouToChat;
  @override
  ConsumerState<Groupscreen> createState() => _GroupscreenState();
}

class _GroupscreenState extends ConsumerState<Groupscreen> {
  int? userId;
  @override
  void initState() {
    _loadUserId();
    super.initState();
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    final groupsdata = ref.watch(groupProvider);
     ref.listen<AsyncValue<List<Group>>>(groupProvider, (
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
    return groupsdata.when(
      data: (data) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.w : 16, vertical: isMobile ? 12.h : 12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final group = data[index];

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: isMobile ? 12.h : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 12.r : 12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.w : 16,
                    vertical: isMobile ? 8.h : 8),
                leading: CircleAvatar(
                  radius: isMobile ? 24.r : 24,
                  backgroundColor: Colors.blueGrey.shade400,
                  child: Icon(Icons.group_outlined,
                      color: Colors.white, size: isMobile ? 28.r : 28),
                ),
                title: Text(
                  group.name ?? 'Unnamed Group',
                  style: TextStyle(
                    fontSize: isMobile ? 16.sp : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: isMobile ? 16.r : 16),
                onTap: () {
                  isMobile
                      ? Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return Chatscreen(
                                isforjoin: false, userId: userId, group: group);
                          },
                        ))
                      : widget.selectgrouToChat(group);
                },
              ),
            );
          },
        );
      },
      error: (error, stackTrace) {
        return ErrorScreen(
          message: 'Unable to load groups',
          onRetry: () {
            ref.refresh(groupProvider);
          },
        );
      },
      loading: () {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
