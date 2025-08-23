import 'package:devconnect/tabs/apiServices/groupnotifier.dart';
import 'package:devconnect/tabs/model/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateGroupDialog extends ConsumerStatefulWidget {
  const CreateGroupDialog({super.key, required this.post});
  final Post post;
  @override
  ConsumerState<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<CreateGroupDialog> {
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Create Group'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _groupNameController,
          decoration: InputDecoration(
            labelText: 'Group Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Group name is required';
            }
            if (value.length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                isloading = true;
              });
              final groupName = _groupNameController.text.trim();
              final group = await ref
                  .watch(groupProvider.notifier)
                  .togglecreateGroup(widget.post.id!, groupName);

              setState(() {
                isloading = false;
              });
              widget.post.group = group;
              if (context.mounted) {
                Navigator.pop(context, groupName);
              }
              // Return the name
            }
          },
          child: isloading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Text('Create Group'),
        ),
      ],
    );
  }
}
