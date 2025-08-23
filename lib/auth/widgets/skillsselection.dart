import 'package:devconnect/auth/model/skill.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Skillsselection extends StatefulWidget {
  const Skillsselection(
      {super.key,
      required this.allSkills,
      required this.selectedSkills,
      required this.onselect});
  final List<Skill> allSkills;
  final List<Skill> selectedSkills;
  final Function(List<Skill>) onselect;
  @override
  State<Skillsselection> createState() => _SkillsselectionState();
}

class _SkillsselectionState extends State<Skillsselection> {
  @override
  Widget build(BuildContext context) {
    List<Skill> tempSelected = List.from(widget.selectedSkills);
    return AlertDialog(
      title: const Text('Select Skills'),
      content: SizedBox(
        width: double.maxFinite,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: widget.allSkills.length,
              itemBuilder: (context, index) {
                final skill = widget.allSkills[index];
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
