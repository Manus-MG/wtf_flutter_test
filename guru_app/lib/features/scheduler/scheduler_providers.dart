import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

final callRequestsProvider = StreamProvider<List<CallRequest>>((ref) {
  return ref.watch(callServiceProvider).watchRequests();
});
