import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

class RateSessionPage extends ConsumerStatefulWidget {
  const RateSessionPage({super.key, required this.logId});
  final String logId;

  @override
  ConsumerState<RateSessionPage> createState() => _RateSessionPageState();
}

class _RateSessionPageState extends ConsumerState<RateSessionPage> {
  int _rating = 0;
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(logServiceProvider).updateLog(widget.logId, {
        'rating': _rating,
        'memberNotes': _noteController.text.trim(),
      });
      DevLogger.instance.log('[CHAT]', 'Session rated $_rating stars');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session saved to your logs.')),
        );
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
      appBar: AppBar(title: const Text('Rate Session')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('How was your session?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      size: 48,
                      color: const Color(0xFFF79009),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: _saving
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
