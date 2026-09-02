# 拾光 · 影像墙（ShiguangPhotoWall）

聚合云盘照片/视频的**手机**与 **Android TV** 照片墙应用。基于 Flutter 构建，单工程双 flavor。

## 功能

- **多云盘聚合**：天翼云盘 / 115 网盘（OAuth 2.0 + PKCE 授权，凭据 AES-GCM 加密存储）
- **增量同步**：目录树遍历 → 分页拉取 → Diff（增/改/删）→ WebP 预览生成 → 孤儿预览 GC
- **手机端**：首页 / 照片 / 视频底部导航，分页网格，图片查看与视频播放
- **TV 端**：左侧焦点导航 + 媒体网格，遥控器 D-pad 导航，长按左右键快进/快退（10s→30s→60s 递增）
- **局域网配对**：TV 展示二维码（不含 token），手机扫码后经 ECDH P-256 密钥协商 + AES-GCM 加密通道同步网盘配置
- **同步可视化**：连接 → 目录 → 媒体 → 预览 → 清理各阶段状态展示，认证失效 Banner 提示

## 架构

```
lib/
├── app/          # 入口、路由、Provider 注入、Shell（mobile/tv）
├── core/         # 配置、加密（AES-GCM / ECDH）、错误模型、工具
├── data/         # Drift 数据库（6 表）、CloudProvider 实现、同步引擎、预览管理
└── features/     # gallery / home / pairing / settings / viewer
```

技术栈：Flutter + Riverpod + GoRouter + Drift(SQLite) + Dio + pointycastle + Shelf。

## 开发

```bash
flutter pub get
dart run build_runner build --delete-conflicting-tracts   # 重新生成 Drift 代码

flutter analyze
flutter test

# 手机端
flutter run --flavor mobile
# TV 端
flutter run --flavor tv
```

> Gradle 需要 JDK 17+：`export JAVA_HOME=$(/usr/libexec/java_home -v 17)`

## 构建

```bash
flutter build apk --release --flavor mobile
flutter build apk --release --flavor tv
```

产物：`build/app/outputs/flutter-apk/app-{mobile,tv}-release.apk`

## CI / CD

- **ci.yml**：push / PR 触发 → analyze + test + 双 flavor debug 构建
- **release.yml**：推送 `v*` tag 触发 → 测试 → 构建 release APK → 创建 GitHub Release 并上传产物

发布：

```bash
git tag v1.0.0
git push origin v1.0.0
```

可选配置 Release 签名 Secrets：`SGPW_KEYSTORE_BASE64`、`SGPW_KEYSTORE_PASSWORD`、`SGPW_KEY_ALIAS`、`SGPW_KEY_PASSWORD`（未配置时回退 debug 签名）。
