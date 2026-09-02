import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/providers.dart';
import 'pairing_client.dart';
import 'pairing_models.dart';

/// 手机扫码同步页（PRD §16.3）：
/// 扫描 TV 二维码 → ECDH + AES-GCM 加密配置 → 局域网 POST。
class PhoneScanScreen extends ConsumerStatefulWidget {
  const PhoneScanScreen({super.key});

  @override
  ConsumerState<PhoneScanScreen> createState() => _PhoneScanScreenState();
}

class _PhoneScanScreenState extends ConsumerState<PhoneScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _success) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    // 只处理本应用配对二维码。
    if (!raw.contains(PairingQrPayload.kType)) return;

    _processing = true;
    setState(() => _error = null);

    final error = await PairingClient().sendConfig(
      qrRaw: raw,
      dao: ref.read(appDaoProvider),
      cipher: ref.read(tokenCipherProvider),
    );

    if (!mounted) return;
    setState(() {
      _processing = false;
      if (error == null) {
        _success = true;
      } else {
        _error = error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码同步到 TV')),
      body: _success
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 72,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text('同步成功，TV 正在刷新'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('完成'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                if (_error != null)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 120,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _processing ? Colors.orange : Colors.white70,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
