import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart' show SyncTrigger;
import 'pairing_models.dart';
import 'pairing_server.dart';

/// TV Pairing Server provider（设置页进入时创建）。
final tvPairingServerProvider = Provider<PairingServer>(
  (ref) => PairingServer(
    dao: ref.watch(appDaoProvider),
    cipher: ref.watch(tokenCipherProvider),
    onConfigApplied: () =>
        ref.read(syncServiceProvider).sync(trigger: SyncTrigger.pairing),
  ),
);

/// TV 二维码配对页（PRD §16.1）：
/// - 显示二维码（不含 token）
/// - 120 秒过期倒计时 + 刷新
/// - 手机发送配置成功后显示成功并自动刷新
class TvPairingScreen extends ConsumerStatefulWidget {
  const TvPairingScreen({super.key});

  @override
  ConsumerState<TvPairingScreen> createState() => _TvPairingScreenState();
}

class _TvPairingScreenState extends ConsumerState<TvPairingScreen> {
  PairingQrPayload? _payload;
  String? _error;
  Timer? _countdown;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() => _error = null);
    try {
      final payload = await ref.read(tvPairingServerProvider).start();
      if (!mounted) return;
      if (payload == null) {
        setState(() => _error = '未找到局域网地址，请检查 Wi-Fi 连接');
        return;
      }
      setState(() {
        _payload = payload;
        _remainingSeconds =
            payload.expiresAt - DateTime.now().millisecondsSinceEpoch ~/ 1000;
      });
      _startCountdown();
    } catch (e) {
      if (mounted) setState(() => _error = '配对服务启动失败：$e');
    }
  }

  void _startCountdown() {
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() => _payload = null); // QR 过期
      }
    });
  }

  Future<void> _stopAndClose() async {
    await ref.read(tvPairingServerProvider).stop();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('手机扫码同步'),
        leading: BackButton(onPressed: _stopAndClose),
      ),
      body: Center(
        child: _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _startSession,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('重试', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              )
            : _payload == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('二维码已过期', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _startSession,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('刷新二维码', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: QrImageView(
                      data: _payload!.encode(),
                      version: QrVersions.auto,
                      size: 320,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '使用手机端「设置 → 扫码同步到 TV」扫码',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '二维码 $_remainingSeconds 秒后过期',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _remainingSeconds <= 30
                          ? theme.colorScheme.error
                          : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
