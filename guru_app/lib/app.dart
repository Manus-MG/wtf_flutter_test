import 'package:flutter/material.dart';

import 'features/home/guru_home_page.dart';

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guru App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769E0)),
        useMaterial3: true,
      ),
      home: const GuruHomePage(),
    );
  }
}
