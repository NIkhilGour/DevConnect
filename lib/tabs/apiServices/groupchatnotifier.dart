import 'dart:convert';

import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/apiServices/messageservice.dart';
import 'package:devconnect/tabs/model/message.dart';
import 'package:devconnect/tabs/model/userdetails.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

final sendingMsgProvider =
    StateProvider.family<bool, int>((ref, groupId) => false);

final groupChatProvider = StateNotifierProvider.autoDispose
    .family<GroupChatNotifier, AsyncValue<List<Message>>, int>((ref, groupId) {
  final link = ref.keepAlive(); // prevent auto dispose
  final notifier = GroupChatNotifier(ref, groupId);

  ref.onDispose(() {
    notifier.disconnect(); // safely disconnect WebSocket
    link.close(); // release keepAlive manually when done
  });

  return notifier;
});

class GroupChatNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  GroupChatNotifier(this._ref, this.groupId)
      : super(const AsyncValue.loading()) {
    _bootstrapAndConnect();
  }

  final Ref _ref;
  final int groupId;

  StompClient? _client;
  void Function()? _unsubscribe;

  // ---------- Public API ----------

  Future<void> refresh() => _fetchHistory();

  Future<void> sendMessage(String text, UserProfile user) async {
    print(_client?.connected);
    final msg = Message(
      id: null,
      message: text,
      userProfile: user,
      timestamp: DateTime.now(),
    );

    _ref.read(sendingMsgProvider(groupId).notifier).state = true;

    try {
      if (_client?.connected == true) {
        // Adapt the destination + body keys to match your backend
        _client!.send(
          destination: '/app/chat.sendMessage/$groupId',
          body: jsonEncode({"content": text, "userProfile": user.toJson()}),
        );
        // optimistic update
        state = state.whenData((m) => [...m, msg]);
      } else {
        // // Optional HTTP fallback
        // final sent = await MessageService.sendMessageToGroup(groupId, msg);
        // state = state.whenData((m) => [...m, sent]);
      }
    } catch (e, st) {
      // keep the old list, but surface the error
      state = AsyncValue.error(e, st);
    } finally {
      _ref.read(sendingMsgProvider(groupId).notifier).state = false;
    }
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    _client?.deactivate();
    super.dispose();
  }

  // ---------- Internals ----------

  Future<void> _bootstrapAndConnect() async {
    await _fetchHistory();
    _connectWs();
  }

  Future<void> _fetchHistory() async {
    try {
      final msgs = await MessageService.getMessagesByGroupId(groupId);
      state = AsyncValue.data(msgs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _connectWs() async {
    _client = StompClient(
      config: StompConfig(
        // Use **wss://** for production SSL endpoints
        url: 'wss://devconnect-backend-2-0c3c.onrender.com/chat',
        onConnect: _onConnect,
        onWebSocketError: (error) {
          print(error.toString());
        },
        onStompError: (frame) {
          // ignore or log
        },

        reconnectDelay: const Duration(milliseconds: 5000),
        heartbeatOutgoing: const Duration(seconds: 10),
        heartbeatIncoming: const Duration(seconds: 10),
      ),
    );

    _client!.activate();
  }

  void disconnect() {
    _client!.deactivate(); // or any cleanup logic
  }

  void _onConnect(StompFrame frame) async {
    print("subscribed");
    // Subscribe to the group topic broadcasted by the server
    final userId = await SharedPreferencesService.getInt('userId');
    _unsubscribe = _client!.subscribe(
      destination: '/topic/group.$groupId',
      callback: (StompFrame f) {
        if (f.body == null) return;
        try {
          final msg =
              Message.fromJson(jsonDecode(f.body!) as Map<String, dynamic>);
          print("msg recieved : $msg");
          if (msg.userProfile!.user!.id! != userId) {
            state = state.whenData((m) => [...m, msg]);
          }
        } catch (_) {
          // ignore parse errors
        }
      },
    );
  }
}
