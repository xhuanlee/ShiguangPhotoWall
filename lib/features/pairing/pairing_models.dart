import 'dart:convert';

/// Pairing QR 码内容（PRD §16.2）。
///
/// 二维码不得直接包含 Access Token / Refresh Token。
class PairingQrPayload {
  const PairingQrPayload({
    required this.version,
    required this.type,
    required this.host,
    required this.port,
    required this.sessionId,
    required this.nonce,
    required this.tvPublicKey,
    required this.expiresAt,
  });

  final int version;
  final String type;
  final String host;
  final int port;
  final String sessionId;
  final String nonce;
  final String tvPublicKey;

  /// Unix 秒。
  final int expiresAt;

  static const String kType = 'photo_wall_pairing';
  static const Duration defaultTtl = Duration(seconds: 120);

  bool isExpired({DateTime? now}) =>
      (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000 >= expiresAt;

  Map<String, dynamic> toJson() => {
    'v': version,
    'type': type,
    'host': host,
    'port': port,
    'sessionId': sessionId,
    'nonce': nonce,
    'tvPublicKey': tvPublicKey,
    'expiresAt': expiresAt,
  };

  String encode() => json.encode(toJson());

  /// 解析失败返回 null。
  static PairingQrPayload? tryParse(String raw) {
    try {
      final json = const JsonDecoder().convert(raw);
      if (json is! Map<String, dynamic>) return null;
      final payload = PairingQrPayload(
        version: json['v'] as int? ?? 1,
        type: json['type'] as String? ?? '',
        host: json['host'] as String? ?? '',
        port: json['port'] as int? ?? 0,
        sessionId: json['sessionId'] as String? ?? '',
        nonce: json['nonce'] as String? ?? '',
        tvPublicKey: json['tvPublicKey'] as String? ?? '',
        expiresAt: json['expiresAt'] as int? ?? 0,
      );
      if (payload.type != kType) return null;
      if (payload.host.isEmpty ||
          payload.port <= 0 ||
          payload.sessionId.isEmpty ||
          payload.nonce.isEmpty ||
          payload.tvPublicKey.isEmpty) {
        return null;
      }
      return payload;
    } catch (_) {
      return null;
    }
  }
}

/// 手机端提交的加密配置请求体。
class PairingConfigRequest {
  const PairingConfigRequest({
    required this.sessionId,
    required this.nonce,
    required this.phonePublicKey,
    required this.ciphertext,
  });

  final String sessionId;
  final String nonce;

  /// base64url 编码的手机端 ECDH 公钥。
  final String phonePublicKey;

  /// base64 编码的 AES-GCM 密文（payload JSON）。
  final String ciphertext;

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'nonce': nonce,
    'phonePublicKey': phonePublicKey,
    'ciphertext': ciphertext,
  };

  static PairingConfigRequest? tryParse(Map<String, dynamic> json) {
    final sessionId = json['sessionId'] as String?;
    final nonce = json['nonce'] as String?;
    final phonePublicKey = json['phonePublicKey'] as String?;
    final ciphertext = json['ciphertext'] as String?;
    if (sessionId == null ||
        nonce == null ||
        phonePublicKey == null ||
        ciphertext == null) {
      return null;
    }
    return PairingConfigRequest(
      sessionId: sessionId,
      nonce: nonce,
      phonePublicKey: phonePublicKey,
      ciphertext: ciphertext,
    );
  }
}

/// Pairing 服务端响应。
class PairingResponse {
  const PairingResponse({required this.ok, this.error});

  final bool ok;
  final String? error;

  Map<String, dynamic> toJson() => {
    'ok': ok,
    if (error != null) 'error': error,
  };

  String encode() => json.encode(toJson());
}
