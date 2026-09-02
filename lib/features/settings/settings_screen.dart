import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/account_service.dart';
import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/provider/provider_models.dart';

/// 设置页（PRD §21 SettingsScreen）。
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.isTv = false});

  final bool isTv;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Map<ProviderType, bool> _binding = {};

  Future<void> _bind(ProviderType type) async {
    setState(() => _binding[type] = true);
    try {
      final error = await ref.read(accountServiceProvider).bind(type);
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            error ??
                (widget.isTv
                    ? '认证已恢复，正在同步已配置文件夹'
                    : '${type.displayName}绑定成功，正在同步已配置文件夹'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _binding[type] = false);
    }
  }

  Future<void> _unbind(ProviderAccount account, ProviderType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('解除绑定 ${type.displayName}？'),
        content: const Text('将删除本机的媒体索引与文件夹配置（云盘文件不受影响）。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('解除绑定'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(accountServiceProvider).unbind(account.id, type);
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountsProvider).value ?? const <ProviderAccount>[];
    final settings = ref.watch(playbackSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('云盘'),
          for (final type in ProviderType.values)
            _ProviderCard(
              type: type,
              account: accounts
                  .where((a) => a.providerType == type.wireName)
                  .firstOrNull,
              binding: _binding[type] ?? false,
              onBind: () => _bind(type),
              onUnbind: (account) => _unbind(account, type),
              isTv: widget.isTv,
            ),
          const SizedBox(height: 24),
          _sectionTitle('播放'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('自动播放'),
                  subtitle: const Text('照片按时长切换；视频播放结束后自动下一项'),
                  value: settings.settings.autoPlay,
                  onChanged: (v) => settings.setAutoPlay(v),
                ),
                ListTile(
                  title: const Text('照片停留时间'),
                  subtitle: Text('${settings.settings.photoDurationSec} 秒'),
                  trailing: SizedBox(
                    width: 220,
                    child: Slider(
                      min: 1,
                      max: 60,
                      divisions: 59,
                      value: settings.settings.photoDurationSec.toDouble(),
                      onChanged: (v) => settings.setPhotoDuration(v.round()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (widget.isTv) ...[
            _sectionTitle('TV 配置'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('手机扫码同步'),
                subtitle: const Text('显示二维码，由手机端扫码同步网盘配置'),
                onTap: () => Navigator.of(context).pushNamed('/tv/pairing'),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            _sectionTitle('TV 配置'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.tv),
                title: const Text('扫码同步到 TV'),
                subtitle: const Text('扫描 TV 端二维码，将网盘配置同步到电视'),
                onTap: () => Navigator.of(context).pushNamed('/pairing/scan'),
              ),
            ),
            const SizedBox(height: 24),
          ],
          _sectionTitle('关于'),
          const Card(
            child: Column(
              children: [
                ListTile(title: Text('版本'), trailing: Text('1.0.0')),
                ListTile(
                  title: Text('隐私说明'),
                  subtitle: Text(
                    '凭据经 AES-GCM 加密存储于本机；'
                    '不上传用户媒体；配对仅在局域网内进行。',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

/// 单个 Provider 绑定卡片：状态 + 绑定/重认证/文件夹/解除绑定。
class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.type,
    required this.account,
    required this.binding,
    required this.onBind,
    required this.onUnbind,
    required this.isTv,
  });

  final ProviderType type;
  final ProviderAccount? account;
  final bool binding;
  final VoidCallback onBind;
  final void Function(ProviderAccount account) onUnbind;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final acc = account;
    final (statusText, statusColor) = switch (acc?.status) {
      null || AccountStatus.disconnected => ('未绑定', Colors.grey),
      AccountStatus.authenticated => ('已绑定', Colors.green),
      AccountStatus.needReauth => ('认证失效', Colors.orange),
      AccountStatus.syncing => ('同步中', Colors.blue),
      AccountStatus.error => ('同步异常', Colors.red),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (acc?.displayName.isNotEmpty == true) ...[
                            const SizedBox(width: 12),
                            Text(
                              acc!.displayName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: binding ? null : onBind,
                  child: binding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          acc == null
                              ? '绑定'
                              : acc.status == AccountStatus.needReauth
                              ? '重新认证'
                              : '重新认证',
                        ),
                ),
              ],
            ),
            if (acc != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                      '/settings/folders',
                      arguments: FolderPickerArgs(
                        accountId: acc.id,
                        providerType: type,
                      ),
                    ),
                    child: const Text('文件夹'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => onUnbind(acc),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('解除绑定'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 文件夹选择器参数。
class FolderPickerArgs {
  const FolderPickerArgs({required this.accountId, required this.providerType});

  final int accountId;
  final ProviderType providerType;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
