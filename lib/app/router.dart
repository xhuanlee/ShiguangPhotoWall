import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../features/gallery/media_grid.dart';
import '../features/pairing/phone_scan_screen.dart';
import '../features/pairing/tv_pairing_screen.dart';
import '../features/settings/folder_picker_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/viewer/tv_viewer_screen.dart';
import '../features/viewer/viewer_screen.dart';
import 'shells.dart';

/// 路由配置：按 flavor 区分手机/TV（PRD §1.4 两端独立 UI）。
GoRouter buildRouter() {
  final isTv = AppConfig.isTv;

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            isTv ? const TvShell() : const MobileShell(),
      ),
      GoRoute(
        path: '/viewer',
        builder: (context, state) => ViewerScreen(args: _viewerArgs(state)),
      ),
      GoRoute(
        path: '/tv/viewer',
        builder: (context, state) => TvViewerScreen(args: _viewerArgs(state)),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/tv/settings',
        builder: (context, state) => const SettingsScreen(isTv: true),
      ),
      GoRoute(
        path: '/settings/folders',
        builder: (context, state) {
          final args = state.extra;
          if (args is! FolderPickerArgs) {
            return const Scaffold(body: Center(child: Text('参数错误')));
          }
          return FolderPickerScreen(args: args);
        },
      ),
      GoRoute(
        path: '/pairing/scan',
        builder: (context, state) => const PhoneScanScreen(),
      ),
      GoRoute(
        path: '/tv/pairing',
        builder: (context, state) => const TvPairingScreen(),
      ),
    ],
  );
}

ViewerArgs _viewerArgs(GoRouterState state) {
  final extra = state.extra;
  if (extra is ViewerArgs) return extra;
  return const ViewerArgs(items: [], initialIndex: 0);
}

/// 应用根 Widget。
class SgPhotoWallApp extends ConsumerWidget {
  const SgPhotoWallApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '拾光影像墙',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.dark),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: buildRouter(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      // 暗色优先（PRD §19.1）。
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF121212)
          : null,
    );
  }
}
