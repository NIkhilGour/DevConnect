import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devconnect/tabs/apiServices/requestapi.dart';
import 'package:devconnect/tabs/model/request.dart';

class RequestNotifier extends StateNotifier<AsyncValue<List<Request>>> {
  RequestNotifier() : super(const AsyncValue.loading()) {
    fetchAllRequests();
  }

  Future<void> fetchAllRequests() async {
    try {
      final result = await getAllRequest(); // Fix typo if needed
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleAcceptRequest(int requestId) async {
    final previous = state.value ?? [];

    // Create a new list without the accepted request
    final updatedList = previous.where((e) => e.id != requestId).toList();
    state = AsyncData(updatedList);

    try {
      await acceptrequest(requestId);
    } catch (e, st) {
      // Rollback to previous state
      state = AsyncData(previous);
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleDeleteRequest(int requestId) async {
    final previous = state.value ?? [];

    // Create a new list without the deleted request
    final updatedList = previous.where((e) => e.id != requestId).toList();
    state = AsyncData(updatedList);

    try {
      await deleterequest(requestId);
    } catch (e, st) {
      // Rollback on error
      state = AsyncData(previous);
      state = AsyncError(e, st);
    }
  }
}

final requestProvider =
    StateNotifierProvider<RequestNotifier, AsyncValue<List<Request>>>(
  (ref) => RequestNotifier(),
);
