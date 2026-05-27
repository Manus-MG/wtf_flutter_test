import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

const _slides = [
  _Slide(
    icon: Icons.fitness_center,
    title: 'Train with the Best',
    body: 'Connect with your assigned trainer, schedule video calls, and track every session.',
  ),
  _Slide(
    icon: Icons.chat_bubble_outline,
    title: 'Stay in Sync',
    body: 'Chat in real time, share your progress, and never miss an update from your trainer.',
  ),
];

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    const dk = User(
      id: 'user_dk',
      role: UserRole.member,
      name: 'DK',
      email: 'dk@wtf.com',
      assignedTrainerId: 'user_aarav',
    );
    await ref.read(authNotifierProvider.notifier).signInAs(dk);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) => _Dot(active: i == _page)),
                  ),
                  const SizedBox(height: 24),
                  if (_page < _slides.length - 1)
                    FilledButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      ),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: _start,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: const Text('Start as DK'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(slide.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(slide.body, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}
