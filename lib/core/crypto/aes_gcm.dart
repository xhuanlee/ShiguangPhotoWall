import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// AES-GCM 加解密封装。
class AesGcmCipher {
  AesGcmCipher._();

  static const int _ivLength = 12;
  static const int _tagLength = 16; // 128 bit

  /// 加密：返回 iv(12) + ciphertext + tag(16)。
  static Uint8List encrypt(
    Uint8List key,
    Uint8List plaintext, {
    Uint8List? iv,
    Uint8List? aad,
  }) {
    final effectiveIv = iv ?? _randomIv();
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(key),
          _tagLength * 8,
          effectiveIv,
          aad ?? Uint8List(0),
        ),
      );
    final encrypted = cipher.process(plaintext);
    final out = BytesBuilder()
      ..add(effectiveIv)
      ..add(encrypted);
    return out.toBytes();
  }

  /// 解密：输入 iv(12) + ciphertext + tag(16)。
  static Uint8List decrypt(Uint8List key, Uint8List data, {Uint8List? aad}) {
    if (data.length < _ivLength + _tagLength) {
      throw ArgumentError('data too short for AES-GCM');
    }
    final iv = Uint8List.sublistView(data, 0, _ivLength);
    final encrypted = Uint8List.sublistView(data, _ivLength);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(key),
          _tagLength * 8,
          iv,
          aad ?? Uint8List(0),
        ),
      );
    return cipher.process(encrypted);
  }

  static Uint8List _randomIv() {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_ivLength, (_) => rng.nextInt(256)),
    );
  }
}

/// 生成随机 AES-256 密钥。
Uint8List generateAesKey() {
  final rng = Random.secure();
  return Uint8List.fromList(List<int>.generate(32, (_) => rng.nextInt(256)));
}
