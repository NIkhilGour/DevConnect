import 'dart:async';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/error_screen.dart';
import 'package:devconnect/tabs/apiServices/getskills.dart';
import 'package:devconnect/tabs/model/skill.dart';

import 'package:flutter/material.dart';

class Skillsselection extends StatefulWidget {
  const Skillsselection({
    super.key,
    required this.selectedSkills,
    required this.onselect,
  });

  final List<Skill> selectedSkills;
  final Function(List<Skill>) onselect;
  @override
  State<Skillsselection> createState() => _SkillsselectionState();
}

class _SkillsselectionState extends State<Skillsselection> {
  Future<List<Skill>> fetchSkills() async {
    final token = await JWTService.gettoken();
    try {
      final result = await getAllSkills(token!);
      return result!;
    } catch (e) {
      throw AsyncError(e, StackTrace.current);
    }
  }

  @override
  void initState() {
    fetchSkills();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Skill> tempSelected = List.from(widget.selectedSkills);
    return AlertDialog(
      title: const Text('Select Skills'),
      content: SizedBox(
        width: 300,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return FutureBuilder(
              future: fetchSkills(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  return ErrorScreen(
                    message: 'Error in loading skills',
                    onRetry: () async {
                      final token = await JWTService.gettoken();
                      if (context.mounted) {
                        await JWTService.validateTokenAndRedirect(
                          context,
                          token!,
                        );
                      }

                      fetchSkills();
                    },
                  );
                } else if (asyncSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final allSkills = asyncSnapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: allSkills.length,
                  itemBuilder: (context, index) {
                    final skill = allSkills[index];
                    return CheckboxListTile(
                      title: Text(skill.skill!),
                      value: tempSelected.contains(skill),
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            tempSelected.add(skill);
                          } else {
                            tempSelected.remove(skill);
                          }
                        });
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onselect(tempSelected);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
