# TrainQuest 组员在 Mac 上配置 iPhone App 指南

## 先回答你的问题

是的，如果你的组员要在他自己的 Mac 上通过 `Xcode` 或 `Flutter` 把当前工程安装到他的 iPhone 上，那么这份前端项目代码需要放到他的 Mac 上，并且由他的 Mac 完成一次构建和签名。

但后端不一定要跑在他的 Mac 上。

- 前端 Flutter iOS 工程：必须在 Mac 上构建。
- 后端 Flask 服务：可以跑在你的电脑、他的 Mac，或者任何一台手机能访问到的服务器上。

只有在下面两种情况下，组员才不需要在自己的 Mac 上保存并运行这个项目：

- 你已经导出并签名好了可安装的 `.ipa` 文件。
- 你们已经接入 `TestFlight` 进行分发。

对你们现在这个小组项目来说，最稳妥的方式是：

- 每个组员在自己的 Mac 上拉取这份项目。
- 用自己的 Apple ID 或你们统一的开发团队账号完成 iPhone 签名。
- 用 `flutter run` 安装到自己的手机上。

## 这份项目当前的实际情况

你们当前项目里有两个很重要的事实：

- Flutter 工程目录是 `app/app/flutter_application_1`
- 后端目录是 `trainquest_backend_a`

另外，当前 Flutter 代码在真机上如果不额外配置后端地址，会默认访问本机地址：

- iOS 默认会落到 `http://127.0.0.1:5000`

这在模拟器里还能勉强解释，但在真实 iPhone 上一定不对，因为手机里的 `127.0.0.1` 指向的是手机自己，不是你的电脑。

所以真机运行时，必须显式传入后端地址，例如：

```bash
flutter run --dart-define=TRAINQUEST_API_BASE_URL=http://192.168.1.8:5000
```

## 推荐的部署思路

推荐你让组员按下面的方式做：

1. 在他的 Mac 上拿到整个项目仓库。
2. 用 `Xcode` 完成 iPhone 签名配置。
3. 用 `flutter run` 安装到手机。
4. 把后端地址指向一台局域网内可访问的机器。

原因很简单：

- `Xcode` 最适合处理 iPhone、证书、签名、Developer Mode。
- `flutter run` 最适合处理 Flutter 真机启动，尤其是你们现在需要传 `--dart-define` 指定后端地址。

如果只点 `Xcode` 的 Run，而没有额外处理 `dart-define`，当前项目很可能会退回到 `127.0.0.1:5000`，导致手机能打开界面但接口全部失败。

## 方案选择

### 方案 A：后端跑在你的电脑上

适合你已经把后端在自己电脑上跑通，并且演示时大家都在同一个 Wi-Fi 下。

优点：

- 组员不用再单独部署后端。
- 你们的数据源更统一。

要求：

- 你的电脑和组员的 iPhone 在同一个局域网。
- 你的电脑防火墙允许外部访问 `5000` 端口。
- 后端已经启动。

### 方案 B：后端跑在组员自己的 Mac 上

适合你想让每个人都能独立演示。

优点：

- 不依赖你的电脑在线。
- 每个人可以单独调试。

缺点：

- 每个人都要在自己电脑上多配一遍 Python 后端环境。

如果你们只是为了课程展示，我更推荐先走方案 A。

## 第 1 步：让组员准备 Mac 环境

### 1. 安装 Xcode

在 Mac App Store 安装 `Xcode`，安装完成后至少打开一次，接受许可协议。

然后在终端执行：

```bash
xcode-select --install
sudo xcodebuild -runFirstLaunch
```

### 2. 安装 Flutter SDK

如果组员的 Mac 还没有 Flutter，需要先安装 Flutter，并确认命令可用：

```bash
flutter --version
flutter doctor
```

`flutter doctor` 至少需要看到：

- Flutter 正常
- Xcode 正常
- iOS toolchain 正常

### 3. 安装 CocoaPods

iOS Flutter 工程通常需要 `CocoaPods`：

```bash
brew install cocoapods
pod --version
```

如果已经安装过，就不需要重复装。

### 4. 准备 Apple ID

组员需要把自己的 Apple ID 登录到 Xcode：

1. 打开 `Xcode`
2. 进入 `Xcode > Settings... > Accounts`
3. 点击 `+`
4. 选择 `Apple ID`
5. 登录账号

说明：

- 只是在自己的手机上本地安装调试，个人 Apple ID 也可以。
- 如果要 `TestFlight` 或上架 App Store，需要付费 Apple Developer Program。

## 第 2 步：把项目放到组员的 Mac 上

最推荐的方式是直接拉取整个仓库。

如果你们用 Git：

```bash
git clone <你的仓库地址>
```

如果你们没有用 Git，也可以直接把整个项目文件夹拷给他。

组员拿到仓库后，进入 Flutter 工程目录：

```bash
cd app/app/flutter_application_1
```

然后执行：

```bash
flutter pub get
```

如果 `flutter pub get` 成功，说明 Flutter 依赖基本正常。

## 第 3 步：连接 iPhone 并启用开发模式

1. 用数据线把 iPhone 连到 Mac。
2. iPhone 弹出“是否信任此电脑”时，点“信任”。
3. 在 Mac 上打开 `Xcode`，等待设备被识别。
4. 如果手机是 iOS 16 及以上，第一次真机运行前需要开启 `Developer Mode`。

开启方式通常是：

1. 先在 Xcode 里尝试选择该手机为运行目标。
2. 手机上会出现开发模式相关提示。
3. 进入 `设置 > 隐私与安全性 > Developer Mode`
4. 打开开关并重启手机
5. 重启后再次确认启用

如果设置里暂时看不到 `Developer Mode`，通常是因为还没有被 Xcode 正确识别过一次。

## 第 4 步：在 Xcode 里完成签名配置

这一部分非常关键。

### 1. 打开正确的工程

不要打开 `ios/Runner.xcodeproj`，而是打开：

```text
ios/Runner.xcworkspace
```

### 2. 进入签名页面

在 Xcode 左侧选择 `Runner` 项目，然后：

1. 选择 `TARGETS > Runner`
2. 打开 `Signing & Capabilities`

### 3. 勾选自动签名

勾选：

```text
Automatically manage signing
```

### 4. 选择 Team

在 `Team` 下拉框里选择组员自己的 Apple ID 对应团队，或者你们统一的团队账号。

### 5. 修改 Bundle Identifier

这一项一定要注意。

你们当前工程默认的包名是：

```text
com.example.flutterApplication1
```

这通常不适合直接用于多人真机签名。推荐这样处理：

- 如果每个人都用自己的个人 Apple ID：每个人都改成不同的包名
- 如果所有人都用同一个开发团队账号：可以统一使用同一个正式包名

推荐命名示例：

```text
com.trainquest.membera
com.trainquest.memberb
com.yourteam.trainquest
```

最重要的原则是：

- 包名不要继续用 `com.example...`
- 包名要尽量唯一

### 6. 如果 Xcode 提示 Fix Issue

如果页面上出现 `Fix Issue`，直接点它，让 Xcode 自动帮你创建和下载开发证书与 profile。

### 7. 先尝试一次原生层编译

这一步不一定要求成功进入业务页面，但至少可以帮助 Xcode 完成设备注册和签名初始化。

## 第 5 步：决定后端跑在哪里

你们必须先决定手机要访问哪个后端。

### 方式 1：手机访问你的电脑

适合你作为主开发同学统一跑后端。

你在自己的电脑上进入后端目录：

```bash
cd trainquest_backend_a
pip install -r requirements.txt
python app.py
```

你这份后端代码默认会监听：

```text
0.0.0.0:5000
```

这意味着局域网内其他设备可以访问，只要防火墙允许。

然后你在 Windows 上查看局域网 IP：

```powershell
ipconfig
```

记下类似这样的地址：

```text
192.168.1.8
```

那么手机实际应该访问：

```text
http://192.168.1.8:5000
```

### 方式 2：手机访问组员自己的 Mac

如果组员要自己跑后端，可以在他的 Mac 上进入后端目录并运行：

```bash
cd trainquest_backend_a
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

然后在 Mac 上查看自己的局域网 IP，例如：

```bash
ipconfig getifaddr en0
```

如果返回：

```text
192.168.1.23
```

那么手机的后端地址就应该写成：

```text
http://192.168.1.23:5000
```

## 第 6 步：确认手机能访问后端

在真正跑 app 之前，先做一个最重要的网络验证：

1. 确保手机和后端电脑在同一个 Wi-Fi。
2. 在手机 Safari 里打开：

```text
http://<后端IP>:5000/
```

例如：

```text
http://192.168.1.8:5000/
```

如果能看到类似下面的 JSON：

```json
{"message":"TrainQuest backend is running"}
```

说明网络基本通了。

如果 Safari 都打不开，那 app 一定也访问不到。此时先不要继续折腾 Flutter，先检查：

- 后端是不是已经运行
- IP 是不是写错了
- 电脑和手机是不是同一个 Wi-Fi
- Windows 或 macOS 防火墙有没有拦截 `5000`

## 第 7 步：推荐的真机启动方式

### 为什么推荐用 `flutter run`

你们当前项目把后端地址做成了 `dart-define`：

```text
TRAINQUEST_API_BASE_URL
```

因此最稳的方式是：

- 用 Xcode 配签名
- 用 Flutter 命令真正安装和运行 app

### 具体命令

组员在 Mac 上回到 Flutter 工程目录：

```bash
cd app/app/flutter_application_1
```

先查看设备：

```bash
flutter devices
```

确认 iPhone 已经出现在设备列表里后，执行：

```bash
flutter run --dart-define=TRAINQUEST_API_BASE_URL=http://<后端IP>:5000
```

例如：

```bash
flutter run --dart-define=TRAINQUEST_API_BASE_URL=http://192.168.1.8:5000
```

如果同时连了多个设备，可以指定设备：

```bash
flutter run -d <device_id> --dart-define=TRAINQUEST_API_BASE_URL=http://192.168.1.8:5000
```

## 第 8 步：检查手机上的结果

安装成功后，组员的 iPhone 上应该看到 app 图标。

请按下面顺序检查：

1. App 能否正常打开
2. 首页是否正常显示
3. 登录或注册是否成功
4. 需要请求后端的数据页面是否正常
5. 图片上传、任务、徽章等接口是否可用

如果图标出现了、页面也能打开，但登录失败或列表一直空白，基本可以优先怀疑：

- 后端地址没有传对
- 后端没有启动
- 防火墙拦住了请求

## 第 9 步：常见问题排查

### 问题 1：手机能装上 app，但打开后接口都失败

最常见原因：

- 仍然在访问 `127.0.0.1:5000`
- `--dart-define` 没传
- 后端 IP 写错
- 防火墙阻止了 `5000`

优先检查：

1. 运行命令里是不是带了 `--dart-define`
2. 手机上的 Safari 能不能打开 `http://<后端IP>:5000/`

### 问题 2：Xcode 提示 Bundle Identifier 冲突

解决方法：

- 把 `Bundle Identifier` 改成更独特的值

例如：

```text
com.trainquest.alice
```

### 问题 3：Xcode 提示 Signing 失败

常见原因：

- 没有登录 Apple ID
- Team 没选
- 手机没被当前 Apple ID 注册
- 自动签名没有开启

处理顺序：

1. 检查 `Accounts` 里是否已登录 Apple ID
2. 检查 `Automatically manage signing` 是否勾选
3. 检查 `Team` 是否已选择
4. 点击 `Fix Issue`

### 问题 4：手机上看不到 Developer Mode

通常是因为手机还没和 Xcode 完整建立一次开发连接。

解决方法：

1. 确保数据线连接正常
2. 手机点“信任此电脑”
3. 在 Xcode 中选择这台手机作为目标设备
4. 再去 `设置 > 隐私与安全性` 查找 `Developer Mode`

### 问题 5：`flutter doctor` 里 iOS toolchain 异常

常见修复：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 问题 6：iPhone 能访问浏览器地址，但 app 里仍然报网络错误

这时要考虑 iOS 的 `ATS`（App Transport Security） 对本地 `HTTP` 请求的限制。

先做判断：

1. 手机 Safari 能打开 `http://<后端IP>:5000/`
2. App 却提示网络请求失败

如果出现这种情况，说明很可能需要在 iOS 的 `Info.plist` 里增加本地网络或 HTTP 访问例外配置。

这是一个项目级改动，建议由你统一改一次，然后再让所有组员重新拉代码。  
如果你走到这一步，我建议你直接让我帮你补这一段 iOS 配置。

## 第 10 步：什么时候不需要组员在自己的 Mac 上跑项目

如果你们后续想让“别人像正常安装 app 一样安装”，推荐走下面的正式分发方式：

### 方式 1：TestFlight

适合课程展示和多人测试。

特点：

- 需要 Apple Developer Program
- 你上传一次，测试成员不用拿源码
- 组员只需要安装 TestFlight 并接受邀请

### 方式 2：导出 `.ipa` 给指定设备安装

特点：

- 仍然需要正确签名
- 安装和证书管理比较麻烦
- 不如 TestFlight 省心

## 你们当前最建议的执行方案

对于你们现在的阶段，我建议直接这样安排：

1. 你把整个项目发给组员
2. 组员在自己的 Mac 上安装 Xcode、Flutter、CocoaPods
3. 组员打开 `ios/Runner.xcworkspace`
4. 在 Xcode 里完成 Apple ID、Team、Bundle Identifier、Developer Mode 配置
5. 你在自己的电脑上运行后端
6. 组员在自己的 Mac 上执行：

```bash
flutter run --dart-define=TRAINQUEST_API_BASE_URL=http://你的局域网IP:5000
```

这样是你们现在成本最低、最容易成功的一条路。

## 官方参考

- Flutter iOS 真机部署：<https://docs.flutter.dev/get-started/install/macos/mobile-ios>
- Apple Developer Mode：<https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device>
- Apple ATS / 本地网络说明：<https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking>
- Personal Team 不能用于 App Store 提交：<https://developer.apple.com/library/archive/qa/qa1915/_index.html>
