import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtf_shared/shared.dart';
import 'app.dart';
import 'core/providers/app_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DevLogger.instance.init(FirebaseFirestore.instance);

  final prefs = await SharedPreferences.getInstance();
  await SeedService(FirebaseFirestore.instance, prefs).seed();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const TrainerApp(),
    ),
  );
}
