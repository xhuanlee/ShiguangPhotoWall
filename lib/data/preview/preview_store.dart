import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Preview 磁盘缓存（PRD §12）。
///
/// - 命名：sha256(provider|account|remoteId|version|size).webp
/// - 只保存小尺寸缩略图
/// - 可删除、可重新生成、不影响数据库核心数据
class PreviewStore {
  PreviewStore(this.baseDir);

  final Directory baseDir;

  static const int gridLongEdge = 720;
  static const int tvLongEdge = 1080;

  /// 生成 preview 相对文件名。
  static String relativeName({
    required String providerType,
    required String accountKey,
    required String remoteId,
    String? version,
    int? size,
  }) {
    final digest = sha256.convert(
      utf8.encode('$providerType|$accountKey|$remoteId|$version|$size'),
    );
    return '${digest.toString()}.webp';
  }

  Directory get _dir {
    if (!baseDir.existsSync()) baseDir.createSync(recursive: true);
    return baseDir;
  }

  File file(String relative) => File('${_dir.path}/$relative');

  bool exists(String relative) => file(relative).existsSync();

  Future<void> write(String relative, List<int> bytes) async {
    final f = file(relative);
    await f.writeAsBytes(bytes, flush: true);
  }

  Future<void> delete(String relative) async {
    final f = file(relative);
    if (f.existsSync()) await f.delete();
  }

  /// 列出全部 preview 相对路径（GC 输入）。
  List<String> listAll() => _dir
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .toList();
}
