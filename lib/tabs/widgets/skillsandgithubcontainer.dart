import 'package:devconnect/tabs/model/post.dart';
import 'package:devconnect/tabs/model/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillsAndGithubContainer extends StatelessWidget {
  const SkillsAndGithubContainer(
      {super.key, required this.skills, required this.github});
  final List<TechSkills> skills;
  final String github;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ismobile = screenWidth < 800;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(ismobile ? 16.r : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills',
              style: TextStyle(
                  fontSize: ismobile ? 19.sp : 19, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: EdgeInsets.only(top: ismobile ? 16.h : 16),
              child: Wrap(
                spacing: ismobile ? 8.w : 8,
                runSpacing: ismobile ? 8.h : 8,
                children: List.generate(skills.length, (index) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ismobile ? 10.w : 10,
                        vertical: ismobile ? 6.h : 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ismobile ? 12.r : 12),
                      color: const Color(0xFF876FE8).withOpacity(0.1),
                    ),
                    child: Text(
                      skills[index].skill!,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: ismobile ? 15.sp : 15),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: ismobile ? 15.w : 15),
              child: Text(
                'Github',
                style: TextStyle(
                    fontSize: ismobile ? 19.sp : 19,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: ismobile ? 10.w : 10),
              child: Text(
                github,
                style: TextStyle(fontSize: ismobile ? 19.sp : 19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
