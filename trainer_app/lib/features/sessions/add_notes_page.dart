import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

class AddNotesPage extends ConsumerStatefulWidget {
  const AddNotesPage({super.key, required this.logId});
  final String logId;

  @override
  ConsumerState<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends ConsumerState<AddNotesPage> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(logServiceProvider).updateLog(widget.logId, {
        'trainerNotes': _ctrl.text.trim(),
      });
      DevLogger.instance.log('[RTC]', 'Trainer notes saved for ${widget.logId.substring(0, 8)}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session saved to your logs.')));
        context.go('/sessions');
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Session Notes')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Add your notes about this session...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFFE50914),
              ),
              child: _saving
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Mark as Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
