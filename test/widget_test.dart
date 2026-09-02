// Mobile / TV Shell widget 冒烟测试（PRD §19.2 / §19.3）。
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgphotowall/app/providers.dart';
import 'package:sgphotowall/app/shells.dart';
import 'package:sgphotowall/data/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    // 测试中每个用例各建一个内存数据库。
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(AppDatabase db, Widget child) => ProviderScope(
    overrides: [
      // 内存数据库，避免真实文件 / path_provider 平台通道。
      appDatabaseProvider.overrideWithValue(db),
      // 覆盖 preview 目录。
      previewDirProvider.overrideWith((ref) async => Directory.systemTemp),
    ],
    child: MaterialApp(home: child),
  );

  /// 释放 widget 树并让 drift 流取消产生的 0ms timer 触发，避免 pending timer。
  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('MobileShell 渲染三个 Tab 且可切换', (tester) async {
    final db = AppDatabase.memory();
    await tester.pumpWidget(wrap(db, const MobileShell()));
    await tester.pumpAndSettle();

    // 导航标签 + 当前页 AppBar 标题（IndexedStack 隐藏页被 finder 跳过）。
    expect(find.text('首页'), findsNWidgets(2));
    expect(find.text('照片'), findsOneWidget);
    expect(find.text('视频'), findsOneWidget);
    // 空态提示（内存数据库无媒体；IndexedStack 仅可见页被 finder 命中）。
    expect(find.text('当前文件夹没有照片或视频'), findsOneWidget);

    // 切换到"照片" Tab。
    await tester.tap(find.text('照片').last);
    await tester.pumpAndSettle();
    expect(find.text('当前文件夹没有照片或视频'), findsOneWidget);

    await teardownTree(tester);
    await db.close();
  });

  testWidgets('TvShell 渲染左侧导航 Rail', (tester) async {
    final size = tester.view.physicalSize;
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 3.0;
    });

    final db = AppDatabase.memory();
    await tester.pumpWidget(wrap(db, const TvShell()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    // Rail 标签 + 当前页 AppBar 标题。
    expect(find.text('首页'), findsNWidgets(2));
    expect(find.text('照片'), findsOneWidget);
    expect(find.text('视频'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('当前文件夹没有照片或视频'), findsOneWidget);

    // D-pad 焦点导航到"照片"。
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('当前文件夹没有照片或视频'), findsOneWidget);

    await teardownTree(tester);
    await db.close();
  });
}
