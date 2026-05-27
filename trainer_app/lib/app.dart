import 'package:flutter/material.dart';

import 'features/home/trainer_home_page.dart';

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE50914)),
        useMaterial3: true,
      ),
      home: const TrainerHomePage(),
    );
  }
}
