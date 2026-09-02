# Flutter 引擎
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Drift generated
-keep class *.db.* { *; }

# Play Core（未启用的 Deferred Components，Flutter 引擎引用）
-dontwarn com.google.android.play.core.**

-dontwarn junit.framework.**
