// AES-GCM / ECDH 加密单元测试（PRD §42 安全规范）。
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sgphotowall/core/crypto/aes_gcm.dart';
import 'package:sgphotowall/core/crypto/ecdh.dart';

void main() {
  group('AesGcmCipher', () {
    test('加解密往返一致', () {
      final key = generateAesKey();
      final plaintext = Uint8List.fromList(utf8.encode('secret-token-限定'));

      final encrypted = AesGcmCipher.encrypt(key, plaintext);
      final decrypted = AesGcmCipher.decrypt(key, encrypted);

      expect(decrypted, plaintext);
    });

    test('密文包含 iv(12) + tag(16) 且不等于明文', () {
      final key = generateAesKey();
      final plaintext = Uint8List.fromList(List.generate(64, (i) => i));

      final encrypted = AesGcmCipher.encrypt(key, plaintext);

      expect(encrypted.length, plaintext.length + 12 + 16);
      expect(encrypted, isNot(equals(plaintext)));
    });

    test('同一密钥两次加密产生不同密文（随机 IV）', () {
      final key = generateAesKey();
      final plaintext = Uint8List.fromList(utf8.encode('same-input'));

      final a = AesGcmCipher.encrypt(key, plaintext);
      final b = AesGcmCipher.encrypt(key, plaintext);

      expect(a, isNot(equals(b)));
    });

    test('固定 IV 时加密结果确定（可复现）', () {
      final key = generateAesKey();
      final plaintext = Uint8List.fromList(utf8.encode('deterministic'));
      final iv = Uint8List.fromList(List.filled(12, 7));

      final a = AesGcmCipher.encrypt(key, plaintext, iv: iv);
      final b = AesGcmCipher.encrypt(key, plaintext, iv: iv);

      expect(a, equals(b));
    });

    test('密文被篡改时解密抛出异常（完整性保护）', () {
      final key = generateAesKey();
      final plaintext = Uint8List.fromList(utf8.encode('integrity'));
      final encrypted = AesGcmCipher.encrypt(key, plaintext);

      encrypted[encrypted.length - 1] ^= 0x01;

      expect(() => AesGcmCipher.decrypt(key, encrypted), throwsA(anything));
    });

    test('错误密钥解密抛出异常', () {
      final encrypted = AesGcmCipher.encrypt(
        generateAesKey(),
        Uint8List.fromList([1, 2, 3]),
      );

      expect(
        () => AesGcmCipher.decrypt(generateAesKey(), encrypted),
        throwsA(anything),
      );
    });

    test('AAD 不匹配时解密失败', () {
      final key = generateAesKey();
      final plaintext = Uint8List.fromList(utf8.encode('with-aad'));
      final encrypted = AesGcmCipher.encrypt(
        key,
        plaintext,
        aad: Uint8List.fromList(utf8.encode('pairing-session-1')),
      );

      expect(
        () => AesGcmCipher.decrypt(
          key,
          encrypted,
          aad: Uint8List.fromList(utf8.encode('pairing-session-2')),
        ),
        throwsA(anything),
      );
      // AAD 一致时可解密。
      expect(
        AesGcmCipher.decrypt(
          key,
          encrypted,
          aad: Uint8List.fromList(utf8.encode('pairing-session-1')),
        ),
        plaintext,
      );
    });

    test('过短输入抛 ArgumentError', () {
      expect(
        () => AesGcmCipher.decrypt(generateAesKey(), Uint8List(10)),
        throwsArgumentError,
      );
    });
  });

  group('EcdhKeyPair', () {
    test('双方独立生成密钥对，共享密钥推导一致', () {
      final tv = EcdhKeyPair.generate();
      final phone = EcdhKeyPair.generate();

      final tvShared = tv.deriveSharedKey(phone.publicKeyEncoded);
      final phoneShared = phone.deriveSharedKey(tv.publicKeyEncoded);

      expect(tvShared, equals(phoneShared));
      expect(tvShared, hasLength(32)); // SHA-256 → AES-256
    });

    test('公钥编码为 base64url（无 padding），可往返解码', () {
      final pair = EcdhKeyPair.generate();

      final encoded = pair.publicKeyEncoded;

      expect(encoded, isNot(contains('=')));
      expect(encoded, isNot(contains('+')));
      expect(encoded, isNot(contains('/')));

      // 可用于推导（解码成功）。
      final other = EcdhKeyPair.generate();
      expect(
        pair.deriveSharedKey(other.publicKeyEncoded),
        equals(other.deriveSharedKey(encoded)),
      );
    });

    test('每次生成的密钥对不同', () {
      final a = EcdhKeyPair.generate();
      final b = EcdhKeyPair.generate();

      expect(a.publicKeyEncoded, isNot(equals(b.publicKeyEncoded)));
    });

    test('不同会话的共享密钥不同（前向安全）', () {
      final tv1 = EcdhKeyPair.generate();
      final tv2 = EcdhKeyPair.generate();
      final phone = EcdhKeyPair.generate();

      expect(
        tv1.deriveSharedKey(phone.publicKeyEncoded),
        isNot(equals(tv2.deriveSharedKey(phone.publicKeyEncoded))),
      );
    });
  });
}
