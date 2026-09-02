import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../core/crypto/aes_gcm.dart';
import '../../core/crypto/ecdh.dart';
import '../../data/crypto/token_cipher.dart';
import '../../data/db/app_database.dart';
import '../../data/sync/sync_engine.dart' show applyPairingPayload;
import 'pairing_models.dart';

/// Pairing 会话（内存态；一次性、120 秒过期，PRD §16.5）。
class PairingSession {
  PairingSession({
    required this.sessionId,
    required this.nonce,
    required this.keyPair,
    required this.expiresAt,
  });

  final String sessionId;
  final String nonce;
  final EcdhKeyPair keyPair;
  final DateTime expiresAt;
  bool used = false;
}

/// 会话管理：创建 / 校验 / 消费（一次性）。
class PairingSessionManager {
  final Map<String, PairingSession> _sessions = {};

  static String _randomToken({int bytes = 16}) {
    final rng = Random.secure();
    final values = List<int>.generate(bytes, (_) => rng.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  PairingSession create({Duration ttl = PairingQrPayload.defaultTtl}) {
    // 清理过期会话。
    final now = DateTime.now();
    _sessions.removeWhere((_, s) => s.expiresAt.isBefore(now) || s.used);
    final session = PairingSession(
      sessionId: _randomToken(bytes: 16), // 128-bit
      nonce: _randomToken(bytes: 16),
      keyPair: EcdhKeyPair.generate(),
      expiresAt: now.add(ttl),
    );
    _sessions[session.sessionId] = session;
    return session;
  }

  /// 校验 sessionId + nonce；返回会话（未过期未使用且 nonce 匹配）。
  PairingSession? validate(String sessionId, String nonce) {
    final session = _sessions[sessionId];
    if (session == null || session.used) return null;
    if (DateTime.now().isAfter(session.expiresAt)) return null;
    if (session.nonce != nonce) return null;
    return session;
  }

  /// 消费会话（一次性：发送成功后立即作废）。
  void consume(PairingSession session) => session.used = true;

  /// 预留：解密失败的会话也作废，防止重放。
  void invalidate(String sessionId) => _sessions.remove(sessionId);
}

/// TV 端 Pairing LAN Server（PRD §16）。
///
/// - 仅绑定局域网接口，不监听公网
/// - POST /pairing/config：session/nonce 校验 → ECDH 解密 → 落库 → 会话作废
class PairingServer {
  PairingServer({
    required this.dao,
    required this.cipher,
    required this.onConfigApplied,
    this.port = 19420,
  });

  final AppDao dao;
  final TokenCipher cipher;

  /// 配置接收成功后的回调（TV 自动触发一次刷新）。
  final FutureOr<void> Function() onConfigApplied;
  final int port;

  final PairingSessionManager sessions = PairingSessionManager();
  HttpServer? _server;

  bool get isRunning => _server != null;
  String? boundAddress;

  /// 获取本机局域网 IPv4 地址。
  static Future<String?> lanAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return null;
  }

  /// 启动服务器并创建一个新会话，返回 QR payload。
  Future<PairingQrPayload?> start() async {
    final host = await lanAddress();
    if (host == null) return null;

    if (_server == null) {
      _server = await shelf_io.serve(
        _handler,
        InternetAddress(host), // 仅局域网接口
        port,
        shared: true,
      );
      boundAddress = host;
    }

    final session = sessions.create();
    final payload = PairingQrPayload(
      version: 1,
      type: PairingQrPayload.kType,
      host: host,
      port: port,
      sessionId: session.sessionId,
      nonce: session.nonce,
      tvPublicKey: session.keyPair.publicKeyEncoded,
      expiresAt: session.expiresAt.millisecondsSinceEpoch ~/ 1000,
    );

    // 会话入库（审计/一次性消费持久化）。
    await dao.insertPairingSession(
      PairingSessionsCompanion.insert(
        sessionId: session.sessionId,
        nonce: session.nonce,
        tvPublicKey: session.keyPair.publicKeyEncoded,
        expiresAt: session.expiresAt,
      ),
    );

    return payload;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    boundAddress = null;
    await dao.deleteExpiredPairingSessions();
  }

  Future<Response> _handler(Request request) async {
    if (request.method != 'POST' || request.url.path != 'pairing/config') {
      return Response(
        404,
        body: const PairingResponse(ok: false, error: 'not found').encode(),
      );
    }
    return _handleConfig(request);
  }

  Future<Response> _handleConfig(Request request) async {
    Map<String, dynamic> body;
    try {
      final raw = await request.readAsString();
      body = raw.isEmpty ? const {} : json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return _reject(400, 'malformed payload');
    }

    final req = PairingConfigRequest.tryParse(body);
    if (req == null) return _reject(400, 'malformed payload');

    // expired / used / invalid nonce → reject。
    final session = sessions.validate(req.sessionId, req.nonce);
    if (session == null) {
      return _reject(403, 'session rejected');
    }

    // ECDH 共享密钥派生 + AES-GCM 解密。
    Map<String, dynamic> payload;
    try {
      final sharedKey = session.keyPair.deriveSharedKey(req.phonePublicKey);
      final ciphertext = base64.decode(req.ciphertext);
      final plaintext = AesGcmCipher.decrypt(
        sharedKey,
        Uint8List.fromList(ciphertext),
      );
      payload = json.decode(utf8.decode(plaintext)) as Map<String, dynamic>;
    } catch (_) {
      // wrong public key / decrypt failure / malformed payload → session 作废。
      sessions.invalidate(req.sessionId);
      return _reject(403, 'decrypt failed');
    }

    try {
      await applyPairingPayload(dao: dao, cipher: cipher, payload: payload);
    } catch (_) {
      return _reject(500, 'apply failed');
    }

    // 成功：会话一次性作废。
    sessions.consume(session);
    await dao.markPairingSessionUsed(req.sessionId);
    unawaited(Future.sync(onConfigApplied));

    return Response.ok(
      const PairingResponse(ok: true).encode(),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _reject(int status, String error) => Response(
    status,
    body: PairingResponse(ok: false, error: error).encode(),
    headers: {'content-type': 'application/json'},
  );
}
