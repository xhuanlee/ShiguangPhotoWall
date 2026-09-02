import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 双 flavor：--flavor tv / mobile（Gradle productFlavor → appFlavor）。
  final flavor = appFlavor == 'tv' ? AppFlavor.tv : AppFlavor.mobile;
  AppConfig.init(flavor);

  if (AppConfig.isTv) {
    // TV 横屏。
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SgPhotoWallApp(),
    ),
  );
}
