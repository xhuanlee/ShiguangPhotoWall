import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/provider/provider_models.dart';
import 'settings_screen.dart';

/// 文件夹选择器（PRD §4.2）：
/// - 浏览网盘目录树
/// - 勾选一个或多个文件夹（保存 folder ID + 完整路径快照）
/// - 保存后立即触发 SYNC_MANUAL
class FolderPickerScreen extends ConsumerStatefulWidget {
  const FolderPickerScreen({super.key, required this.args});

  final FolderPickerArgs args;

  @override
  ConsumerState<FolderPickerScreen> createState() => _FolderPickerScreenState();
}

class _FolderPickerScreenState extends ConsumerState<FolderPickerScreen> {
  final List<(String, String)> _stack = []; // (folderId, folderName)
  List<RemoteFolder> _folders = const [];
  bool _loading = false;
  String? _error;

  /// remoteFolderId → (folderName, folderPathSnapshot)
  final Map<String, (String, String)> _selected = {};

  ProviderType get _type => widget.args.providerType;

  String get _currentPath =>
      _stack.isEmpty ? '/' : '/${_stack.map((e) => e.$2).join('/')}';

  @override
  void initState() {
    super.initState();
    _loadExisting();
    _loadFolders();
  }

  Future<void> _loadExisting() async {
    final folders = await ref
        .read(appDaoProvider)
        .getFolders(widget.args.accountId);
    if (!mounted) return;
    setState(() {
      for (final f in folders) {
        _selected[f.remoteFolderId] = (f.folderName, f.folderPathSnapshot);
      }
    });
  }

  Future<void> _loadFolders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = ref.read(providerRegistryProvider).providerOf(_type);
    final result = await provider.listFolders(
      _stack.isEmpty ? null : _stack.last.$1,
    );
    if (!mounted) return;
    result.fold(
      ok: (folders) => setState(() {
        _folders = folders;
        _loading = false;
      }),
      err: (e) => setState(() {
        _loading = false;
        _error = '目录获取失败：$e';
      }),
    );
  }

  void _openFolder(RemoteFolder folder) {
    setState(() => _stack.add((folder.id, folder.name)));
    _loadFolders();
  }

  void _goUp() {
    if (_stack.isEmpty) return;
    setState(() => _stack.removeLast());
    _loadFolders();
  }

  void _toggle(RemoteFolder folder) {
    setState(() {
      final path = _currentPath == '/'
          ? '/${folder.name}'
          : '$_currentPath/${folder.name}';
      if (_selected.containsKey(folder.id)) {
        _selected.remove(folder.id);
      } else {
        _selected[folder.id] = (folder.name, path);
      }
    });
  }

  Future<void> _save() async {
    final dao = ref.read(appDaoProvider);
    final now = DateTime.now();
    await dao.replaceFolders(widget.args.accountId, [
      for (final entry in _selected.entries)
        FolderConfigsCompanion.insert(
          providerAccountId: widget.args.accountId,
          remoteFolderId: entry.key,
          folderName: entry.value.$1,
          folderPathSnapshot: entry.value.$2,
          createdAt: now,
          updatedAt: now,
        ),
    ]);
    // 保存后立即执行一次同步（PRD §4.2 默认行为）。
    if (mounted) {
      ref
          .read(syncServiceProvider)
          .sync(
            trigger: SyncTrigger.manual,
            providerAccountId: widget.args.accountId,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择文件夹 · ${_type.displayName}'),
        leading: BackButton(onPressed: _stack.isEmpty ? null : _goUp),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _currentPath,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '已选 ${_selected.length} 项',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _folders.isEmpty
                ? const Center(child: Text('此目录没有子文件夹'))
                : ListView.builder(
                    itemCount: _folders.length,
                    itemBuilder: (context, index) {
                      final folder = _folders[index];
                      final checked = _selected.containsKey(folder.id);
                      return ListTile(
                        leading: Checkbox(
                          value: checked,
                          onChanged: (_) => _toggle(folder),
                        ),
                        title: Text(folder.name),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openFolder(folder),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _selected.isEmpty ? null : _save,
            child: Text('保存并同步（${_selected.length} 个文件夹）'),
          ),
        ),
      ),
    );
  }
}
