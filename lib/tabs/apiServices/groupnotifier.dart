import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/core/user_id_service.dart';
import 'package:devconnect/tabs/apiServices/creategroup.dart';
import 'package:devconnect/tabs/apiServices/groupapi.dart';
import 'package:devconnect/tabs/apiServices/joingroup.dart';
import 'package:devconnect/tabs/apiServices/leavegroup.dart';
import 'package:devconnect/tabs/model/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Groupnotifier extends StateNotifier<AsyncValue<List<Group>>> {
  Groupnotifier() : super(const AsyncValue.loading()) {
    getAllJoinedGroups();
  }

  Future<void> getAllJoinedGroups() async {
    final token = await JWTService.gettoken();
    if (JWTService.isExpired(token!)) {
      throw AsyncError("Token Expired", StackTrace.current);
    }
    try {
      final groups = await getJoinedGroups();

      state = AsyncValue.data(groups);
    } catch (e) {
      throw Error();
    }
  }

  Future<Group> togglecreateGroup(int postId, String name,BuildContext context) async {
    try {
      final group = await createGroup(postId, name,context);
      if (state.value != null) {
        final newstate = [...state.value!, group];
        state = AsyncData(newstate);
        return group;
      }

      state = AsyncData([group]);
      return group;
    } catch (e) {
      throw Error();
    }
  }

  Future<Group> togglejoinGroup(int groupId, int userId,BuildContext context) async {
    try {
      final group = await joinGroupApi(groupId, userId,context);
      if (state.value != null) {
        final newstate = [...state.value!, group];
        state = AsyncData(newstate);
        return group;
      }

      state = AsyncData([group]);
      return group;
    } catch (e) {
      throw Error();
    }
  }

  Future<void> toggleleaveGroup(int groupId, int userId,BuildContext context) async {
    try {
      await leaveGroup(groupId, userId,context);
      if (state.value != null) {
        List<Group> list = state.value!;
        list.removeWhere(
          (element) {
            return element.id == groupId;
          },
        );

        state = AsyncData(list);
      }
    } catch (e) {
      throw Error();
    }
  }
}

final groupProvider =
    StateNotifierProvider<Groupnotifier, AsyncValue<List<Group>>>(
  (
    ref,
  ) {
    return Groupnotifier();
  },
);
