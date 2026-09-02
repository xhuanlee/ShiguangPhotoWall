// TV 遥控器长按快进/快退状态机单元测试（PRD §0-3 / §8.3）。
import 'package:flutter_test/flutter_test.dart';
import 'package:sgphotowall/features/viewer/tv_seek_logic.dart';

void main() {
  final start = DateTime(2025, 1, 1, 12);

  group('短按（tap）', () {
    test('阈值前抬起 → onUp 返回 true 且未进入 seeking', () {
      final logic = TvSeekLogic();
      logic.onDown(forward: true, now: start);

      final before = logic.onRepeat(
        start.add(const Duration(milliseconds: 200)),
      );
      expect(before, isNull); // 未达长按阈值
      expect(logic.isSeeking, isFalse);

      final wasTap = logic.onUp();
      expect(wasTap, isTrue);
    });
  });

  group('长按（seek）', () {
    test('超过阈值进入 seeking，步长 10s 起步', () {
      final logic = TvSeekLogic();
      logic.onDown(forward: true, now: start);

      final seek = logic.onRepeat(start.add(const Duration(milliseconds: 500)));
      expect(seek, const Duration(seconds: 10));
      expect(logic.isSeeking, isTrue);
      expect(logic.onUp(), isFalse);
    });

    test('快退方向返回负值', () {
      final logic = TvSeekLogic();
      logic.onDown(forward: false, now: start);

      final seek = logic.onRepeat(start.add(const Duration(milliseconds: 500)));
      expect(seek, const Duration(seconds: -10));
    });

    test('repeatInterval 内不重复触发', () {
      final logic = TvSeekLogic();
      logic.onDown(forward: true, now: start);

      expect(
        logic.onRepeat(start.add(const Duration(milliseconds: 500))),
        const Duration(seconds: 10),
      );
      // 100ms < 180ms repeatInterval → 不触发。
      expect(
        logic.onRepeat(start.add(const Duration(milliseconds: 600))),
        isNull,
      );
      // 超过 repeatInterval → 再次触发。
      expect(
        logic.onRepeat(start.add(const Duration(milliseconds: 700))),
        const Duration(seconds: 10),
      );
    });

    test('步长随持续时间递增 10s → 30s → 60s', () {
      final logic = TvSeekLogic();
      logic.onDown(forward: true, now: start);

      // level 0：阈值后 1.5s 内。
      expect(
        logic.onRepeat(start.add(const Duration(milliseconds: 500))),
        const Duration(seconds: 10),
      );
      // level 1：阈值后 1.5~3s。
      expect(
        logic.onRepeat(start.add(const Duration(milliseconds: 2000))),
        const Duration(seconds: 30),
      );
      // level 2：阈值后 3s 以上（封顶）。
      expect(
        logic.onRepeat(start.add(const Duration(milliseconds: 4000))),
        const Duration(seconds: 60),
      );
      // 封顶后不再增长。
      expect(
        logic.onRepeat(start.add(const Duration(milliseconds: 6000))),
        const Duration(seconds: 60),
      );
    });

    test('抬起后重新按下重新计时', () {
      final logic = TvSeekLogic();
      logic.onDown(forward: true, now: start);
      logic.onRepeat(start.add(const Duration(milliseconds: 500)));
      expect(logic.onUp(), isFalse);

      // 第二次按下：新的长按。
      final second = start.add(const Duration(seconds: 10));
      logic.onDown(forward: true, now: second);
      expect(
        logic.onRepeat(second.add(const Duration(milliseconds: 500))),
        const Duration(seconds: 10),
      );
    });

    test('未按下时 onRepeat / onUp 无副作用', () {
      final logic = TvSeekLogic();
      expect(logic.onRepeat(start), isNull);
      expect(logic.onUp(), isFalse);
      expect(logic.isSeeking, isFalse);
    });
  });
}
