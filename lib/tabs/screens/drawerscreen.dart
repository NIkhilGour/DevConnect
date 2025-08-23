import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/auth/authentication_tab.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/error_screen.dart';

import 'package:devconnect/tabs/apiServices/userdetails.dart';
import 'package:devconnect/tabs/model/userdetails.dart';

import 'package:devconnect/tabs/screens/profilescren.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Drawerscreen extends ConsumerStatefulWidget {
  const Drawerscreen({super.key, required this.isweb, required this.ontap});
  final bool isweb;
  final Function() ontap;
  @override
  ConsumerState<Drawerscreen> createState() => _DrawerscreenState();
}

class _DrawerscreenState extends ConsumerState<Drawerscreen> {
  @override
  Widget build(BuildContext context) {
    final userprofiledata = ref.watch(userdetailsprovider);
    ref.listen<AsyncValue<UserProfile>>(userdetailsprovider, (
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
    return userprofiledata.when(
      data: (userprofile) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  widget.isweb
                      ? widget.ontap()
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ProfileScreen(
                                userid: userprofile.user!.id!,
                              );
                            },
                          ),
                        );
                },
                child: Padding(
                  padding: EdgeInsets.all(widget.isweb ? 16 : 16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.isweb ? 12 : 12.r,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: userprofile.profilePictureUrl!,
                            height: widget.isweb ? 90 : 90.h,
                            width: widget.isweb ? 90 : 90.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.isweb ? 8 : 8.r,
                        ),
                        child: Text(
                          userprofile.name!,
                          style: GoogleFonts.poppins(
                            fontSize: widget.isweb ? 22 : 22.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.isweb ? 8 : 8.r,
                        ),
                        child: Text(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          userprofile.bio!,
                          style: TextStyle(
                            fontSize: widget.isweb ? 14 : 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.isweb ? 8 : 8.r,
                        ),
                        child: Text(
                          userprofile.location!,
                          style: GoogleFonts.lato(
                            color: const Color.fromARGB(255, 66, 64, 64),
                            fontSize: widget.isweb ? 17 : 17.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Container(height: widget.isweb ? 0.7 : 0.7.h, color: Colors.grey),
              Padding(
                padding: EdgeInsets.only(
                  bottom: widget.isweb ? 16 : 16.r,
                  left: widget.isweb ? 16 : 16.r,
                  top: widget.isweb ? 16 : 16.r,
                ),
                child: GestureDetector(
                  onTap: () async {
                    await JWTService.deletetoken();
                    await SharedPreferencesService.clear();

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AuthenticationTab();
                          },
                        ),
                        (route) {
                          return false;
                        },
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: widget.isweb ? 30 : 30.r,
                        color: Colors.red,
                      ),
                      SizedBox(width: widget.isweb ? 10 : 10.w),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return ErrorScreen(
          message: 'Unable to load UserDetails',
          onRetry: () {
            ref.refresh(userdetailsprovider);
          },
        );
      },
      loading: () {
        return SizedBox();
      },
    );
  }
}
