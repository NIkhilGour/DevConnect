import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/model/group.dart';
import 'package:devconnect/tabs/screens/chatscreen.dart';
import 'package:devconnect/tabs/screens/groupscreen.dart';

import 'package:flutter/material.dart';

class WebGroupPage extends StatefulWidget {
  const WebGroupPage({super.key});

  @override
  State<WebGroupPage> createState() => _WebGroupPageState();
}

class _WebGroupPageState extends State<WebGroupPage> {
  Group? selectedgroup;
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
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Groupscreen(
            selectgrouToChat: (group) {
              setState(() {
                selectedgroup = group;
              });
            },
          ),
        ),
        selectedgroup != null
            ? Flexible(
                flex: 2,
                child: Chatscreen(
                    group: selectedgroup!, userId: userId, isforjoin: false),
              )
            : Flexible(
                flex: 2,
                child: Center(
                  child: Text('Select Group To chat'),
                ),
              )
      ],
    );
  }
}
