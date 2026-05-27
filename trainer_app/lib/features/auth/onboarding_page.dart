import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 96, color: theme.colorScheme.primary),
              const SizedBox(height: 32),
              Text('WTF Trainer', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text('Manage your members, approve calls, and track every session.',
                  style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () async {
                  const aarav = User(
                    id: 'user_aarav',
                    role: UserRole.trainer,
                    name: 'Aarav',
                    email: 'aarav@wtf.com',
                  );
                  await ref.read(authNotifierProvider.notifier).signInAs(aarav);
                  if (context.mounted) context.go('/home');
                },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: const Text('Sign in as Aarav'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
