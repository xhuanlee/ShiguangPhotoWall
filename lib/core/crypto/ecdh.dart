import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// ECDH P-256 临时密钥对（Pairing 用）。
class EcdhKeyPair {
  EcdhKeyPair._(this.privateKey, this.publicKey);

  final ECPrivateKey privateKey;
  final ECPublicKey publicKey;

  factory EcdhKeyPair.generate() {
    final secureRandom = _secureRandom();
    final generator = ECKeyGenerator()
      ..init(
        ParametersWithRandom(
          ECKeyGeneratorParameters(ECDomainParameters('secp256r1')),
          secureRandom,
        ),
      );
    final keyPair = generator.generateKeyPair();
    return EcdhKeyPair._(
      keyPair.privateKey as ECPrivateKey,
      keyPair.publicKey as ECPublicKey,
    );
  }

  /// base64url 编码的公钥（未压缩点 65 字节）。
  String get publicKeyEncoded => _encodeUrl(_uncompressedPoint(publicKey));

  static Uint8List _uncompressedPoint(ECPublicKey pub) {
    final q = pub.Q!;
    return Uint8List.fromList([
      0x04,
      ..._bigIntToFixedBytes(q.x!.toBigInteger()!, 32),
      ..._bigIntToFixedBytes(q.y!.toBigInteger()!, 32),
    ]);
  }

  /// 与对端公钥计算 ECDH 共享密钥（SHA-256 → AES-256 key）。
  Uint8List deriveSharedKey(String peerPublicKeyEncoded) {
    final peerPoint = _decodePoint(peerPublicKeyEncoded);
    final agreement = ECDHBasicAgreement()..init(privateKey);
    final shared = agreement.calculateAgreement(
      ECPublicKey(peerPoint, privateKey.parameters!),
    );
    final sharedBytes = _bigIntToFixedBytes(shared, 32);
    // SHA-256 派生对称密钥
    final digest = SHA256Digest();
    return digest.process(sharedBytes);
  }

  static ECPoint _decodePoint(String encoded) {
    final bytes = _decodeUrl(encoded);
    final curve = ECDomainParameters('secp256r1').curve;
    return curve.decodePoint(bytes)!;
  }
}

String _encodeUrl(Uint8List bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

Uint8List _decodeUrl(String s) {
  final normalized = s.replaceAll('-', '+').replaceAll('_', '/');
  final padded = normalized + '=' * ((4 - normalized.length % 4) % 4);
  return base64.decode(padded);
}

Uint8List _bigIntToFixedBytes(BigInt value, int length) {
  final hex = value.toRadixString(16).padLeft(length * 2, '0');
  return Uint8List.fromList([
    for (var i = 0; i < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ]);
}

SecureRandom _secureRandom() {
  final secureRandom = FortunaRandom();
  final seedSource = Random.secure();
  final seeds = Uint8List.fromList(
    List<int>.generate(32, (_) => seedSource.nextInt(256)),
  );
  secureRandom.seed(KeyParameter(seeds));
  return secureRandom;
}
