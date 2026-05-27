import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../../features/auth/onboarding_page.dart';
import '../../features/home/guru_home_page.dart';
import '../../features/chat/chat_page.dart';
import '../../features/scheduler/schedule_page.dart';
import '../../features/scheduler/request_call_page.dart';
import '../../features/sessions/sessions_page.dart';
import '../../features/sessions/session_detail_page.dart';
import '../../features/sessions/rate_session_page.dart';
import '../../features/calls/pre_join_screen.dart';
import '../../features/calls/in_call_screen.dart';
import '../../features/calls/post_call_screen.dart';
import '../../features/devpanel/dev_panel_page.dart';

final guruRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final loading = authState.isLoading;
      final loggedIn = authState.user != null;
      final onboarding = state.matchedLocation == '/onboarding';
      if (loading) return null;
      if (!loggedIn && !onboarding) return '/onboarding';
      if (loggedIn && onboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/home', builder: (_, __) => const GuruHomePage()),
      GoRoute(path: '/chat/:chatId', builder: (_, s) => ChatPage(chatId: s.pathParameters['chatId']!)),
      GoRoute(path: '/schedule', builder: (_, __) => const SchedulePage()),
      GoRoute(path: '/schedule/request', builder: (_, __) => const RequestCallPage()),
      GoRoute(path: '/sessions', builder: (_, __) => const SessionsPage()),
      GoRoute(path: '/sessions/:id', builder: (_, s) => SessionDetailPage(logId: s.pathParameters['id']!)),
      GoRoute(path: '/sessions/:id/rate', builder: (_, s) => RateSessionPage(logId: s.pathParameters['id']!)),
      GoRoute(path: '/call/pre-join/:requestId', builder: (_, s) => PreJoinScreen(requestId: s.pathParameters['requestId']!)),
      GoRoute(path: '/call/in-call/:requestId', builder: (_, s) => InCallScreen(requestId: s.pathParameters['requestId']!)),
      GoRoute(path: '/call/post-call/:requestId', builder: (_, s) => PostCallScreen(requestId: s.pathParameters['requestId']!)),
      GoRoute(path: '/dev-panel', builder: (_, __) => const DevPanelPage()),
    ],
  );
});
