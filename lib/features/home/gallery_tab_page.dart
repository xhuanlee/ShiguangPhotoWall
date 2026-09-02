import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/account_service.dart';
import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/provider/provider_models.dart';
import '../../data/sync/sync_engine.dart';
import '../gallery/media_grid.dart';

/// 首页/照片/视频页共用骨架（PRD §21 HomeScreen）：
/// - 标题 + 刷新按钮 + 设置入口
/// - 同步状态可视化（PRD §10.1）
/// - Reauth Banner（PRD §15）
/// - 媒体 Grid
class GalleryTabPage extends ConsumerWidget {
  const GalleryTabPage({
    super.key,
    required this.title,
    this.mediaType,
    this.isTv = false,
  });

  final String title;
  final String? mediaType;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(syncProgressProvider).value;
    final accounts =
        ref.watch(accountsProvider).value ?? const <ProviderAccount>[];
    final needReauth = accounts
        .where((a) => a.status == AccountStatus.needReauth)
        .toList();

    final isSyncing = progress != null && _isRunning(progress.phase);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
              onPressed: () => ref.read(syncServiceProvider).sync(),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: () =>
                Navigator.of(context)
                    .pushNamed(isTv ? '/tv/settings' : '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isSyncing) SyncStatusBar(label: progress.displayLabel),
          for (final account in needReauth)
            ReauthBanner(
              accountId: account.id,
              accountType: account.providerType,
            ),
          Expanded(
            child: MediaGridScreen(
              mediaType: mediaType,
              title: title,
              isTv: isTv,
            ),
          ),
        ],
      ),
    );
  }

  bool _isRunning(SyncPhase phase) => switch (phase) {
    SyncPhase.idle ||
    SyncPhase.success ||
    SyncPhase.partialFailure ||
    SyncPhase.authFailed ||
    SyncPhase.networkFailed => false,
    _ => true,
  };
}

/// 同步状态条（PRD §10.1）。
class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

/// 认证失效 Banner（PRD §15）。
class ReauthBanner extends ConsumerWidget {
  const ReauthBanner({
    super.key,
    required this.accountId,
    required this.accountType,
  });

  final int accountId;
  final String accountType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ProviderType.fromWire(accountType);
    if (type == null) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${type.displayName}认证已失效',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final error = await ref.read(accountServiceProvider).bind(type);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.maybeOf(context)
                      ?.showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: const Text('重新认证'),
            ),
          ],
        ),
      ),
    );
  }
}
