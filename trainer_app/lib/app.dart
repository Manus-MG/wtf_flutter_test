import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_providers.dart';
import 'core/router/trainer_router.dart';

class TrainerApp extends ConsumerWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(trainerRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Trainer App',
      theme: _buildTheme(const Color(0xFFE50914), Brightness.light),
      darkTheme: _buildTheme(const Color(0xFFE50914), Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

ThemeData _buildTheme(Color seedColor, Brightness brightness) {
  final scheme =
      ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isDark ? scheme.outlineVariant : Colors.grey.shade200),
      ),
    ),
  );
}
