import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';
import 'conflict_checker.dart';
import 'scheduler_providers.dart';

class RequestCallPage extends ConsumerStatefulWidget {
  const RequestCallPage({super.key});

  @override
  ConsumerState<RequestCallPage> createState() => _RequestCallPageState();
}

class _RequestCallPageState extends ConsumerState<RequestCallPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }


  Future<void> _submit() async {
    if (_selectedDate == null || _selectedTime == null) {
      setState(() => _error = 'Please select a date and time');
      return;
    }
    final scheduled = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    if (scheduled.isBefore(DateTime.now())) {
      setState(() => _error = 'Cannot pick a time in the past');
      return;
    }

    final existing = ref.read(callRequestsProvider).value ?? [];
    if (hasConflict(scheduled, existing)) {
      setState(() => _error = 'This time slot already has an approved call');
      return;
    }

    final user = ref.read(currentUserProvider)!;
    final req = CallRequest(
      id: const Uuid().v4(),
      memberId: user.id,
      trainerId: user.assignedTrainerId ?? 'user_aarav',
      requestedAt: DateTime.now(),
      scheduledFor: scheduled,
      note: _noteController.text.trim(),
      status: CallRequestStatus.pending,
    );

    setState(() { _isSubmitting = true; _error = null; });
    try {
      await ref.read(callServiceProvider).requestCall(req);
      DevLogger.instance.log('[SCHEDULE]', 'Call requested for ${scheduled.toIso8601String()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call requested. Waiting for trainer approval.')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Request a Call')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _PickerCard(
              label: _selectedDate == null
                  ? 'Tap to pick (next 3 days)'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              icon: Icons.calendar_month,
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            Text('Select Time (30-min blocks)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (_selectedDate != null) _TimeSlotGrid(onSelected: (t) => setState(() => _selectedTime = t), selected: _selectedTime)
            else _PickerCard(
              label: 'Select date first',
              icon: Icons.schedule,
              onTap: null,
            ),
            const SizedBox(height: 16),
            Text('Note (optional)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLength: 140,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Macros review',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Color(0xFFD92D20))),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: _isSubmitting
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Request Call'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _TimeSlotGrid extends StatelessWidget {
  const _TimeSlotGrid({required this.onSelected, required this.selected});
  final ValueChanged<TimeOfDay> onSelected;
  final TimeOfDay? selected;

  @override
  Widget build(BuildContext context) {
    final slots = <TimeOfDay>[];
    for (var h = 6; h < 22; h++) {
      slots.add(TimeOfDay(hour: h, minute: 0));
      slots.add(TimeOfDay(hour: h, minute: 30));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((t) {
        final label = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        final isSelected = selected?.hour == t.hour && selected?.minute == t.minute;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onSelected(t),
        );
      }).toList(),
    );
  }
}
