import 'dart:math';

import 'package:devconnect/core/colors.dart';
import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/error_screen.dart';
import 'package:devconnect/tabs/apiServices/groupchatnotifier.dart';
import 'package:devconnect/tabs/apiServices/groupnotifier.dart';
import 'package:devconnect/tabs/apiServices/userdetails.dart';

import 'package:devconnect/tabs/model/group.dart';
import 'package:devconnect/tabs/model/message.dart';
import 'package:devconnect/tabs/model/userdetails.dart';
import 'package:devconnect/tabs/widgets/chatbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatscreen extends ConsumerStatefulWidget {
  const Chatscreen({
    super.key,
    required this.group,
    required this.userId,
    required this.isforjoin,
    required this.isgroupscreen,
    this.onselectgroup,
  });

  final Group group;
  final int? userId;
  final bool isforjoin;
  final bool isgroupscreen;
  final VoidCallback? onselectgroup;

  @override
  ConsumerState<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends ConsumerState<Chatscreen> {
  bool isjoining = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => joinGroup());
  }

  void joinGroup() async {
    if (widget.isforjoin) {
      setState(() => isjoining = true);

      await ref
          .read(groupProvider.notifier)
          .togglejoinGroup(widget.group.id!, widget.userId!);
      widget.group.members!.add(widget.userId!);

      setState(() => isjoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(groupChatProvider(widget.group.id!));
    final chatNotifier = ref.read(groupChatProvider(widget.group.id!).notifier);
    final isSending = ref.watch(sendingMsgProvider(widget.group.id!));
    final userprofile = ref.watch(userdetailsprovider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ismobile = screenWidth < 800;
    return Scaffold(
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (ismobile) {
              Navigator.pop(context);
            } else {
              widget.isgroupscreen
                  ? widget.onselectgroup!()
                  : Navigator.pop(context);
            }
          },
          icon: Icon(ismobile ? Icons.arrow_back : Icons.close),
        ),
        elevation: 2,
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: ismobile ? 8.w : 8),
            CircleAvatar(
              radius: ismobile ? 24.r : 24,
              backgroundColor: Colors.blueGrey.shade400,
              child: Icon(
                Icons.group_outlined,
                color: Colors.black,
                size: ismobile ? 28.r : 28,
              ),
            ),
            SizedBox(width: ismobile ? 12.w : 12),
            Expanded(
              child: Text(
                widget.group.name ?? "Group Chat",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: ismobile ? 18.sp : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            color: const Color.fromARGB(197, 0, 0, 0),
            onSelected: (value) async {
              if (value == 'leave') {
                await ref
                    .read(groupProvider.notifier)
                    .toggleleaveGroup(widget.group.id!, widget.userId!);
                widget.group.members!.removeWhere((e) => e == widget.userId!);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Leave Group', style: TextStyle(color: Colors.red)),
                    Icon(Icons.exit_to_app_outlined, color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: isjoining
            ? [
                Center(
                  child: Container(
                    height: ismobile ? 150.h : 150,
                    width: ismobile ? 150.w : 150,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(ismobile ? 10.r : 10),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ]
            : [
                // messages list
                Padding(
                  padding: EdgeInsets.only(bottom: ismobile ? 70.h : 70),
                  child: chatState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, e) => ErrorScreen(
                      message: 'unable to load chats',
                      onRetry: () async {
                        final token = await JWTService.gettoken();
                        if (context.mounted) {
                          await JWTService.validateTokenAndRedirect(
                            context,
                            token!,
                          );
                        }
                        ref.refresh(groupChatProvider(widget.group.id!));
                      },
                    ),
                    data: (messages) {
                      if (messages.isEmpty) {
                        return const Center(child: Text("No messages yet"));
                      }
                      return ListView.builder(
                        itemCount: messages.length,
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: ismobile ? 12.w : 12,
                          vertical: ismobile ? 10.h : 10,
                        ),
                        itemBuilder: (context, index) {
                          final msg =
                              messages[messages.length - 1 - index]; // reverse

                          print(
                            '${msg.message} :  ${msg.userProfile?.user?.id}',
                          );
                          final isSent =
                              msg.userProfile?.user?.id == widget.userId;
                          return ChatBubble(msg: msg, isSent: isSent);
                        },
                      );
                    },
                  ),
                ),
                // composer
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ismobile ? 12.w : 12,
                      vertical: ismobile ? 10.h : 10,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ismobile ? 14.w : 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(
                                ismobile ? 24.r : 24,
                              ),
                            ),
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) =>
                                  _onSend(chatNotifier, userprofile.value!),
                            ),
                          ),
                        ),
                        SizedBox(width: ismobile ? 10.w : 10),
                        isSending
                            ? const SizedBox(
                                height: 32,
                                width: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : GestureDetector(
                                onTap: () =>
                                    _onSend(chatNotifier, userprofile.value!),
                                child: CircleAvatar(
                                  backgroundColor: seedcolor,
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  void _onSend(GroupChatNotifier chatNotifier, UserProfile userprofile) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    chatNotifier.sendMessage(
      text,
      userprofile, // adapt to your real model
    );
    _controller.clear();
  }
}
