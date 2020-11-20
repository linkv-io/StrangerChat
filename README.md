# 一对一视频通话

本文介绍如何使用StrangerChatSDK视频通话SDK快速实现视频通话

**技术交流及商务合作欢迎进QQ群交流：1160896626**

## 1、示例界面

StrangerChatSDK不仅包含有类似声网和Zego的RTC音视频推拉流及IM通讯能力，除此之外还封装了陌生人交友、视频聊天、网络聊天室等场景需要用到的一些api。例如呼叫、接听、连麦、送礼、礼物动效等常用功能。本文介绍如何使用StrangerChat快速实现音视频通话。

![](https://github.com/linkv-io/StrangerChat/blob/master/Snapshot/StrangerChat.gif?raw=true)

![](https://raw.githubusercontent.com/linkv-io/StrangerChat/master/Snapshot/call.png)

![](https://raw.githubusercontent.com/linkv-io/StrangerChat/master/Snapshot/room.png)

### Demo下载体验

[点我安装Demo或扫描下方二维码下载](https://www.pgyer.com/DWu7)

![](https://www.pgyer.com/app/qrcode/DWu7)

### 前提条件

* iOS9.0或以上版本的设备
* 有效的`AppID`和`AppSign`

## 2、集成SDK

> 在执行以下步骤之前，请确保已安装 CocoaPods。 请参阅 [CocoaPods 官网](https://cocoapods.org/)

在工程 Podfile 文件中添加下列依赖，然后执行 **pod install** 即可添加StrangerChat到工程中（如果搜索不到可以 pod repo update 更新下索引库）

```
pod 'StrangerChat'
```

## 3、设置工程配置

### 添加权限

复制以下代码，粘贴到 info.plist 里面，添加权限（摄像头，麦克风） 描述。

```
<key>NSCameraUsageDescription</key>
<string>LinkV 需要使用摄像头权限，否则无法发布视频直播，无法与主持人视频连麦</string>
<key>NSMicrophoneUsageDescription</key>
<string>LinkV 需要使用麦克风权限，否则无法发布音频直播，无法与主持人音频连麦</string>
```

![img](https://dl.linkv.io/doc/zh/ios/rtc/images/iOS_Auth2.png)

### 关闭 ATS

> 由于目前 SDK 还需要使用 http 域名，所以需要关闭 ATS。

复制以下代码，粘贴到 info.plist 里面，设置 NSAllowsArbitraryLoads 为 YES。

```
<key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
```

![img](https://dl.linkv.io/doc/zh/ios/rtc/images/iOS_ATS2.png)

### 关闭 bitcode

> 由于 SDK 目前没有支持 bitcode，所以需要关闭 bitcode

1. 选择当前 Xcode工程的 target
2. 选择Build Settings - Enable Bitcode 设置为 **No**

![img](https://dl.linkv.io/doc/zh/ios/rtc/images/iOS_bitcode.png)

## 4、测试集成

导入 **<StrangerChat/StrangerChat.h>** 头文件，然后执行 **createEngine** ，运行如果没问题，那么代表集成成功。

```
#import <StrangerChat/StrangerChat.h>
- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始SDK
    self.engine = [StrangerChat createEngine:your_app_id appKey:your_app_sign isTestEnv:NO completion:^(NSInteger code) {
        if (code == 0) {
            NSLog(@"SDK init succeed");
        }
    } delegate:self];
}
```

