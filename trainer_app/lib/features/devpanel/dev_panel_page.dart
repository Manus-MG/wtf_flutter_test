import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/shared.dart';

final _devLogsProvider = StreamProvider<List<DevLogEntry>>((ref) {
  return FirebaseFirestore.instance
      .collection('dev_logs')
      .orderBy('createdAt', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map((d) {
            final data = d.data();
            return DevLogEntry(
              id: data['id'] as String? ?? d.id,
              level: DevLogLevel.values.byName(data['level'] as String? ?? 'info'),
              tag: data['tag'] as String? ?? '',
              message: data['message'] as String? ?? '',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList());
});

class DevPanelPage extends ConsumerStatefulWidget {
  const DevPanelPage({super.key});

  @override
  ConsumerState<DevPanelPage> createState() => _DevPanelPageState();
}

class _DevPanelPageState extends ConsumerState<DevPanelPage> {
  String? _tagFilter;
  static const _tags = ['[AUTH]', '[CHAT]', '[RTC]', '[SCHEDULE]'];

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(_devLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => FirebaseFirestore.instance.collection('dev_logs').get().then((s) { for (final d in s.docs) { d.reference.delete(); } }),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Build Info', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('App: Trainer App v0.0.1+1'),
                const Text('Firebase: testing-6edfc'),
                const Text('Token Server: http://10.0.2.2:3001'),
              ]),
            )),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              ChoiceChip(label: const Text('All'), selected: _tagFilter == null, onSelected: (_) => setState(() => _tagFilter = null)),
              const SizedBox(width: 8),
              ..._tags.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t),
                  selected: _tagFilter == t,
                  onSelected: (_) => setState(() => _tagFilter = _tagFilter == t ? null : t),
                ),
              )),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: logs.when(
              data: (entries) {
                final filtered = _tagFilter == null ? entries : entries.where((e) => e.tag == _tagFilter).toList();
                if (filtered.isEmpty) return const Center(child: Text('No logs yet'));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final e = filtered[i];
                    final color = switch (e.level) { DevLogLevel.info => Colors.blue, DevLogLevel.warn => const Color(0xFFF79009), DevLogLevel.error => const Color(0xFFD92D20) };
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: '${e.tag} ${e.message}'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: Text(e.tag, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.message, style: const TextStyle(fontSize: 12))),
                            Text('${e.createdAt.hour.toString().padLeft(2, '0')}:${e.createdAt.minute.toString().padLeft(2, '0')}:${e.createdAt.second.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ]),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
