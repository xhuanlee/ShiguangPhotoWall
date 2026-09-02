import 'package:flutter/material.dart';

import '../features/home/gallery_tab_page.dart';

/// 手机端底部导航外壳（PRD §3 / §19.2）：
/// 首页 / 照片 / 视频 三个主功能。
class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          GalleryTabPage(title: '首页', mediaType: null),
          GalleryTabPage(title: '照片', mediaType: 'IMAGE'),
          GalleryTabPage(title: '视频', mediaType: 'VIDEO'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_outlined),
            selectedIcon: Icon(Icons.photo),
            label: '照片',
          ),
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam),
            label: '视频',
          ),
        ],
      ),
    );
  }
}

/// TV 端外壳（PRD §19.3）：
/// 左侧大焦点导航（首页/照片/视频/设置），右侧媒体区。
/// 遥控器 D-pad 导航，不依赖触摸。
class TvShell extends StatefulWidget {
  const TvShell({super.key});

  @override
  State<TvShell> createState() => _TvShellState();
}

class _TvShellState extends State<TvShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = switch (_index) {
      0 => const GalleryTabPage(title: '首页', mediaType: null, isTv: true),
      1 => const GalleryTabPage(title: '照片', mediaType: 'IMAGE', isTv: true),
      2 => const GalleryTabPage(title: '视频', mediaType: 'VIDEO', isTv: true),
      _ => const SizedBox.shrink(),
    };

    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏：大焦点框（PRD §19.3 hit area ≥ 64dp）。
          NavigationRailTheme(
            data: NavigationRailThemeData(
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              selectedIconTheme: IconThemeData(
                size: 40,
                color: theme.colorScheme.primary,
              ),
              unselectedIconTheme: const IconThemeData(size: 32),
              selectedLabelTextStyle: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              unselectedLabelTextStyle: theme.textTheme.bodyLarge,
              minExtendedWidth: 140,
            ),
            child: NavigationRail(
              extended: true,
              selectedIndex: _index,
              onDestinationSelected: (i) {
                if (i == 3) {
                  Navigator.of(context).pushNamed('/tv/settings');
                } else {
                  setState(() => _index = i);
                }
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  label: Text('首页'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.photo_outlined),
                  label: Text('照片'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.videocam_outlined),
                  label: Text('视频'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: Text('设置'),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
