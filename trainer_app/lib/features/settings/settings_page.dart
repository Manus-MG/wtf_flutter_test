import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.settings_brightness_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (selection) {
                  notifier.setThemeMode(selection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(_subtitle(mode), style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _subtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow the device setting';
      case ThemeMode.light:
        return 'Always use the light theme';
      case ThemeMode.dark:
        return 'Always use the dark theme';
    }
  }
}
