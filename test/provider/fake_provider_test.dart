// Fake Provider 契约测试（CloudProvider 接口语义，PRD §26-§29）。
import 'package:flutter_test/flutter_test.dart';
import 'package:sgphotowall/core/result/result.dart';
import 'package:sgphotowall/data/provider/fake_provider.dart';
import 'package:sgphotowall/data/provider/provider_models.dart';

RemoteMedia _file(String id, {String folder = 'f1', int size = 100}) =>
    RemoteMedia(
      remoteFileId: id,
      parentFolderId: folder,
      name: '$id.jpg',
      mediaType: MediaType.image,
      mimeType: 'image/jpeg',
      sizeBytes: size,
      modifiedTime: DateTime(2025, 1, 1),
    );

void main() {
  group('listFolders', () {
    test('返回指定父目录的子文件夹', () async {
      final provider = FakeCloudProvider(
        folderTree: {
          null: [const RemoteFolder(id: 'f1', name: '照片')],
          'f1': [
            const RemoteFolder(id: 'f1-1', name: '2024', parentId: 'f1'),
            const RemoteFolder(id: 'f1-2', name: '2025', parentId: 'f1'),
          ],
        },
      );

      final root = await provider.listFolders(null);
      final children = await provider.listFolders('f1');

      expect((root as Ok).value, hasLength(1));
      expect((children as Ok).value, hasLength(2));
    });

    test('未知目录返回空列表', () async {
      final provider = FakeCloudProvider();
      final result = await provider.listFolders('nonexistent');
      expect((result as Ok).value, isEmpty);
    });
  });

  group('listMedia 分页契约', () {
    test('按 cursor 分页遍历全部文件', () async {
      final provider = FakeCloudProvider(
        pageSize: 3,
        files: [
          for (var i = 0; i < 8; i++) _file('f${i.toString().padLeft(2, '0')}'),
        ],
      );

      final collected = <RemoteMedia>[];
      String? cursor;
      var pages = 0;
      do {
        final result = await provider.listMedia('f1', cursor);
        final page = (result as Ok).value as RemotePage<RemoteMedia>;
        collected.addAll(page.items);
        cursor = page.nextCursor;
        pages++;
      } while (cursor != null);

      expect(pages, 3); // 3 + 3 + 2
      expect(collected, hasLength(8));
      expect(collected.map((m) => m.remoteFileId).toSet(), hasLength(8));
    });

    test('空目录返回空页且无 nextCursor', () async {
      final provider = FakeCloudProvider();
      final result = await provider.listMedia('f1', null);
      final page = (result as Ok).value as RemotePage<RemoteMedia>;

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('seedFiles 可重置数据', () async {
      final provider = FakeCloudProvider(files: [_file('a')]);
      expect(
        (((await provider.listMedia('f1', null)) as Ok).value
                as RemotePage<RemoteMedia>)
            .items,
        hasLength(1),
      );

      provider.seedFiles([_file('a'), _file('b')]);
      expect(
        (((await provider.listMedia('f1', null)) as Ok).value
                as RemotePage<RemoteMedia>)
            .items,
        hasLength(2),
      );
    });
  });

  group('错误注入（同步失败保留旧数据测试，PRD §31）', () {
    test('网络错误：所有远端调用返回 Offline', () async {
      final provider = FakeCloudProvider(throwNetworkError: true);

      expect((await provider.listFolders(null)) is Err, isTrue);
      expect((await provider.listMedia('f1', null)) is Err, isTrue);
      expect((await provider.getPlayableUrl('m1')) is Err, isTrue);
      expect((await provider.getOriginalImageSource('m1')) is Err, isTrue);
      expect(
        (await provider.downloadBytes('https://fake.local/x')) is Err,
        isTrue,
      );
    });

    test('凭据过期：validateCredential 返回 needReauth', () async {
      final provider = FakeCloudProvider(credentialsExpired: true);
      expect(await provider.validateCredential(), CredentialState.needReauth);

      provider.credentialsExpired = false;
      expect(
        await provider.validateCredential(),
        CredentialState.authenticated,
      );
    });
  });

  group('媒体源契约', () {
    test('getPlayableUrl 返回带时效的 URL', () async {
      final provider = FakeCloudProvider();
      final result = await provider.getPlayableUrl('m1');
      final source = (result as Ok).value as PlayableSource;

      expect(source.url, contains('m1'));
      expect(source.expiresAt, isNotNull);
      expect(source.expiresAt!.isAfter(DateTime.now()), isTrue);
    });

    test('getOriginalImageSource 返回原图 URL', () async {
      final provider = FakeCloudProvider();
      final result = await provider.getOriginalImageSource('m1');
      final source = (result as Ok).value as ImageSource;

      expect(source.url, contains('m1'));
    });

    test('downloadBytes 返回有效 PNG 头', () async {
      final provider = FakeCloudProvider();
      final result = await provider.downloadBytes('https://fake.local/x');
      final bytes = (result as Ok).value;

      expect(bytes[0], 0x89); // PNG magic
      expect(bytes[1], 0x50); // 'P'
    });
  });

  group('授权契约', () {
    test('authorize / refreshCredential 返回有效凭据', () async {
      final provider = FakeCloudProvider();

      final auth = await provider.authorize();
      expect(auth, isA<AuthSuccess>());
      final creds = (auth as AuthSuccess).credentials;
      expect(creds.isExpired, isFalse);

      final refreshed = await provider.refreshCredential();
      expect(refreshed, isA<AuthSuccess>());
    });

    test('logoutOrRevoke 成功', () async {
      final provider = FakeCloudProvider();
      expect(await provider.logoutOrRevoke(), isA<Ok<void>>());
    });
  });

  group('ProviderType', () {
    test('wireName 与 fromWire 往返一致', () {
      for (final type in ProviderType.values) {
        expect(ProviderType.fromWire(type.wireName), type);
      }
      expect(ProviderType.fromWire('UNKNOWN'), isNull);
    });
  });

  group('MediaType.fromFile', () {
    test('按扩展名识别图片/视频', () {
      expect(MediaType.fromFile('a.jpg', null), MediaType.image);
      expect(MediaType.fromFile('b.HEIC', null), MediaType.image);
      expect(MediaType.fromFile('c.mp4', null), MediaType.video);
      expect(MediaType.fromFile('d.MOV', null), MediaType.video);
      expect(MediaType.fromFile('e.docx', null), isNull);
    });

    test('按 MIME 类型兜底', () {
      expect(MediaType.fromFile('file', 'image/png'), MediaType.image);
      expect(MediaType.fromFile('file', 'video/mp4'), MediaType.video);
    });
  });
}
