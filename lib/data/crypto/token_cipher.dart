import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/crypto/aes_gcm.dart';

/// Token 加密存储：AES-GCM 密文入库，密钥托管 Android Keystore（PRD §13/§42）。
///
/// - DB 只存密文
/// - 加密 key 不明文放数据库
/// - 日志/crash 上报不输出 token
abstract class TokenCipher {
  Future<String> encrypt(String plaintext);
  Future<String> decrypt(String ciphertext);
}

class KeystoreTokenCipher implements TokenCipher {
  KeystoreTokenCipher({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _keyAlias = 'sgpw.token.aes.key.v1';
  Uint8List? _cachedKey;

  Future<Uint8List> _getKey() async {
    if (_cachedKey != null) return _cachedKey!;
    final stored = await _storage.read(key: _keyAlias);
    if (stored != null && stored.isNotEmpty) {
      return _cachedKey = base64.decode(stored);
    }
    final key = generateAesKey();
    await _storage.write(key: _keyAlias, value: base64.encode(key));
    return _cachedKey = key;
  }

  @override
  Future<String> encrypt(String plaintext) async {
    final key = await _getKey();
    final encrypted = AesGcmCipher.encrypt(
      key,
      Uint8List.fromList(utf8.encode(plaintext)),
    );
    return base64.encode(encrypted);
  }

  @override
  Future<String> decrypt(String ciphertext) async {
    final key = await _getKey();
    final decrypted = AesGcmCipher.decrypt(key, base64.decode(ciphertext));
    return utf8.decode(decrypted);
  }
}

/// 明文实现（仅测试）。
class InsecureTokenCipher implements TokenCipher {
  @override
  Future<String> encrypt(String plaintext) async =>
      'enc:${base64.encode(utf8.encode(plaintext))}';

  @override
  Future<String> decrypt(String ciphertext) async =>
      utf8.decode(base64.decode(ciphertext.replaceFirst('enc:', '')));
}

/// 内存实现（仅测试）：模拟 Keystore AES-GCM。
class FakeAesTokenCipher implements TokenCipher {
  final Uint8List _key = generateAesKey();

  @override
  Future<String> encrypt(String plaintext) async => base64.encode(
    AesGcmCipher.encrypt(_key, Uint8List.fromList(utf8.encode(plaintext))),
  );

  @override
  Future<String> decrypt(String ciphertext) async =>
      utf8.decode(AesGcmCipher.decrypt(_key, base64.decode(ciphertext)));
}
