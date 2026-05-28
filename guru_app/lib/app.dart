import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_providers.dart';
import 'core/router/guru_router.dart';

class GuruApp extends ConsumerWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(guruRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Guru App',
      theme: _buildTheme(const Color(0xFF1769E0), Brightness.light),
      darkTheme: _buildTheme(const Color(0xFF1769E0), Brightness.dark),
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
