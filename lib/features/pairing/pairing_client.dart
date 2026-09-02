import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/crypto/aes_gcm.dart';
import '../../core/crypto/ecdh.dart';
import '../../data/db/app_database.dart';
import '../../data/crypto/token_cipher.dart';
import '../../data/sync/sync_engine.dart' show buildPairingPayload;
import 'pairing_models.dart';

/// 手机端 Pairing 客户端（PRD §16.3）：
/// 1. 扫描二维码 → 解析 host/port/sessionId/nonce/tvPublicKey
/// 2. 生成手机端 ECDH 密钥对，与 TV 公钥协商共享密钥
/// 3. AES-GCM 加密配置 payload（PRD §16.3 Payload 结构）
/// 4. POST 给 TV；QR 过期 / session 拒绝 / 解密失败 → 明确报错
class PairingClient {
  PairingClient({Dio? dio, this.timeout = const Duration(seconds: 10)})
    : _dio = dio ?? Dio();

  final Dio _dio;
  final Duration timeout;

  /// 执行完整配对流程。返回错误消息（null = 成功）。
  Future<String?> sendConfig({
    required String qrRaw,
    required AppDao dao,
    required TokenCipher cipher,
  }) async {
    final qr = PairingQrPayload.tryParse(qrRaw);
    if (qr == null) return '二维码内容无效';
    if (qr.isExpired()) return '二维码已过期，请刷新 TV 端二维码';

    // 导出本机网盘配置。
    final payload = await buildPairingPayload(dao: dao, cipher: cipher);
    if ((payload['providers'] as List).isEmpty) {
      return '本机没有可同步的网盘配置';
    }

    // ECDH 密钥协商。
    final phoneKeyPair = EcdhKeyPair.generate();
    final sharedKey = phoneKeyPair.deriveSharedKey(qr.tvPublicKey);

    // AES-GCM 加密。
    final plaintext = Uint8List.fromList(utf8.encode(json.encode(payload)));
    final ciphertext = AesGcmCipher.encrypt(sharedKey, plaintext);

    final request = PairingConfigRequest(
      sessionId: qr.sessionId,
      nonce: qr.nonce,
      phonePublicKey: phoneKeyPair.publicKeyEncoded,
      ciphertext: base64.encode(ciphertext),
    );

    try {
      final response = await _dio.post<void>(
        'http://${qr.host}:${qr.port}/pairing/config',
        data: request.toJson(),
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: {'content-type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        return null;
      }
      return '同步失败（HTTP ${response.statusCode}）';
    } on DioException catch (e) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => '连接超时，请确认手机与 TV 在同一局域网',
        DioExceptionType.connectionError => '无法连接 TV，请确认手机与 TV 在同一局域网',
        _ => '同步失败：${e.message}',
      };
    } on SocketException {
      return '无法连接 TV，请确认手机与 TV 在同一局域网';
    }
  }
}
