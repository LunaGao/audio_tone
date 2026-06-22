# audio_tone

![Static Badge](https://img.shields.io/badge/bless-Cats-green)
![Static Badge](https://img.shields.io/badge/AI-doubao-pink)
![Static Badge](https://img.shields.io/badge/AI-TRAE-pink)
![Static Badge](https://img.shields.io/badge/AI-Codex-pink)
![Pub Version](https://img.shields.io/pub/v/audio_tone)
![Flutter Platform](https://img.shields.io/badge/platform-Flutter-blue)

一个专业的Flutter插件，用于音频音调生成和摩斯电码播放。该插件提供全面的音频控制功能，包括频率调制、速度调节和精确的摩斯电码通信时间控制。

> __Note__: **0.1.0 及以上版本** 使用 **Flutter 3.44.0 及以上版本** (iOS 包管理更新至Swift Package Manager). 如果你使用Flutter 3.41.9 或更低的版本(iOS 包管理使用 Pod), 请使用 0.0.9 版本.


## 功能特性 ✨

- **音频音调生成**：生成可定制频率的纯音频音调
- **摩斯电码支持**：完整的摩斯电码播放，支持自定义时间间隔
- **专业音频控制**：精确的音频参数控制
- **跨平台支持**：支持Android和iOS平台
- **实时播放**：实时音频生成和播放控制
- **灵活配置**：丰富的音频参数自定义选项

## 安装 📦

在您的`pubspec.yaml`文件中添加依赖：

```yaml
dependencies:
  audio_tone: ^0.1.0
```

然后运行：

```bash
flutter pub get
```

## 使用方法 🚀

### 基础用法

```dart
import 'package:audio_tone/audio_tone.dart';
import 'package:audio_tone/audio_frequency.dart';

// 创建默认设置的实例
final audioTone = AudioTone();

// 播放简单音调
await audioTone.play();

// 停止音调
await audioTone.stop();
```

### 摩斯电码播放

```dart
// 播放摩斯电码
await audioTone.playMorseCode(".-.-  .-.- .");

// 获取摩斯电码播放时长
double duration = await audioTone.getMorseCodePlayDuration(".-.-  .-.- .");
print("播放时长: $duration 秒");

// 插件支持：
// "." - 点（短音）
// "-" - 划（长音）
// " " - 字母间隔（单个空格）
// "  " - 单词间隔（两个空格）
```

### 原始时序播放

```dart
// 以毫秒数组播放音调/静音序列
// 偶数索引发音，奇数索引静音
final result = await audioTone.playTimings([120, 120, 360]);
print('playTimings 结果: $result');
```

### 高级配置

```dart
// 创建自定义设置的实例
final audioTone = AudioTone(
  sampleRate: AudioSampleRate.cdQuality, // 44100Hz
  frequency: AudioFrequency.defaultFrequency, // 800Hz
  wpm: 10, // 每分钟单词数 (5-100)
  dashDuration: 3, // 划的持续时间（点的倍数）(2-10)
  dotDashIntervalDuration: 1, // 点划间隔（点的倍数）(1-5)
  letterIntervalDuration: 3, // 字母间隔（点的倍数）(1-5)
  wordsIntervalDuration: 7, // 单词间隔（点的倍数）(3-20)
  volume: 1.0, // 音量 (0.0-1.0)
  lightFlashingMagnificationFactor: 5.0, // 灯光闪烁倍数 (1.0-100.0)
);

// 动态调整设置
audioTone.setFrequency(AudioFrequency.frequency1000);
audioTone.setSpeed(15); // 设置为15 WPM
audioTone.setVolume(0.5); // 设置为50%音量
audioTone.setLightFlashingMagnificationFactor(8.0);
```

## API参考 📚

### AudioTone类

#### 构造函数参数

| 参数 | 类型 | 默认值 | 描述 |
|-----------|------|---------|-------------|
| `sampleRate` | AudioSampleRate | `44100Hz` | 音频采样率 |
| `frequency` | AudioFrequency | `800Hz` | 音调频率 |
| `wpm` | int | `10` | 每分钟单词数 (5-100) |
| `dashDuration` | int | `3` | 划的持续时间（点的倍数）(2-10) |
| `dotDashIntervalDuration` | int | `1` | 点划间隔（点的倍数）(1-5) |
| `letterIntervalDuration` | int | `3` | 字母间隔（点的倍数）(1-5) |
| `wordsIntervalDuration` | int | `7` | 单词间隔（点的倍数）(3-20) |
| `volume` | double | `1.0` | 音量级别 (0.0-1.0) |
| `lightFlashingMagnificationFactor` | double | `5.0` | 灯光闪烁倍数 (1.0-100.0) |

#### 方法

- `setFrequency(AudioFrequency frequency)` - 设置音频频率
- `setSpeed(int wpm)` - 设置摩斯电码速度 (5-100 WPM)
- `setDashDuration(int dotsTimes)` - 设置划的持续时间 (2-10 点)
- `setDotDashIntervalDuration(int dotsTimes)` - 设置点划间隔 (1-5 点)
- `setLetterIntervalDuration(int dotsTimes)` - 设置字母间隔 (1-5 点)
- `setWordsIntervalDuration(int dotsTimes)` - 设置单词间隔 (3-20 点)
- `setVolume(double volume)` - 设置音量 (0.0-1.0)
- `setLightFlashingMagnificationFactor(double factor)` - 设置灯光闪烁倍数 (1.0-100.0)
- `playMorseCode(String morseCode)` - 播放摩斯电码字符串
- `playTimings(List<int> timings)` - 按毫秒播放原始发音/静音时序
- `playStream(String morseCode)` - 以流的方式接收摩斯电码播放事件
- `getMorseCodePlayDuration(String morseCode)` - 获取摩斯电码播放时长（秒）
- `play()` - 开始音调播放
- `stop()` - 停止当前音调或序列播放

### AudioFrequency枚举

- `defaultFrequency` (800Hz)
- `frequency600`
- `frequency800`
- `frequency1000`
- `frequency1200`

### AudioSampleRate枚举

- `defaultSampleRate` (44100Hz)
- `telephone` (8000Hz)
- `lowQuality` (11025Hz)
- `voice` (16000Hz)
- `halfCD` (22050Hz)
- `professional` (32000Hz)
- `cdQuality` (44100Hz)
- `professionalVideo` (48000Hz)
- `highQuality` (88200Hz)
- `ultraHighQuality` (96000Hz)
- `extremeQuality` (176400Hz)
- `maximumQuality` (192000Hz)

## 完整示例 🎯

```dart
import 'package:flutter/material.dart';
import 'package:audio_tone/audio_tone.dart';
import 'package:audio_tone/audio_frequency.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final audioTone = AudioTone(wpm: 5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('音频音调插件示例')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('播放摩斯电码'),
              subtitle: const Text('点击播放".-.-  .-.- ."'),
              onTap: () async {
                await audioTone.playMorseCode(".-.-  .-.- .");
              },
            ),
            GestureDetector(
              onTapDown: (_) => audioTone.play(),
              onTapUp: (_) => audioTone.stop(),
              child: ListTile(
                title: const Text('按住播放音调'),
                subtitle: const Text('触摸按住播放，释放停止'),
              ),
            ),
            ListTile(
              title: const Text('设置参数'),
              subtitle: const Text('点击设置频率为1000Hz，速度为15 WPM'),
              onTap: () {
                audioTone.setFrequency(AudioFrequency.frequency1000);
                audioTone.setSpeed(15);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已设置：1000Hz, 15 WPM')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 平台支持 📱

| 平台 | 版本 |
|----------|---------|
| Android | SDK 24+ |
| iOS | 13.0+ |

## 开发说明 🔧

### 项目结构
```
audio_tone/
├── lib/
│   ├── audio_tone.dart              # 主插件类
│   ├── audio_tone_platform_interface.dart  # 平台接口
│   ├── audio_tone_method_channel.dart      # 方法通道实现
│   ├── audio_frequency.dart         # 频率枚举
│   └── audio_sample_rate.dart       # 采样率枚举
├── ios/
│   └── Classes/
│       ├── AudioTonePlugin.swift    # iOS插件实现
│       └── AudioTonePlayer.swift    # iOS音频播放器
├── android/
│   └── src/main/kotlin/
│       └── com/maomishen/audio_tone/
│           └── AudioTonePlugin.kt   # Android插件实现
└── example/                         # 示例应用
```

### 贡献指南 🤝

欢迎贡献！请随时提交Pull Request。对于重大更改，请先开启issue讨论您想要更改的内容。

### 开发环境要求
- Flutter >= 3.3.0
- Dart SDK >= 3.9.2
- Xcode (for iOS development)
- Android Studio (for Android development)

## 许可证 📄

本项目采用BSD 2-Clause许可证 - 查看[LICENSE](LICENSE)文件了解详情。

## 作者 👨‍💻

由[LunaGao](https://github.com/LunaGao)用心创建 ❤️

## 支持 💖

如果您觉得这个插件有帮助，请在[GitHub](https://github.com/LunaGao/audio_tone)上给它一个⭐！

**注意**：这是一个Flutter插件项目，包含Android和iOS平台的原生实现代码。如需Flutter开发帮助，请查看[在线文档](https://docs.flutter.dev)。
