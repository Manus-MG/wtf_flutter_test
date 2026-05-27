import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

final sessionLogsProvider = StreamProvider<List<SessionLog>>((ref) {
  return ref.watch(logServiceProvider).watchLogs();
});

enum SessionFilter { all, last7Days, thisMonth }
final sessionFilterProvider = StateProvider<SessionFilter>((ref) => SessionFilter.all);

final filteredSessionsProvider = Provider<AsyncValue<List<SessionLog>>>((ref) {
  final filter = ref.watch(sessionFilterProvider);
  return ref.watch(sessionLogsProvider).whenData((logs) {
    final now = DateTime.now();
    switch (filter) {
      case SessionFilter.all: return logs;
      case SessionFilter.last7Days:
        return logs.where((l) => l.startedAt.isAfter(now.subtract(const Duration(days: 7)))).toList();
      case SessionFilter.thisMonth:
        return logs.where((l) => l.startedAt.year == now.year && l.startedAt.month == now.month).toList();
    }
  });
});
