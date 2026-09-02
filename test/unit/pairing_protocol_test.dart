// Pairing 协议单元测试（PRD §16：QR payload + ECDH/AES-GCM 加密通道）。
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sgphotowall/core/crypto/aes_gcm.dart';
import 'package:sgphotowall/core/crypto/ecdh.dart';
import 'package:sgphotowall/features/pairing/pairing_models.dart';

PairingQrPayload _payload({
  String type = PairingQrPayload.kType,
  int expiresAt = 4102444800, // 2100-01-01
}) => PairingQrPayload(
  version: 1,
  type: type,
  host: '192.168.1.100',
  port: 39399,
  sessionId: 'session-1',
  nonce: 'nonce-1',
  tvPublicKey: 'pubkey',
  expiresAt: expiresAt,
);

void main() {
  group('PairingQrPayload', () {
    test('encode → tryParse 往返一致', () {
      final payload = _payload();
      final parsed = PairingQrPayload.tryParse(payload.encode());

      expect(parsed, isNotNull);
      expect(parsed!.host, payload.host);
      expect(parsed.port, payload.port);
      expect(parsed.sessionId, payload.sessionId);
      expect(parsed.nonce, payload.nonce);
      expect(parsed.tvPublicKey, payload.tvPublicKey);
      expect(parsed.expiresAt, payload.expiresAt);
    });

    test('类型不匹配返回 null', () {
      final raw = _payload(type: 'other_type').encode();
      expect(PairingQrPayload.tryParse(raw), isNull);
    });

    test('缺少必要字段返回 null', () {
      expect(PairingQrPayload.tryParse('not-json'), isNull);
      expect(PairingQrPayload.tryParse('{}'), isNull);
      expect(
        PairingQrPayload.tryParse(
          json.encode({
            'v': 1,
            'type': PairingQrPayload.kType,
            'host': '', // 空 host
            'port': 39399,
            'sessionId': 's',
            'nonce': 'n',
            'tvPublicKey': 'k',
            'expiresAt': 4102444800,
          }),
        ),
        isNull,
      );
    });

    test('isExpired 过期判断', () {
      final now = DateTime(2025, 6, 1);
      final alive = _payload(
        expiresAt: now.millisecondsSinceEpoch ~/ 1000 + 60,
      );
      final expired = _payload(
        expiresAt: now.millisecondsSinceEpoch ~/ 1000 - 60,
      );

      expect(alive.isExpired(now: now), isFalse);
      expect(expired.isExpired(now: now), isTrue);
    });

    test('二维码内容不包含 token 字段', () {
      final raw = _payload().encode();
      expect(raw.toLowerCase(), isNot(contains('token')));
      expect(raw.toLowerCase(), isNot(contains('secret')));
    });
  });

  group('PairingConfigRequest', () {
    test('toJson / tryParse 往返一致', () {
      final request = PairingConfigRequest(
        sessionId: 's1',
        nonce: 'n1',
        phonePublicKey: 'pk',
        ciphertext: 'cipher',
      );
      final parsed = PairingConfigRequest.tryParse(request.toJson());

      expect(parsed!.sessionId, 's1');
      expect(parsed.nonce, 'n1');
      expect(parsed.phonePublicKey, 'pk');
      expect(parsed.ciphertext, 'cipher');
    });

    test('缺少字段返回 null', () {
      expect(PairingConfigRequest.tryParse({}), isNull);
      expect(PairingConfigRequest.tryParse({'sessionId': 's1'}), isNull);
    });
  });

  group('E2E 加密通道（模拟 TV ↔ 手机）', () {
    test('TV 生成密钥对 → 手机协商共享密钥 → AES-GCM 配置密文可被 TV 解密', () {
      // TV 端：生成临时密钥对（QR 中携带公钥）。
      final tvKeys = EcdhKeyPair.generate();

      // 手机端：生成临时密钥对并与 TV 公钥协商。
      final phoneKeys = EcdhKeyPair.generate();
      final phoneShared = phoneKeys.deriveSharedKey(tvKeys.publicKeyEncoded);

      // 手机端加密配置 payload。
      const config = {
        'providers': [
          {
            'providerType': '115_CLOUD',
            'accountId': 'user-1',
            'folders': [
              {'remoteFolderId': 'f1', 'recursive': true},
            ],
          },
        ],
      };
      final plaintext = Uint8List.fromList(utf8.encode(json.encode(config)));
      final ciphertext = AesGcmCipher.encrypt(phoneShared, plaintext);

      // TV 端用手机公钥协商同一共享密钥并解密。
      final tvShared = tvKeys.deriveSharedKey(phoneKeys.publicKeyEncoded);
      final decrypted = AesGcmCipher.decrypt(tvShared, ciphertext);

      expect(json.decode(utf8.decode(decrypted)), config);
    });

    test('密文被中间人篡改后 TV 解密失败', () {
      final tvKeys = EcdhKeyPair.generate();
      final phoneKeys = EcdhKeyPair.generate();
      final shared = phoneKeys.deriveSharedKey(tvKeys.publicKeyEncoded);

      final ciphertext = AesGcmCipher.encrypt(
        shared,
        Uint8List.fromList(utf8.encode('config')),
      );
      ciphertext[ciphertext.length - 1] ^= 0xFF;

      final tvShared = tvKeys.deriveSharedKey(phoneKeys.publicKeyEncoded);
      expect(
        () => AesGcmCipher.decrypt(tvShared, ciphertext),
        throwsA(anything),
      );
    });
  });
}
