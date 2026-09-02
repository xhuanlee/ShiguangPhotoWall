/// 应用形态配置。
///
/// UI 布局由窗口尺寸决定；输入设备策略由 form factor 决定。
enum AppFlavor { mobile, tv }

class AppConfig {
  AppConfig._();

  static AppFlavor flavor = AppFlavor.mobile;

  static bool get isTv => flavor == AppFlavor.tv;

  static void init(AppFlavor value) => flavor = value;
}
