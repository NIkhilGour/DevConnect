import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/error_screen.dart';
import 'package:devconnect/tabs/apiServices/allpostApi.dart';
import 'package:devconnect/tabs/apiServices/userdetails.dart';
import 'package:devconnect/tabs/apiServices/userprojects.dart';
import 'package:devconnect/tabs/model/userdetails.dart';
import 'package:devconnect/tabs/widgets/postcontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({required this.userid, super.key});
  final int userid;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int? userId;

  Future<UserProfile> getUserDetails() async {
    UserProfile userProfile = await getOtherUserDetails(widget.userid);
    return userProfile;
  }

  @override
  void initState() {
    _loadUserId();
    super.initState();
  }

  void _loadUserId() async {
    final userid = await SharedPreferencesService.getInt('userId');
    setState(() {
      userId = userid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ismobile = screenWidth < 800;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.lato(
            fontSize: ismobile ? 25.sp : 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorScreen(
              message: 'Unable to load User Profile',
              onRetry: () {
                getUserDetails();
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userProfile = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Profile Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: userProfile.profilePictureUrl != null
                            ? CachedNetworkImageProvider(
                                userProfile.profilePictureUrl!,
                              )
                            : null,
                        child: userProfile.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile.name ?? 'Unknown',
                              style: GoogleFonts.poppins(
                                fontSize: ismobile ? 25.sp : 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(userProfile.bio ?? 'No bio'),
                            const SizedBox(height: 8),
                            if (userProfile.location != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16),
                                  const SizedBox(width: 4),
                                  Text(userProfile.location!),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Tech Skills
                if (userProfile.techSkills != null &&
                    userProfile.techSkills!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Skills",
                          style: GoogleFonts.poppins(
                            fontSize: ismobile ? 18.sp : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: userProfile.techSkills!
                              .map(
                                (skill) => Chip(label: Text(skill.skill ?? '')),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                /// Posts Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Posts",
                    style: GoogleFonts.poppins(
                      fontSize: ismobile ? 20.sp : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder(
                  future: fetchUserProjects(widget.userid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return ErrorScreen(
                        message: 'Error in loading projects',
                        onRetry: () async {
                          final token = await JWTService.gettoken();
                          if (context.mounted) {
                            await JWTService.validateTokenAndRedirect(
                              context,
                              token!,
                            );
                          }

                          fetchUserProjects(widget.userid);
                        },
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data!;
                    if (data.isEmpty) {
                      return const Text("No posts yet.");
                    }

                    return ListView.builder(
                      itemCount: data.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Postcontainer(
                          onConnect: () {
                            ref
                                .watch(projectsNotifierProvider.notifier)
                                .toggleConnectionStatus(data[index].id!);
                          },
                          onComment: () {},
                          onLike: () {
                            ref
                                .watch(projectsNotifierProvider.notifier)
                                .toggleLikePostInNotifier(data[index].id!);
                          },
                          isliking: ref.watch(
                            likeLoadingProvider(data[index].id!),
                          ),
                          isLiked:
                              data[index].likes?.any(
                                (like) => like.user?.id == userId,
                              ) ??
                              false,
                          post: data[index],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
