# 拾光 · 影像墙 Android / Android TV PRD

> 文档用途：作为实现型大模型的单一事实来源（Single Source of Truth）。  
> 目标：实现一个同时适配手机与 Android TV 的现代照片墙应用，聚合天翼云盘、115 网盘中的照片/视频，支持按指定云盘文件夹同步、预览、全屏播放、自动播放、TV 遥控器交互，以及手机向 TV 局域网扫码同步网盘配置。
>
> **实现前置约束：** 云盘 Provider 的具体 OAuth / API 以官方开放平台当前文档为准，禁止从第三方逆向协议作为生产依赖。115 当前存在官方开放平台，支持个人云存储能力接入；实现应以官方开放平台权限为准。天翼云盘同样必须通过可验证的官方开发者接口接入；若目标接口/权限在开发时不可获得，则 Provider 必须进入 `UNAVAILABLE` 状态，不能通过抓包/逆向网页登录流程绕过。115 官方平台明确提供个人云存储的文件存储、同步、管理、播放和信息查询等开放接口能力，具体权限仍以平台实际授权为准。

---

## 0. 本轮新增硬性约束

本版本新增以下**不可降低优先级的产品与工程约束**：

1. **手机端与 TV 端必须打包为两个独立 APK**
   - `ShiguangPhotoWall Mobile`
   - `ShiguangPhotoWall TV`
   - 两者共享 domain / data / provider / sync / database / pairing 等核心代码，但拥有独立 application module、独立 manifest、独立资源和独立 UI。
   - 禁止通过“一个 APK 同时覆盖手机 + TV”作为最终交付形态。
   - 推荐 Gradle 结构：
     ```text
     app-mobile/
     app-tv/
     core/*
     feature/*
     provider/*
     ```
   - applicationId 建议分别为：
     ```text
     com.example.sgphotowall
     com.example.sgphotowall.tv
     ```
   - 手机 APK 不依赖 TV 专属 UI；TV APK 不包含手机 Bottom Navigation 等无用页面资源。

2. **性能与资源消耗是 P0**
   - 性能优化不是发布后的补充工作，而是需求验收条件。
   - 必须从架构、数据库、图片解码、列表分页、网络、缓存、播放、同步、后台任务等层面控制 CPU、内存、磁盘、网络和电量。
   - 所有关键性能指标必须进入自动化测试/benchmark 或发布检查。

3. **TV 播放控制增加长按左右键功能**
   - TV Viewer 中：
     - 长按左键：快退
     - 长按右键：快进
   - 短按左/右仍执行上一项/下一项。
   - 长按必须防止重复触发“上一项/下一项”。
   - 视频快进/快退建议按递增步长实现，例如：
     `±10s → ±30s → ±60s`
     最大速度受视频/播放器能力限制。
   - 电视遥控器在长按期间应显示轻量 HUD：
     `-10s / -30s / -60s`、`+10s / +30s / +60s`
   - 图片执行长按左/右时不进行 seek；可直接忽略长按 seek 逻辑，避免错误交互。

4. **独立 APK 的发布测试必须分别执行**
   - Mobile unit/integration/UI tests
   - TV unit/integration/UI/TV navigation tests
   - Mobile release APK build
   - TV release APK build
   - 两个 APK 都通过全部门禁后才允许 release。

---

## 1. 产品定位

### 1.1 产品名称
暂定：`ShiguangPhotoWall`

### 1.2 产品目标
把用户分散在多个网盘文件夹中的家庭照片和视频，变成一个：
- 手机上浏览自然
- TV 大屏浏览舒适
- 全部媒体统一按时间倒序
- 点击即可播放/预览
- 低本地存储占用
- 网盘认证失效可恢复且不丢配置
- TV 输入困难时可由手机扫码同步配置
的家庭媒体墙。

### 1.3 非目标
MVP 不实现：
- 网盘文件上传、删除、移动、重命名
- 照片编辑
- 视频转码
- 云端文件夹管理
- 用户评论、收藏、分享
- 多用户账号体系
- 云端数据库
- 第三方服务器中转用户原始媒体

### 1.4 平台与打包方式
- Android 手机：优先支持 API 26+
- Android TV：优先支持 API 26+
- **最终交付两个独立 APK：**
  - Mobile APK
  - TV APK
- 推荐同一个 Git 仓库、共享核心业务代码，但使用两个独立 application module：
  ```text
  app-mobile/
  app-tv/
  core:common
  core:database
  core:network
  core:media
  core:pairing
  feature:home
  feature:photos
  feature:videos
  feature:viewer
  feature:settings
  feature:folderpicker
  provider:api
  provider:115
  provider:tianyi
  ```
- 共享模块只包含平台无关能力。
- TV 专属 UI / Focus / D-pad 逻辑放在 TV app/TV feature 中。
- 手机 APK 不应打包 TV 无用资源；TV APK 不应打包手机专属资源。
- 两端通过版本化的局域网 Pairing Protocol 互通，而不是通过共享 APK 实现。

### 1.5 两端职责
**Mobile APK**
- 网盘认证
- 文件夹配置
- 手机端媒体浏览
- Viewer/手势
- TV 配置同步
- 可作为 TV 配置源

**TV APK**
- 网盘配置接收/管理
- TV 媒体浏览
- TV Viewer
- 遥控器焦点与播放控制
- 局域网 Pairing Server
- 适合大屏的低资源渲染
- Compose 作为 UI 主技术；TV 使用 AndroidX TV Material/TV 组件与明确焦点体系。
- Android 官方当前推荐使用 Jetpack Compose 构建自适应应用；Android TV 使用 Compose for TV 可获得针对遥控器/焦点优化的组件。

---

# 2. 用户角色与核心场景

只有一种角色：**家庭用户**。

典型流程：

1. 首次启动
2. 进入设置
3. 绑定 115 / 天翼云盘
4. 授权成功
5. 选择一个或多个云盘文件夹
6. 返回首页
7. 自动触发一次首次刷新
8. 刷新结束后首页出现媒体
9. 点击媒体进入 Viewer
10. 手机通过上下滑动切换；TV 通过上下键/左右键切换
11. 用户开启自动播放后：
   - 照片停留 N 秒
   - 视频播放结束后自动下一项
12. 某次刷新发现 token 失效：
   - 状态改为“需要重新认证”
   - 保留 provider、账号标识、本地选择的文件夹配置、已有媒体索引和预览
   - 用户重新认证
   - 原文件夹配置继续生效，不要求再次选择
13. TV 设置页显示二维码
14. 手机扫描二维码
15. 手机将已配置的网盘认证信息和文件夹配置加密发送给 TV
16. TV 自动接收并保存
17. TV 自动执行一次刷新

---

# 3. 信息架构

底部导航 / TV 导航统一为 3 个主功能：

1. 首页
2. 照片
3. 视频

设置不是主菜单，放在：
- 手机：右上角设置按钮
- TV：首页/侧边导航中的设置入口，或遥控器 Menu/设置入口

---

# 4. 核心功能需求

## 4.1 网盘绑定

### 支持 Provider
- `TIANYI_CLOUD`
- `115_CLOUD`

所有 Provider 必须实现统一接口 `CloudProvider`。

### Provider 接口最小能力

```kotlin
interface CloudProvider {
    val type: ProviderType

    suspend fun authorize(): AuthResult

    suspend fun refreshCredential(): AuthResult

    suspend fun validateCredential(): CredentialState

    suspend fun listFolders(
        parentFolderId: String?
    ): Result<List<RemoteFolder>>

    suspend fun listMedia(
        folderId: String,
        cursor: String?
    ): Result<RemotePage<RemoteMedia>>

    suspend fun getPlayableUrl(
        mediaId: String
    ): Result<PlayableSource>

    suspend fun getOriginalImageSource(
        mediaId: String
    ): Result<ImageSource>

    suspend fun logoutOrRevoke(): Result<Unit>
}
```

Provider 不得直接操作 Room DAO，不得直接修改 UI State。

---

## 4.2 文件夹配置

用户可：
- 浏览网盘目录树
- 勾选一个或多个文件夹
- 保存所选 folder ID + 当时的完整路径快照
- 后续刷新只同步这些文件夹及其递归子目录

### 文件夹配置原则
- 配置与认证状态解耦
- token 失效不得删除 folder config
- provider 账号重新认证后继续使用原 folder ID
- folder ID 在云盘侧不存在时标记为 `REMOTE_MISSING`
- 删除本地 folder config 必须是用户显式操作

### 默认行为
保存文件夹后立即执行一次：
`SYNC_MANUAL / SYNC_INITIAL`

---

# 5. 首页

## 5.1 内容

首页展示：
- 所有照片
- 所有视频

统一按：

```text
captureTime DESC
fallback = remoteModifiedTime DESC
fallback = createdTime DESC
```

排序。

### 重要规则
照片与视频卡片大小完全相同。

卡片使用固定纵横比，例如：
`1.45 : 1`

媒体内容使用：
- `CenterCrop` 作为卡片缩略图策略
- 卡片尺寸由 Grid 决定，而非原始媒体分辨率决定

这样可以确保：
- 竖图不会把卡片撑高
- 4K 视频不会产生超大卡片
- 不同媒体混排仍然整齐

### 卡片展示
- Preview
- 类型标识：照片 / 视频
- 视频可显示时长
- 可选日期文字
- 可选多选框（预留，不在 MVP 中开放）

---

# 6. 照片页

只显示：
`mediaType = IMAGE`

按统一时间倒序。

支持：
- 3~6 列自适应 Grid
- 手机根据宽度动态列数
- TV 根据 10-foot UI 增加卡片尺寸和间距
- 点击进入 Viewer

---

# 7. 视频页

只显示：
`mediaType = VIDEO`

支持：
- 视频缩略图
- 时长
- 时间倒序
- 点击进入 Viewer

---

# 8. Viewer / 全屏预览

## 8.1 照片

必须按原始分辨率比例展示。

原则：
- 不裁切
- 保持宽高比
- 尽可能完整显示
- 超大图使用采样解码/渐进式加载，避免 OOM
- 允许双指缩放（手机）
- TV 默认 Fit Center

## 8.2 视频

使用 AndroidX Media3 / ExoPlayer。

视频：
- 保持原始宽高比
- 不拉伸
- 默认 `fit`
- 用户可选择填充模式（可后续扩展）

Media3 当前提供 ExoPlayer、Player、PlayerView 等播放能力，并支持 playlist / next / previous 等操作。

## 8.3 导航手势

### 手机
- 上滑：下一项
- 下滑：上一项
- 左右滑默认不切换媒体
- 点击空白区显示/隐藏控制栏
- 返回：关闭 Viewer

### TV
- 上键：上一项
- 下键：下一项
- **短按左键：上一项**
- **短按右键：下一项**
- **长按左键：视频快退**
- **长按右键：视频快进**
- OK/Enter：播放/暂停视频
- Back：返回媒体列表
- Menu：显示播放设置

### TV 左右键长按规则

必须区分 `tap` 与 `long press`：

```text
DOWN
  ↓
等待 longPressThreshold
  ├─ 在阈值前 UP → previous / next
  └─ 超过阈值 → enter seeking mode
        ↓
      每隔 repeatInterval 触发一次 seek
        ↓
      根据持续时间逐级增加 seek amount
        ↓
      UP → exit seeking mode
```

推荐初始参数：
```text
longPressThreshold = 450ms
repeatInterval = 180ms
seekStep = 10s
acceleratedStep = 30s
maxStep = 60s
```

同一个按键进入 seeking mode 后：
- 禁止触发媒体切换
- 不触发系统返回
- 不改变列表焦点
- 视频暂停时仍可 seek
- 到视频开头/结尾时停止继续 seek
- HUD 在 500~800ms 内自动淡出

实现建议：
- TV 以 `D-pad` 为主
- 确保焦点边界明确
- Viewer 不允许焦点丢失到系统导航区域

---

# 9. 自动播放

设置：

```text
自动播放：OFF / ON
照片停留时间：1~60 秒
默认：2 秒
```

### 播放规则

当 `autoPlay = true`：

照片：
```text
展示照片
↓
计时 photoDuration
↓
next()
```

视频：
```text
start()
↓
播放结束事件
↓
next()
```

用户手动上一张/下一张：
- 立即重置当前媒体的自动播放计时器
- 视频重新开始播放

切换到后台：
- 停止自动播放计时
- 返回前台继续

手动暂停视频：
- 不应自动 next

---

# 10. 刷新与同步

## 10.1 刷新入口

首页右上角：

`刷新`

状态可视化：
- 空闲
- 正在连接
- 获取目录
- 同步媒体
- 生成预览
- 清理旧预览
- 成功
- 部分失败
- 认证失效
- 网络失败

## 10.2 自动刷新

自动刷新只发生在：
1. 首次完成网盘绑定后
2. TV 扫码接收配置成功后

MVP 不开启后台定时刷新。

架构应保留后续接入：
- WorkManager 周期同步
- Wi-Fi only
- 充电时同步

Android 官方推荐 WorkManager 承担持久后台工作，并支持 OneTimeWorkRequest / PeriodicWorkRequest。

---

# 11. 同步算法

每次刷新使用以下阶段：

## Phase A：加载配置

读取：
- active providers
- folder configs
- credential state

若 credential：
`NEED_REAUTH`

则：
- 不删除数据
- UI 提示重新认证
- 该 provider 跳过同步

## Phase B：获取远端快照

针对每个 folder config：
- 递归列目录
- 获取媒体文件
- 获取 remote ID
- 获取 size
- 获取 modified time
- 获取 media type
- 获取 capture time（优先 EXIF/媒体元数据；无法获取则使用远端时间）

## Phase C：Upsert

唯一键：

```text
providerType + accountId + remoteFileId
```

将远程文件写入 `MediaEntity`。

## Phase D：生成/更新 Preview

同步后：
- 新文件：生成 preview
- 文件内容发生变化：重建 preview
- 文件删除：标记 deleted
- 文件移出已配置文件夹：视为失效

## Phase E：清理无用 Preview

每次成功刷新完成后：

```text
previewFiles
    NOT IN activeMedia.previewPath
```

进入垃圾回收。

### 强制规则
不得“全量删除 preview 后重新生成”，否则 TV 大媒体库会出现明显闪烁和重复 IO。

只删除：
- 已确认远端不存在的媒体
- 已移出同步范围的媒体
- 文件 hash/version 已变更的旧 preview
- 数据库 orphan preview

## Phase F：提交快照

使用：
- transaction
- temp state
- success marker

避免：
`半同步结果覆盖稳定数据`

### 核心原则

刷新失败时：
- 老数据可继续浏览
- 老 preview 不删除
- 失败项显示旧数据
- UI 显示“上次成功刷新时间”

---

# 12. Preview 策略

本地只保存：
- 小尺寸 Grid Thumbnail
- Viewer Photo Preview / 可选中等尺寸缓存

默认不把整个原始文件同步到本地。

### Preview 命名

不要使用纯文件名。

建议：

```text
{sha256(provider|account|remoteId|version|size)}.webp
```

照片：
- 长边默认 720px
- 高质量 WebP

TV 可根据需要：
- 720px / 1080px 两级缓存

视频：
- 获取视频缩略图/关键帧
- 默认 720px
- 失败时显示统一 video placeholder

---

# 13. 本地数据库

使用 SQLite + Room。

Room 负责：
- schema
- migration
- DAO
- transaction
- Flow

核心表：

## ProviderAccount

```text
id
providerType
accountId
displayName
status
createdAt
updatedAt
lastAuthenticatedAt
lastSyncAt
lastSyncError
```

状态：

```text
DISCONNECTED
AUTHENTICATED
NEED_REAUTH
SYNCING
ERROR
```

## Credential

```text
providerAccountId
accessTokenEncrypted
refreshTokenEncrypted
expiresAt
tokenType
updatedAt
```

敏感 token 不能以明文存储。

建议：
- Android Keystore
- AES-GCM 加密数据
- DB 中只存密文
- 加密 key 不明文放数据库

## FolderConfig

```text
id
providerAccountId
remoteFolderId
folderPathSnapshot
folderName
enabled
recursive
createdAt
updatedAt
```

## MediaEntity

```text
id
providerAccountId
providerType
remoteFileId
parentRemoteFolderId
name
mediaType
mimeType
sizeBytes
captureTime
modifiedTime
remoteVersion
checksum
width
height
durationMs
containerFormat
videoCodec
audioCodec
originalMimeType
previewPath
status
createdAt
updatedAt
```

唯一索引：

```text
(providerType, accountId, remoteFileId)
```

## SyncRun

```text
id
startedAt
finishedAt
trigger
status
foundCount
addedCount
updatedCount
deletedCount
previewCreatedCount
previewDeletedCount
errorCount
errorMessage
```

## PairingSession

```text
id
sessionId
nonce
tvPublicKey
expiresAt
usedAt
```

Pairing Session 仅用于局域网扫码同步，不持久保存长期二维码秘密。

---

# 14. 状态机

## Provider 状态

```text
DISCONNECTED
    ↓ authorize
AUTHENTICATED
    ↓ token invalid / refresh failed
NEED_REAUTH
    ↓ re-authorize
AUTHENTICATED
```

### 强制规则
`NEED_REAUTH` 绝对不能：
- 删除 FolderConfig
- 删除 MediaEntity
- 删除 Preview
- 重置用户播放设置

---

# 15. 认证失效 UX

首页显示：

> 115 网盘认证已失效

按钮：
`重新认证`

重新认证后：
- 保留原账号关联
- 保留 FolderConfig
- 自动恢复同步
- 自动刷新一次

Toast：

> 认证已恢复，正在同步已配置文件夹

---

# 16. TV ↔ 手机扫码同步

## 16.1 使用场景

TV：
`设置 → 网盘配置 → 手机扫码同步`

TV 显示二维码。

## 16.2 二维码内容

二维码**不得直接包含 Access Token / Refresh Token**。

内容示例：

```json
{
  "v": 1,
  "type": "photo_wall_pairing",
  "host": "192.168.1.20",
  "port": 19420,
  "sessionId": "random-128-bit",
  "nonce": "random",
  "tvPublicKey": "base64url",
  "expiresAt": 1780000000
}
```

QR 过期：
- 默认 120 秒

## 16.3 加密同步

手机：
1. 扫描二维码
2. 建立局域网连接
3. 验证 sessionId / nonce
4. 与 TV 进行临时密钥协商
5. 用 AES-GCM 加密配置 payload
6. POST 给 TV

Payload：

```json
{
  "providers": [
    {
      "type": "115",
      "account": {...},
      "credential": {...},
      "folders": [...]
    }
  ]
}
```

TV 解密后：
- Upsert ProviderAccount
- 覆盖 credential
- 文件夹配置使用“手机端配置”同步
- 自动触发一次 refresh

## 16.4 文件夹同步语义

本 MVP 使用：

`replace provider config`

例如手机配置 115：

```text
照片
视频
2025 家庭旅行
```

TV 原来配置：

```text
照片
```

扫码后 TV 变成手机当前配置。

## 16.5 安全要求

- pairing token 一次性
- 2 分钟过期
- nonce 防重放
- payload AES-GCM
- 配置发送完成后 pairing session 立即作废
- TV 不监听公网
- Pairing HTTP server 仅绑定局域网接口
- 不启用 UPnP 自动打洞

---

# 17. 网络层

推荐：

```text
Ktor Client 或 Retrofit + OkHttp
```

Provider：
- HTTP API
- OAuth callback
- 文件列表
- 下载/播放 URL

统一错误模型：

```kotlin
sealed interface NetworkError {
    data object Unauthorized : NetworkError
    data object Forbidden : NetworkError
    data object NotFound : NetworkError
    data object RateLimited : NetworkError
    data object Timeout : NetworkError
    data object Offline : NetworkError
    data class Server(val code: Int) : NetworkError
    data class Unknown(val cause: Throwable) : NetworkError
}
```

---

# 18. 媒体层

推荐：

```text
Media3 / ExoPlayer
```

视频 Viewer 要支持：
- play
- pause
- seek
- next
- previous
- progress
- buffering
- network error
- replay

视频播放 URI 不能长期写死，因为部分云盘播放 URL 可能有时效性。

推荐：

```text
MediaEntity
    ↓
Provider.getPlayableUrl()
    ↓
fresh URL
    ↓
Media3
```

播放失败时：
- 若为 URL 过期：重新获取 URL 后 retry 1 次
- 若为权限失效：provider → NEED_REAUTH
- 其它错误：提示“播放失败”，允许重试

---

# 19. UI 规范

## 19.1 视觉关键词
- 暗色优先
- 玻璃感但不过度
- 图片优先
- 高信息密度的首页
- 大圆角
- 轻量阴影
- 动画短、快、可打断

## 19.2 手机
- 底部导航
- 2~4 列 Grid
- Material 3
- 状态栏安全区
- 手势导航友好

## 19.3 TV
- 大字号
- 大焦点框
- 8~10 英尺可读
- 明确的 D-pad focus
- 不依赖触摸
- Button/Card hit area 至少 48dp，重要 TV 控件尽量 ≥ 64dp

Android 官方的 TV Compose 组件针对遥控器和清晰焦点进行了优化；推荐优先使用 TV Material 组件，而不是直接把手机 Material 组件原样搬到 TV。

---

# 20. 自适应布局规则

统一使用 Window Size / screen size 来决定布局。

不要写：
```kotlin
if (isTv) ...
```
作为唯一判断手段。

推荐：
```text
Compact
Medium
Expanded
```

再叠加：
```text
isTelevision
```

用于 TV 专属交互行为。

原则：
- UI layout 用窗口尺寸决定
- 输入设备策略由 form factor 决定
- ViewModel / UseCase / Repository 不感知设备类型

---

# 21. 页面定义

## HomeScreen

区域：
1. 标题
2. 刷新按钮
3. 同步状态
4. 媒体 Grid
5. Empty State
6. Reauth Banner

Loading：
- skeleton card

刷新时：
- 不清空当前媒体
- 顶部显示进度

## PhotosScreen

只展示图片。

## VideosScreen

只展示视频。

## SettingsScreen

### 云盘
- 115
- 天翼云盘

每个 provider：
- 未绑定
- 已绑定
- 认证失效

按钮：
- 绑定
- 重新认证
- 文件夹
- 解除绑定

### 播放
- 自动播放开关
- 照片停留时间

### TV 配置
- 手机扫码同步

### 关于
- 版本
- 开源许可
- 隐私说明

---

# 22. ViewModel 建议

```text
HomeViewModel
PhotoViewModel
VideoViewModel
ViewerViewModel
SettingsViewModel
CloudProviderViewModel
FolderPickerViewModel
PairingViewModel
```

禁止：
- Activity 内写同步逻辑
- Compose Composable 内直接访问数据库
- Provider SDK 在 Composable 中调用

---

# 23. Clean Architecture

推荐模块：

```text
apps/
  mobile/
  tv/

packages/
  app_core/
  data/
  domain/
  design_system/
  media/
  pairing/
  providers/
  feature_home/
  feature_photos/
  feature_videos/
  feature_viewer/
  feature_settings/
  feature_folder_picker/
  feature_tv_viewer/
  feature_tv_focus/

android/
  shared_native/
  mobile_host/
  tv_host/

  native_media/
  native_livp/
  native_pairing/
  provider_115/
  provider_tianyi/
```

### 独立 APK 构建

推荐：

```bash
flutter build apk --flavor mobile --release
flutter build apk --flavor tv --release
```

必须分别输出：

```text
ShiguangPhotoWall-Mobile-release.apk
ShiguangPhotoWall-TV-release.apk
```

两个 APK 使用不同 `applicationId`，但共享同一版本号。


依赖方向：

```text
feature
  ↓
domain
  ↓
provider:api / database / media
  ↓
data / implementation
```

业务层依赖接口，不依赖 115 / 天翼实现。

---

# 24. Repository 接口

```kotlin
interface MediaRepository {
    fun observeAllMedia(): Flow<List<MediaItem>>
    fun observePhotos(): Flow<List<MediaItem>>
    fun observeVideos(): Flow<List<MediaItem>>
    fun observeMedia(id: Long): Flow<MediaItem?>
}

interface SyncRepository {
    suspend fun syncAll(): SyncResult
    suspend fun syncProvider(providerId: Long): SyncResult
}

interface ProviderRepository {
    fun observeProviders(): Flow<List<ProviderAccount>>
    suspend fun authenticate(type: ProviderType): Result<Unit>
    suspend fun reauthenticate(id: Long): Result<Unit>
    suspend fun validate(id: Long): CredentialState
}

interface FolderRepository {
    fun observeConfiguredFolders(providerId: Long): Flow<List<FolderConfig>>
    suspend fun saveFolders(providerId: Long, folders: List<FolderConfig>)
}
```

---

# 24. 性能与资源消耗要求

性能要求是 P0，必须在设计阶段实现，不允许作为“以后优化”。

## 24.1 内存

### 强制规则
- 首页禁止一次性把全部媒体加载到内存。
- 使用 Paging 3。
- ViewModel 只持有当前 UI 所需的小窗口数据。
- 图片必须按目标显示尺寸采样解码。
- 禁止在内存中缓存原始 4K/8K bitmap 列表。
- Viewer 最多保留当前媒体 + 邻近 1~2 个媒体的预加载资源。
- 视频播放器切换媒体时及时释放旧 player/decoder 资源。
- Preview 使用磁盘缓存，不把完整 Preview 库加载到内存。

### 内存目标
以 20,000 媒体基准库为测试样本：
- Home 首屏进入后，稳态 Java/Kotlin heap 不应随媒体总量线性增长。
- 连续浏览 500 张图片后不发生 OOM。
- 连续切换 100 个视频后不发生显著 native memory 持续增长。

## 24.2 图片解码

必须：
- 根据 ImageView 实际尺寸计算 `inSampleSize`
- 优先使用 RGB_565 仅在画质允许的缩略图场景；原图 Viewer 根据实际格式选择合适配置
- Grid 永不解码成原图尺寸
- Preview 优先 WebP/AVIF（以 Android 目标版本和库稳定性为前提）
- Viewer 图片采用 `fit`，禁止因为超大图片直接申请无限 bitmap

推荐：
```text
Grid preview: 720px 长边
TV preview: 1080px 长边（视设备性能按需降级）
Viewer: 按屏幕尺寸 + zoom 上限动态加载
```

## 24.3 列表性能

必须使用：
- Paging 3
- Stable key
- 稳定 item content type
- 避免不必要的 recomposition
- 避免每个 Card 创建独立昂贵状态
- 日期格式化结果可缓存
- Preview path / aspect ratio 等展示字段尽量在 data layer 预计算

禁止：
```kotlin
items(mediaList) {
    expensiveDatabaseQuery()
}
```

## 24.4 Compose 性能

必须：
- `@Stable` / immutable model 在适当情况下使用
- Lazy Grid 使用 stable key
- 避免 Composable 中直接做：
  - hash
  - bitmap decoding
  - 文件 IO
  - database query
  - 网络请求
- 复杂动画默认 60fps 目标
- TV Grid 在低性能电视上减少同时运行的动画数量

推荐监控：
- recomposition count
- frame time
- jank
- startup time

## 24.5 数据库性能

必须：
- 所有大查询有合适 index
- 首页排序索引：
  ```sql
  CREATE INDEX idx_media_capture_time
  ON media(captureTime DESC);
  ```
- Photos:
  ```sql
  CREATE INDEX idx_media_photo_time
  ON media(mediaType, captureTime DESC);
  ```
- Videos:
  ```sql
  CREATE INDEX idx_media_video_time
  ON media(mediaType, captureTime DESC);
  ```
- Provider/account/remoteFileId 使用唯一索引
- 刷新大量数据使用 Room transaction
- 大批量 upsert 使用批量 DAO
- 禁止循环逐条打开 transaction

## 24.6 同步性能

必须：
- 目录分页
- 媒体分页
- 增量 diff
- 只更新发生变化的媒体
- 只重新生成变化媒体 Preview
- 预览生成限制并发
- 网络请求限制并发，避免一次刷新建立数百并行请求

推荐：
```text
metadata fetch concurrency: 4~8
preview generation concurrency: 2~4
```

实际并发数必须可配置并根据设备类别动态调整。

### TV 特别策略
TV 硬件差异非常大：
- 低内存设备：减少 preview 并发
- 高性能设备：允许更高并发
- 可根据 `ActivityManager.isLowRamDevice` 降低资源上限

## 24.7 网络资源

- 不重复请求相同 media URL
- 播放 URL 只在需要时获取
- 401/expired URL 只重试一次
- 列目录必须使用分页 cursor
- 不允许每次进入 Viewer 都刷新整张媒体库
- Pairing 仅在用户发起配置同步时启动

## 24.8 磁盘

本地存储按职责分离：

```text
database/
cache/preview/
cache/video/
logs/
```

Preview 必须：
- 可删除
- 可重新生成
- 不影响数据库核心数据

磁盘清理策略：
- 每次成功 refresh 做 orphan preview GC
- 应用缓存空间接近上限时执行 LRU 清理
- Viewer 大文件临时缓存必须有大小上限
- 不允许无限增长

## 24.9 电量

MVP 默认：
- 不进行高频后台同步
- 不在后台持续扫描媒体
- Preview 生成仅在用户主动刷新后的工作阶段进行
- 视频退出 Viewer 后及时释放播放器

未来后台同步必须默认考虑：
- Wi-Fi only
- charging only
- network constraint
- battery constraint

## 24.10 启动性能

目标：
- 不在 Application.onCreate() 扫描整个媒体库
- 不在首屏启动时运行全量同步
- 数据库初始化延迟到首次真正使用时
- 云盘认证信息读取只在设置/同步相关场景进行
- Home 先显示本地索引，网络状态异步更新

## 24.11 性能测试基准

至少建立三种数据集：

### S
```text
1,000 media
```

### M
```text
10,000 media
```

### L
```text
20,000 media
```

每个数据集测试：
- cold start
- home first contentful paint
- first scroll
- 1000 item scroll
- open viewer
- image switch
- video switch
- sync
- preview generation
- preview GC
- app background/foreground

## 24.12 性能回归门禁

CI/Release 前至少执行：
- Gradle benchmark / macrobenchmark（适用模块）
- baseline/profile 检查
- Android lint
- unit/integration/UI tests

建议建立基准阈值：
```text
Home 首屏明显内容时间：目标 < 1.5s（本地已有索引）
Viewer 打开本地 preview：目标 < 500ms
媒体切换：目标 < 300ms（已有 preview）
首次视频准备：依网络和云盘而定，不设置绝对网络时延门槛
```

这些数值属于工程目标，不是所有 Android TV 硬件都能保证的绝对 SLA；CI 采用相同设备/模拟器配置进行趋势回归。

## 25.1 媒体格式测试矩阵

CI 必须维护最小格式 fixture 集：

```text
photo/
  sample.jpg
  sample.jpeg
  sample.png
  sample.webp
  sample.heic
  sample.heif
  sample.avif
  sample.livp

video/
  sample.mp4
  sample.mov
  sample.m4v
  sample.mkv
  sample.webm
  sample.3gp
```

视频 fixture 至少包含：
```text
H.264
HEVC
VP9
AV1（设备/CI 支持时）
AAC
Opus
```

`.livp` fixture 至少包含：
```text
HEIC + motion video
JPEG + motion video（如样本可获得）
```

必须测试：
- extension 正确
- MIME 正确
- magic bytes 与 extension 不一致
- 损坏容器
- 空文件
- 超大 entry
- Zip Slip
- Zip bomb 防护
- static image 可独立显示
- motion video 可按需播放

## 25.2 无损行为测试

测试必须证明：
- 同步不会修改原始 bytes
- Preview 生成不会覆盖原文件
- Viewer 不创建新的“原始媒体”
- MOV 不自动转 MP4
- HEVC 不自动转 H.264
- HEIC 不自动转 JPEG
- `.livp` 原始文件保持不变

可使用 SHA-256：

```kotlin
assertEquals(
    originalSha256,
    localRawFileSha256
)
```

对于远端不落地原文件的情况，至少验证下载到临时文件后的 SHA-256 与远端响应内容一致。

## 25.3 Codec Capability Test

运行时必须提供：

```kotlin
data class CodecCapability(
    val mimeType: String,
    val decoderName: String?,
    val isHardwareAccelerated: Boolean,
    val isSecure: Boolean
)
```

播放前根据：
- mime
- codec
- width
- height
- frame rate
- HDR profile
进行能力探测。

不要因为文件扩展名判断“设备一定可以播放”。

# 26. 测试策略

发布门禁必须满足：

```text
Unit Tests             PASS
Repository Tests       PASS
Database Tests         PASS
Sync Tests              PASS
Provider Contract Tests PASS
Pairing Tests           PASS
UI Tests                PASS
TV Navigation Tests     PASS
Lint                    PASS
Detekt/Ktlint           PASS
Debug APK assemble      PASS
Release APK assemble    PASS
```

任何一项失败：
`禁止 release`

---

# 27. 测试分层

## 26.1 Unit

覆盖：
- 日期排序
- MediaType 分类
- Viewer next/previous
- AutoPlay 状态机
- token 状态机
- sync diff
- preview GC
- pairing expiration
- pairing nonce
- error mapping

## 26.2 Repository

使用 fake Provider：

```kotlin
class FakeCloudProvider(
    private val files: MutableList<RemoteMedia>
) : CloudProvider {
    ...
}
```

验证：
- upsert
- delete
- unchanged
- remote file moved
- provider reauth
- old folder configs preserved

## 26.3 Room

验证：
- migration
- unique index
- transaction rollback
- Flow emitting changes
- orphan preview 查询

## 26.4 Provider Contract Test

所有 Provider 都必须跑同一套 contract suite：

```text
authorize
validate
listFolders
listMedia
getPlayableUrl
getOriginalImageSource
error mapping
```

## 26.5 UI

使用 Compose UI Test：
- Home
- Photo
- Video
- Settings
- Folder picker
- Reauth state
- Refresh state
- Auto play setting

## 26.6 TV

必须覆盖：
- D-pad focus
- OK 打开 Viewer
- Up/Down 切换
- Back 返回
- Viewer 中 next/previous
- AutoPlay
- Pairing 页面可操作

---

# 28. 自动播放测试状态机

伪代码：

```kotlin
sealed interface ViewerEvent {
    data object Open : ViewerEvent
    data object Next : ViewerEvent
    data object Previous : ViewerEvent
    data object VideoEnded : ViewerEvent
    data object Pause : ViewerEvent
    data object Resume : ViewerEvent
    data object Background : ViewerEvent
    data object Foreground : ViewerEvent
}
```

关键断言：

```text
autoPlay OFF
    photo -> no next

autoPlay ON + photo
    after duration -> next

autoPlay ON + video
    before ended -> stay
    ended -> next

paused
    no auto next

background
    timer suspended

manual next
    timer reset
```

---

# 29. 同步 Diff 算法

```kotlin
data class SyncDiff(
    val added: List<RemoteMedia>,
    val updated: List<RemoteMedia>,
    val deleted: List<MediaEntity>,
    val unchanged: List<RemoteMedia>
)

fun diff(
    remote: List<RemoteMedia>,
    local: List<MediaEntity>
): SyncDiff
```

唯一键：

```text
providerType + accountId + remoteFileId
```

版本判断：

```text
remoteVersion changed
OR
size changed
OR
modifiedTime changed
OR
checksum changed
```

任意满足：
`updated`

---

# 30. Preview GC 测试要求

必须覆盖至少：

### Case A
远端删除图片：
- MediaEntity 删除/标记删除
- Preview 删除

### Case B
远端新增：
- MediaEntity 新增
- Preview 新建

### Case C
远端修改：
- MediaEntity 更新
- 旧 Preview 删除
- 新 Preview 生成

### Case D
同步请求失败：
- 老 Preview 不删除

### Case E
DB 存在 orphan Preview：
- GC 删除

### Case F
同一媒体 refresh 两次：
- 不产生第二份 Preview

---

# 31. 认证失效测试

必须覆盖：

```text
access token 过期
refresh 成功
=> 状态 AUTHENTICATED

access token 过期
refresh 失败
=> NEED_REAUTH

NEED_REAUTH
=> FolderConfig remains

NEED_REAUTH
=> MediaEntity remains

NEED_REAUTH
=> Preview remains

reauth success
=> old FolderConfig reused

reauth success
=> sync automatically
```

---

# 32. Pairing 测试

### 单元测试

- expired session rejected
- used session rejected
- invalid nonce rejected
- wrong public key rejected
- malformed payload rejected
- replay payload rejected
- successful decrypt
- after success session invalidated

### 集成测试

```text
TV starts pairing server
    ↓
Phone scans QR
    ↓
Phone exchanges key
    ↓
Phone sends encrypted config
    ↓
TV decrypts
    ↓
TV persists
    ↓
TV auto sync
```

---

# 33. 示例测试代码

下面代码作为实现基线，要求大模型在最终工程中补齐所有依赖与生产实现，而不是仅仅复制测试名称。

## 32.1 排序测试

```kotlin
class MediaSortTest {

    @Test
    fun `sort media by capture time descending`() {
        val list = listOf(
            media(id = 1, captureTime = Instant.parse("2025-01-01T00:00:00Z")),
            media(id = 2, captureTime = Instant.parse("2026-01-01T00:00:00Z")),
            media(id = 3, captureTime = Instant.parse("2024-01-01T00:00:00Z"))
        )

        val result = list.sortedWith(mediaComparator)

        assertEquals(listOf(2L, 1L, 3L), result.map { it.id })
    }
}
```

## 32.2 Provider 认证状态测试

```kotlin
class ProviderAuthStateTest {

    @Test
    fun `reauth required does not delete folder config`() = runTest {
        val accountId = 1L

        db.insertFolder(
            FolderConfigEntity(
                id = 10L,
                providerAccountId = accountId,
                remoteFolderId = "folder-1",
                folderName = "旅行",
                folderPathSnapshot = "/照片/旅行",
                enabled = true,
                recursive = true
            )
        )

        providerRepository.markNeedReauth(accountId)

        val folders = db.folderDao().getFolders(accountId)

        assertEquals(1, folders.size)
        assertEquals("folder-1", folders.first().remoteFolderId)
    }
}
```

## 32.3 Preview GC 测试

```kotlin
class PreviewGcTest {

    @Test
    fun `orphan preview should be deleted`() = runTest {
        val orphan = preview("orphan.webp")
        val used = preview("used.webp")

        previewStore.write(orphan)
        previewStore.write(used)

        db.insertMedia(mediaEntity(previewPath = used.path))

        previewGarbageCollector.collect()

        assertFalse(previewStore.exists(orphan.path))
        assertTrue(previewStore.exists(used.path))
    }
}
```

## 32.4 Refresh failure 保留旧数据

```kotlin
class SyncFailureTest {

    @Test
    fun `sync failure keeps old media and preview`() = runTest {
        val old = mediaEntity(
            remoteFileId = "100",
            previewPath = "/preview/100.webp"
        )

        db.mediaDao().insert(old)
        previewStore.write(PreviewFile("/preview/100.webp"))

        fakeProvider.throwNetworkError = true

        val result = syncUseCase.execute()

        assertTrue(result is SyncResult.Failed)
        assertNotNull(db.mediaDao().findByRemoteId("100"))
        assertTrue(previewStore.exists("/preview/100.webp"))
    }
}
```

## 32.5 自动播放测试

```kotlin
class ViewerAutoPlayTest {

    @Test
    fun `photo advances after duration when autoplay enabled`() = runTest {
        val clock = TestCoroutineScheduler()
        val viewer = TestViewerController(
            dispatcher = StandardTestDispatcher(clock)
        )

        viewer.setAutoPlay(true)
        viewer.setPhotoDuration(Duration.ofSeconds(2))
        viewer.open(image(id = 1))

        clock.advanceTimeBy(1999)

        assertEquals(1L, viewer.currentId)

        clock.advanceTimeBy(1)

        assertEquals(2L, viewer.currentId)
    }

    @Test
    fun `video advances only after playback ended`() = runTest {
        val viewer = TestViewerController()

        viewer.setAutoPlay(true)
        viewer.open(video(id = 1))

        assertEquals(1L, viewer.currentId)

        viewer.onVideoEnded()

        assertEquals(2L, viewer.currentId)
    }
}
```

## 32.6 Pairing session 测试

```kotlin
class PairingSessionTest {

    @Test
    fun `expired pairing session is rejected`() = runTest {
        val session = pairing.create(
            now = Instant.parse("2026-01-01T00:00:00Z")
        )

        val result = pairing.validate(
            sessionId = session.sessionId,
            now = Instant.parse("2026-01-01T00:03:00Z")
        )

        assertFalse(result)
    }

    @Test
    fun `pairing session can only be used once`() = runTest {
        val session = pairing.create(Clock.System.now())

        assertTrue(pairing.consume(session.sessionId))
        assertFalse(pairing.consume(session.sessionId))
    }
}
```

---

# 34. UI Test 示例

```kotlin
@Test
fun home_click_media_opens_viewer() {
    composeRule.setContent {
        TestHomeScreen(
            media = listOf(
                media(id = 1, type = IMAGE),
                media(id = 2, type = VIDEO)
            )
        )
    }

    composeRule
        .onNodeWithContentDescription("媒体 1")
        .performClick()

    composeRule
        .onNodeWithTag("viewer")
        .assertIsDisplayed()
}
```

---

# 35. TV UI Test 示例

```kotlin
@Test
fun tv_down_key_moves_to_next_media() {
    composeRule.setContent {
        TestViewerScreen(
            items = testItems(),
            deviceMode = DeviceMode.TV
        )
    }

    composeRule.onNodeWithTag("viewer").performKeyInput {
        pressKey(Key.DirectionDown)
    }

    composeRule
        .onNodeWithTag("media-2")
        .assertIsDisplayed()
}
```

---

# 36. Provider Contract Test 示例

```kotlin
abstract class CloudProviderContractTest {

    abstract fun createProvider(): CloudProvider

    @Test
    fun `list folders returns stable ids`() = runTest {
        val provider = createProvider()

        val result = provider.listFolders(null).getOrThrow()

        assertTrue(result.all { it.id.isNotBlank() })
    }

    @Test
    fun `unauthorized maps to Unauthorized`() = runTest {
        val provider = createProvider()

        fakeServer.enqueueUnauthorized()

        val result = provider.listFolders(null)

        assertTrue(
            result.exceptionOrNull() is NetworkErrorException.Unauthorized
        )
    }
}
```

---

# 36. 真实 Provider 测试策略

不要把真实账号 token 写进 GitHub。

提供：

```text
USE_REAL_PROVIDER_TESTS=false
```

默认 false。

CI：
- 使用 Fake server / MockWebServer
- Provider contract 测试模拟官方 API response

手工夜间/私有 CI 可通过 GitHub Secrets 开启：

```text
USE_REAL_PROVIDER_TESTS=true
TIANYI_TEST_REFRESH_TOKEN
115_TEST_REFRESH_TOKEN
```

但不建议把个人云盘账号作为普通 PR CI 的强依赖。

---

# 38. Mock API 要覆盖

MockWebServer 场景至少包括：

```text
200 auth
200 list folder
200 list page
200 second page
401 access token expired
200 token refresh
401 refresh invalid
403 permission
404 file missing
429 rate limit
500 server error
timeout
malformed json
empty page
large page
```

---

# 39. 性能验收

以以下数据量作为验收基线：

```text
媒体：20,000
照片：15,000
视频：5,000
文件夹：500
单文件夹：5,000
```

目标：
- 首页首次打开不阻塞主线程
- Grid 滑动无明显卡顿
- 数据库查询必须分页
- 不允许一次性加载全部 20,000 项到内存
- Viewer 打开大图不 OOM
- Preview GC 不阻塞 UI
- Sync 在后台执行

---

# 40. 分页

UI 层禁止：

```kotlin
dao.getAllMedia()
```

改为：
- Paging 3
- PagingSource
- remoteKey（如果未来需要云端分页）

首页与照片/视频页面都必须分页。

---

# 41. 网络稳定性

必须支持：
- Wi-Fi 丢失
- 切换网络
- 4G/5G → Wi-Fi
- API timeout
- DNS failure
- server 429
- server 5xx

重试策略：
- 401：尝试 refresh token 一次
- 429：指数退避
- 5xx：最多重试 2 次
- 4xx 业务错误：不自动重试

---

# 42. 隐私与安全

必须：
- TLS
- Token 加密
- 不在普通 Log 中输出 token
- 不在 crash report 中输出 token
- QR 不包含 token
- pairing session 一次性
- 本地 TV pairing server 仅局域网
- 不上传用户媒体
- 不上传用户云盘目录数据到第三方服务器

日志：
```text
允许：provider=115, fileCount=1200
禁止：access_token=xxx
禁止：refresh_token=xxx
禁止：完整云盘 URL（如包含敏感 query 参数）
```

---

# 43. 错误体验

统一错误组件：

### 网络错误
> 网络连接失败，请检查网络后重试

### 认证失效
> 115 网盘认证已失效，请重新认证

### 权限不足
> 当前应用没有访问此文件夹的权限

### 文件被删除
> 文件已不存在

### 视频播放失败
> 无法播放此视频
> 重试

### 没有媒体
> 当前文件夹没有照片或视频

---

# 44. Release Definition of Done

一个版本只有满足以下全部条件才允许发布：

```text
[PASS] Unit Test
[PASS] Integration Test
[PASS] Provider Contract Test
[PASS] Room Migration Test
[PASS] Sync Test
[PASS] Preview GC Test
[PASS] Pairing Test
[PASS] Compose UI Test
[PASS] TV UI Test
[PASS] Lint
[PASS] Static analysis
[PASS] Debug mobile build
[PASS] Release mobile build
[PASS] Debug TV build
[PASS] Release TV build
[PASS] Performance benchmark
```

---

# 45. GitHub Actions CI/CD

## 44.1 PR / push CI

触发：
- pull_request
- push 到 main

流程：

```text
checkout
↓
setup JDK
↓
gradle test
↓
gradle lint
↓
gradle detekt / ktlint
↓
connectedAndroidTest
↓
assembleDebug
↓
assembleRelease
```

任何一步失败：
`workflow failure`

---

# 46. Tag 自动 Release

触发：

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

版本标签要求：
```text
v1.0.0
v1.2.3
v2.0.0-beta.1
```

Release job 只有在 test job 成功后才能执行。

推荐 GitHub 官方 release API / `gh release create` 等方式创建 Release。GitHub 当前 REST Release API 支持使用 `tag_name` 创建 Release，并要求相应仓库内容权限。

---

# 47. 推荐 GitHub Actions 文件

`.github/workflows/ci.yml`

```yaml
name: CI

on:
  pull_request:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v4

      - name: Unit tests
        run: ./gradlew testDebugUnitTest

      - name: Lint
        run: ./gradlew lint

      - name: Static analysis
        run: ./gradlew detekt

      - name: Unit tests
        run: ./gradlew test

      - name: Mobile UI tests
        run: ./gradlew :app-mobile:test

      - name: TV UI tests
        run: ./gradlew :app-tv:test

      - name: Performance checks
        run: ./gradlew :app-mobile:connectedCheck :app-tv:connectedCheck

      - name: Assemble mobile debug
        run: ./gradlew :app-mobile:assembleDebug

      - name: Assemble TV debug
        run: ./gradlew :app-tv:assembleDebug

      - name: Assemble mobile release
        run: ./gradlew :app-mobile:assembleRelease

      - name: Assemble TV release
        run: ./gradlew :app-tv:assembleRelease
```

---

# 48. Tag Release Workflow

`.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write

jobs:
  verify:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v4

      - name: Unit tests
        run: ./gradlew testDebugUnitTest

      - name: Lint
        run: ./gradlew lint

      - name: Static analysis
        run: ./gradlew detekt

      - name: Instrumented tests
        run: ./gradlew :app-mobile:connectedCheck :app-tv:connectedCheck

      - name: Performance regression tests
        run: ./gradlew :app-mobile:connectedCheck :app-tv:connectedCheck

      - name: Build Mobile Release
        run: ./gradlew :app-mobile:assembleRelease

      - name: Build TV Release
        run: ./gradlew :app-tv:assembleRelease

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: photo-wall-release
          path: |
            app-mobile/build/outputs/apk/release/*.apk
            app-tv/build/outputs/apk/release/*.apk

  release:
    needs: verify
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download APK artifact
        uses: actions/download-artifact@v4
        with:
          name: photo-wall-release
          path: dist

      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh release create "${GITHUB_REF_NAME}" \
            dist/*.apk \
            dist/*.aab \
            --title "${GITHUB_REF_NAME}" \
            --generate-notes
```

### Release 强制要求

禁止：
- `release` job 绕过 `verify`
- 测试失败继续发布
- `if: always()` 发布

必须：

```yaml
needs: verify
```

---

# 49. Release 签名

生产 Release 不允许使用 debug key。

GitHub Secrets：

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

CI 中：
1. decode keystore
2. 临时写到 runner
3. build release
4. 上传 artifacts
5. 删除临时 keystore

不要把 keystore 提交到仓库。

---

# 50. PR 合并门禁建议

GitHub Branch Protection：

```text
main
  Require pull request
  Require status checks
  Require CI / test
  Require CI / lint
  Require CI / build
  Require review
```

推荐禁止直接 push main。

---

# 51. 版本号

遵循 SemVer：

```text
MAJOR.MINOR.PATCH
```

例：
```text
v1.0.0
v1.1.0
v1.1.1
```

---

# 52. 开发阶段拆分

## Phase 1：基础工程
- Gradle
- Compose
- Room
- Navigation
- DesignSystem
- FakeProvider
- CI

## Phase 2：本地媒体
- MediaEntity
- Paging
- Grid
- Viewer
- AutoPlay
- Preview storage

## Phase 3：Provider abstraction
- CloudProvider
- SyncEngine
- Token state machine
- Fake provider

## Phase 4：115
- OAuth
- folder listing
- media listing
- playback URL

## Phase 5：天翼云盘
- OAuth
- folder listing
- media listing
- playback URL

## Phase 6：TV
- TV navigation
- D-pad
- focus
- TV Viewer

## Phase 7：Pairing
- QR
- LAN server
- ECDH/AES-GCM
- sync config

## Phase 8：质量
- all tests
- performance
- migration
- release automation

---

# 53. 实现优先级

### P0 必须
- 3 个主菜单
- 115 / 天翼云盘绑定
- 文件夹选择
- 首次绑定后自动刷新
- 手动刷新
- 首页所有媒体时间倒序
- 统一卡片尺寸
- 本地 preview
- Preview GC
- Room/SQLite
- 图片 Viewer
- 视频 Viewer
- 视频自动播放
- 照片定时自动播放
- TV Up/Down / Phone swipe
- 认证失效重新认证
- 保留文件夹配置
- TV QR pairing
- 测试门禁
- Tag 自动 Release

### P1
- 后台周期同步
- 收藏
- 最近播放位置
- TV 屏保
- 多种缩放模式

### P2
- 多用户
- 多 TV
- Samba / WebDAV
- Plex/Jellyfin

---

# 54. 验收标准

## A. 认证
- 绑定成功
- 自动刷新一次
- access token 失效能重新认证
- 重新认证后 folder config 不变

## B. 同步
- 新媒体出现
- 删除媒体消失
- 移出同步目录消失
- 不相关文件夹不出现
- 刷新失败不会清空旧数据

## C. Preview
- 新媒体生成 preview
- 修改媒体更新 preview
- 删除媒体清理 preview
- 重复刷新不产生垃圾 preview

## D. UI
- 手机适配
- TV 适配
- 卡片统一大小
- 大图按原始比例
- 视频按原始比例

## E. Viewer
- 手机上下滑切换
- TV 遥控器切换
- 视频自动播放
- 视频结束 next
- 照片按配置时间 next

## F. Pairing
- TV 生成二维码
- 手机扫码
- 同局域网互通
- 网盘配置同步
- folder config 同步
- 同步后 TV 自动刷新
- QR 过期后不可用
- token 不出现在二维码

## G. Release
- 所有测试 PASS 才能 release
- tag 自动创建 GitHub Release
- APK/AAB 自动上传
- release 签名正确

---

# 55. 大模型实现约束（必须遵守）

1. 不得跨层调用。
2. 不得把 Provider API 写死在 UI。
3. 不得在 Room 外自己维护第二份状态源。
4. 不得把 token 明文存入数据库。
5. 不得把 token 放入二维码。
6. 不得在 refresh 失败时清理旧 preview。
7. 不得通过文件名作为媒体唯一 ID。
8. 不得让大图缩略图尺寸决定 Grid 卡片尺寸。
9. 不得一次性把整个媒体库加载到内存。
10. 不得用 ExoPlayer 直接保存永久播放 URL。
11. 不得在 TV 上依赖触摸操作。
12. 不得让认证失效删除本地 folder config。
13. 不得跳过 CI 测试直接创建 release。
14. 不得在 CI 日志输出 access/refresh token。
15. 所有新增 Provider 必须通过 `CloudProviderContractTest`。
16. 所有数据库 schema 修改必须附 migration test。
17. 所有新功能必须附 unit / integration / UI 中至少一种对应测试。
18. 发布版本必须在 tag 上重新跑完整验证，而不是信任此前 main 分支结果。

---

# 56. 推荐工程完成标准

实现完成时，仓库应至少包含：

```text
app/
core/
feature/
provider/
test/
.github/
  workflows/
    ci.yml
    release.yml
docs/
  architecture.md
  provider.md
  testing.md
  release.md
```

同时至少有：

```text
> 80% domain 层 line coverage
> 70% data 层 line coverage
100% 核心 sync state machine coverage
100% auth state transition coverage
100% pairing security rule coverage
100% release gate workflow coverage
```

覆盖率只是工程质量门槛，不能替代真实场景测试。

---

# 57. 参考实现技术选型

推荐默认技术栈：

```text
Flutter / Dart
Flutter Material / 自定义 Design System
Riverpod / Bloc（二选一，全项目统一）
go_router
Drift / SQLite 或 sqflite（推荐 Drift）
Dio
Freezed + json_serializable
Flutter Secure Storage（Key 只托管 Android Keystore）
cached_network_image（仅 Preview）
video_player / 直接集成 Media3能力（二选一，但生产建议 Native Media3 Bridge）
flutter_test
integration_test
patrol（可选）
mocktail
Golden Test
```

Android / Kotlin：

```text
Kotlin
AndroidX
Media3 / ExoPlayer
MediaCodec
ImageDecoder
Room（如果数据库主要由 Kotlin 持有）或 Drift（如果统一由 Dart 持有；二选一）
WorkManager
Android Keystore
Pigeon
ZXing / ML Kit Barcode Scanning（二选一）
MockWebServer
JUnit
Benchmark / Macrobenchmark
```

### 数据库技术选型强约束

由于整个 App 使用 Flutter + Kotlin，本项目应优先选择：

```text
Drift(SQLite)
```

作为统一数据库访问层，避免 Flutter 与 Kotlin 各自维护两个数据库。

Kotlin 原生层需要访问数据时：
- 优先通过 Dart domain/service API
- 极少数高性能 native worker 可通过受控接口访问 SQLite，但不得形成第二套业务数据模型

如果实际 Provider SDK 或 Android 后台服务强依赖 Room，则可以采用：
```text
Room = Native-only cache
Drift = App business DB
```
但必须明确所有权，严禁两个 DB 互相复制核心数据。

Flutter 官方支持将 Android Kotlin 能力封装为 plugin / platform channel，因此媒体、TV、`.livp`、Pairing 等 Android 专属能力可以维持 Native 实现，而 UI 与业务交互由 Flutter 统一。citeturn448182search4turn448182search5

---

# 58. 需要在编码前锁定的外部依赖

这是 PRD 唯一允许“实现前再次核验”的部分：

### 天翼云盘
确认：
- 官方开放平台入口
- OAuth 授权流程
- access/refresh token 生命周期
- 文件夹列表接口
- 分页接口
- 文件元数据
- 图片原图 URL
- 视频播放 URL
- 速率限制
- 单应用权限范围

### 115
以当前官方 115 生活开放平台的最新开发文档和账号开通条件为准。

若 API 权限与本 PRD要求有差异：
- 不得修改业务层
- 只修改 `provider:115`
- 更新 provider contract / fake fixtures / integration tests

---

# 59. 实现输出要求（供代码生成大模型）

最终代码生成任务必须一次性提供：

1. 完整项目目录
2. Gradle 配置
3. 数据库 entities
4. DAO
5. migration
6. provider interface
7. fake providers
8. 115 provider
9. 天翼 provider
10. sync engine
11. preview manager
12. image viewer
13. video viewer
14. phone UI
15. TV UI
16. pairing server
17. pairing crypto
18. QR UI
19. 自动播放
20. 所有 unit tests
21. 所有 integration tests
22. Compose UI tests
23. TV tests
24. CI workflow
25. Release workflow
26. README
27. architecture docs
28. testing docs

并必须保证：

```text
./gradlew test
./gradlew lint
./gradlew detekt
./gradlew assembleDebug
./gradlew assembleRelease
```

全部成功后，才允许打 release tag。

---

## 60. 最终产品原则

> **云盘是数据源，SQLite 是索引，Preview 是可丢弃缓存，认证是独立状态，Provider 是可替换适配器，Viewer 是统一媒体层，手机与 TV 只是不同输入/布局表现。**

任何实现都应保持这个边界，否则后续增加更多网盘、WebDAV、局域网 NAS 时会明显增加维护成本。