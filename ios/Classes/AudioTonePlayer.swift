import AVFoundation

class AudioTonePlayer: NSObject {
//    // 摩斯码字典
//    private let morseCodeDictionary: [Character: String] = [
//        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
//        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
//        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
//        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
//        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
//        "Z": "--..", "0": "-----", "1": ".----", "2": "..---", "3": "...--",
//        "4": "....-", "5": ".....", "6": "-....", "7": "--...", "8": "---..",
//        "9": "----.", " ": "/"
//    ]
    
    // 音频配置
    private var sampleRate: Double = 44100 // 音频采样率，Hz
    private var frequency: Double = 800 // 蜂鸣频率，Hz
    
    // 点、划、点划之间、字母、单词之间的倍数关系
    private var dash_DotTimes: Int = 3 // 划的时长，点的倍数
    private var dotDashInterval_DotTimes: Int = 1 // 点划之间的时长，点的倍数
    private var oneWhiteSpace_DotTimes: Int = 3 // 单空格的间隔，点的倍数 （用于字母之间）
    private var twoWhiteSpaces_DotTimes: Int = 7 // 双空格的间隔，点的倍数 （用于单词之间）
    
    // 点、划、点划之间、字母、单词之间的时长
    private var dotDuration: Double = 0.12 // 点的时长，秒（基础时长），使用setSpeed设置
    private var dashDuration: Double = 0.36 // 划的时长，秒
    private var dotDashDuration: Double = 0.12 // 点划之间的时长，秒
    private var oneWhiteSpaceDuration: Double = 0.36 // 单空格的间隔，秒
    private var twoWhiteSpacesDuration: Double = 0.84 // 双空格的间隔，秒
    
    private var volume: Float = 1.0 // 音量，0.0到1.0之间
    
    // 音频引擎组件
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var isPlaying = false
    
    // MARK: - 音频基础设置

    // 设置频率
    func setFrequency(_ frequency: Int) {
        self.frequency = Double(frequency)
    }

    // 设置速度（每分钟单词数），主要设置的是点的时长，其他的都是根据点的时长计算出来的。
    func setSpeed(_ wpm: Int) {
        self.dotDuration = Double((60 / wpm) / 50 )
        upgradeDuration()
    }
    
    // 设置音量
    func setVolume(_ volume: Float) {
        self.volume = volume
        // 设置主混音器音量
        let mainMixer = audioEngine.mainMixerNode
        mainMixer.outputVolume = volume
    }
    
    // MARK: - 时长设置
    // 设置划的时长（点的倍数）
    func setDashDuration(_ dotTimes: Int) {
        self.dash_DotTimes = dotTimes
        upgradeDuration()
    }

    // 设置点与划之间的间隔时长（点的倍数）
    func setDotDashIntervalDuration(_ dotTimes: Int) {
        self.dotDashInterval_DotTimes = dotTimes
        upgradeDuration()
    }
    
    // 设置单空格的间隔，点的倍数 （用于字母之间）
    func setOneWhiteSpaceDuration(_ dotTimes: Int) {
        self.oneWhiteSpace_DotTimes = dotTimes
        upgradeDuration()
    }

    // 设置双空格的间隔，点的倍数 （用于单词之间）
    func setTwoWhiteSpacesDuration(_ dotTimes: Int) {
        self.twoWhiteSpaces_DotTimes = dotTimes
        upgradeDuration()
    }
    
    // 更新时间配置
    private func upgradeDuration() {
        self.dashDuration = Double(self.dash_DotTimes) * self.dotDuration
        self.dotDashDuration = Double(self.dotDashInterval_DotTimes) * self.dotDuration
        self.oneWhiteSpaceDuration = Double(self.oneWhiteSpace_DotTimes) * self.dotDuration
        self.twoWhiteSpacesDuration = Double(self.twoWhiteSpaces_DotTimes) * self.dotDuration
    }
    
    // MARK: - 生命周期方法 初始化和销毁
    init(sampleRate: Double) {
        super.init()
        setupAudioSession()
        self.sampleRate = sampleRate
        setupAudioEngine()
    }

    // 配置音频会话
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // 设置音频会话类别为播放
            try audioSession.setCategory(.playback, mode: .default, options: [])
            
            // 激活音频会话
            try audioSession.setActive(true)
            
            print("音频会话配置成功")
        } catch {
            print("音频会话配置失败: \(error.localizedDescription)")
        }
    }
    
    // 配置音频引擎
    private func setupAudioEngine() {
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(playerNode)
        
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            fatalError("无法创建音频格式")
        }
        
        audioEngine.connect(playerNode, to: mainMixer, format: audioFormat)
        
        print("音频引擎配置完成")
    }
    
    // 结束
    deinit {
        stop()
        print("AudioTonePlayer 已释放")
    }
    
    // MARK: - 不需要了
    // 将文本转换为摩斯码
//    private func textToMorseCode(_ text: String) -> String {
//        let uppercaseText = text.uppercased()
//        var morseCode = [String]()
//        
//        for char in uppercaseText {
//            if let code = morseCodeDictionary[char] {
//                morseCode.append(code)
//            } else {
//                print("警告: 字符 '\(char)' 没有对应的摩斯码")
//            }
//        }
//        
//        let result = morseCode.joined(separator: " ")
//        print("转换的摩斯码: \(result)")
//        return result
//    }
 
    // MARK: - 播放/停止 摩斯码
    
    // 播放摩斯码，只接受".", "-", " "，这三种数据。
    func playMorseCode(for morseCode: String) -> Int {
        guard !isPlaying else {
            print("正在播放中，请等待完成")
            return 1
        }
        
        guard !morseCode.isEmpty else {
            print("错误: 输入文本为空")
            return 2
        }
        
        // 检查输入是否只包含有效字符
        guard morseCode.allSatisfy({ $0 == "." || $0 == "-" || $0 == " " }) else {
            print("错误: 输入包含无效字符")
            return 3
        }
        
        let symbols = preprocessMorseCode(morseCode)
        
        isPlaying = true
        // 准备并启动音频引擎
        do {
            if !audioEngine.isRunning {
                try audioEngine.start()
                print("音频引擎启动成功")
            }
        } catch {
            print("音频引擎启动失败: \(error.localizedDescription)")
            isPlaying = false
            return 10
        }
        
        // 播放处理后的序列内容
        playSymbols(symbols)
        // 播放音频
        playerNode.play()
        return 0
    }

    // 预处理摩斯码内容, 返回 [Character]
    // 1. 移除收尾空格
    // 2. 连续双空格替换为t（tow的首字母）
    // 3. 单空格替换为o（one的首字母）
    // 4. 点和划之间增加i (interval的首字母)
    // 返回的内容中，包含：".", "-", "o", "t", "i"
    private func preprocessMorseCode(_ morseCode: String) -> [String] {
        var processed = morseCode.trimmingCharacters(in: .whitespaces)
        
        // 连续双空格替换为t（tow的首字母）
        processed = processed.replacingOccurrences(of: "  ", with: "t")
        
        // 单空格替换为o（one的首字母）
        processed = processed.replacingOccurrences(of: " ", with: "o")
        
        // 点和划之间增加i (interval的首字母)
        processed = processed.replacingOccurrences(of: ".", with: "i.")
        processed = processed.replacingOccurrences(of: "-", with: "i-")
        
        // 移除t或o后面的i字母
        processed = processed.replacingOccurrences(of: "ti", with: "t")
        processed = processed.replacingOccurrences(of: "oi", with: "o")

        // 移除首个字母是i的情况
        if processed.first == "i" {
            processed.removeFirst()
        }
        
        return processed.components(separatedBy: "")
    }

    // 循环播放符号序列
    private func playSymbols(_ symbols: [String]) {
        // 循环每一个符号
        for symbol in symbols {
            if symbol == "." {
                // 播放一个点
                playDot()
            }
            if symbol == "-" {
                // 播放一个划
                playDash()
            }
            if symbol == "i" {
                // 播放一个点和划之间的间隔
                playDotDashInterval()
            }
            if symbol == "o" {
                // 播放一个字母之间的间隔
                playLetterGap()
            }
            if symbol == "t" {
                // 播放一个单词之间的间隔
                playWordsInterval()
            }
        }
    }
    
    // 递归播放符号序列
    // private func playSymbols(_ symbols: [String], index: Int) {
    //     guard index < symbols.count, isPlaying else {
    //         // 所有符号播放完毕
    //         print("播放完成")
    //         isPlaying = false
            
    //         // 延迟停止，确保最后声音播放完毕
    //         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
    //             self?.stop()
    //         }
    //         return
    //     }
        
    //     let symbol = symbols[index]
    //     print("播放符号 \(index + 1)/\(symbols.count): '\(symbol)'")
        
    //     // 播放当前符号的所有点和划
    //     playSymbolCharacters(Array(symbol), index: 0) { [weak self] in
    //         guard let self = self else { return }
            
    //         // 符号之间的间隔
    //         let gap = index < symbols.count - 1 ? self.letterGap : 0
    //         print("符号间隔: \(gap)秒")
    //         let silence = self.generateSilence(duration: gap)
            
    //         self.playerNode.scheduleBuffer(silence) {
    //             self.playSymbols(symbols, index: index + 1)
    //         }
    //     }
    // }
    
    // 递归播放单个符号的点和划
    // private func playSymbolCharacters(_ characters: [Character], index: Int, completion: @escaping () -> Void) {
    //     guard index < characters.count, isPlaying else {
    //         completion()
    //         return
    //     }
        
    //     let char = characters[index]
    //     let isLast = index == characters.count - 1
        
    //     // 确定是点还是划
    //     let duration = char == "." ? dotDuration : dashDuration
    //     let charType = char == "." ? "点" : "划"
    //     print("播放\(charType): \(duration)秒")
        
    //     let tone = generateTone(duration: duration)
        
    //     playerNode.scheduleBuffer(tone) { [weak self] in
    //         guard let self = self else { return }
            
    //         // 如果不是最后一个字符，添加符号间间隔
    //         if !isLast {
    //             let silence = self.generateSilence(duration: self.symbolGap)
    //             self.playerNode.scheduleBuffer(silence) {
    //                 self.playSymbolCharacters(characters, index: index + 1, completion: completion)
    //             }
    //         } else {
    //             self.playSymbolCharacters(characters, index: index + 1, completion: completion)
    //         }
    //     }
        
    //     // 如果是第一个字符，需要启动播放
    //     if index == 0 {
    //         print("开始播放节点")
    //         playerNode.play()
    //     }
    // }
    
    // 停止播放
    func stop() {
        print("停止播放")
        isPlaying = false
        
        if playerNode.isPlaying {
            playerNode.stop()
        }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.reset()
        }
        
        // 取消激活音频会话
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("音频会话已取消激活")
        } catch {
            print("取消音频会话激活失败: \(error.localizedDescription)")
        }
    }

    // MARK: - 增加音频流

    // 增加一个点到音频流中，高频
    private func playDot() {
        let dot = generateTone(duration: dotDuration)
        playerNode.scheduleBuffer(dot)
    }

    // 增加一个划到音频流中，高频
    private func playDash() {
        let dash = generateTone(duration: dashDuration)
        playerNode.scheduleBuffer(dash)
    }

    // 播放一个点和划之间的间隔，静音
    private func playDotDashInterval() {
        let interval = generateSilence(duration: dotDashDuration)
        playerNode.scheduleBuffer(interval)
    }

    // 播放一个字母之间的间隔，静音
    private func playLetterGap() {
        let gap = generateSilence(duration: oneWhiteSpaceDuration)
        playerNode.scheduleBuffer(gap)
    }
    
    // 播放一个单词之间的间隔，静音
    private func playWordsInterval() {
        let interval = generateSilence(duration: twoWhiteSpacesDuration)
        playerNode.scheduleBuffer(interval)
    }
    
    // MARK: - 生成正弦波音频数据
    // 生成正弦波音频数据
    private func generateTone(duration: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        // 修正：使用可选绑定处理AVAudioFormat?
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            fatalError("无法创建音频缓冲区")
        }
        
        buffer.frameLength = frameCount
        let floatBuffer = buffer.floatChannelData![0]
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            floatBuffer[frame] = Float(sin(2 * Double.pi * frequency * time))
        }
        
        print("生成音调: \(duration)秒, 频率: \(frequency)Hz, 采样数: \(frameCount)")
        return buffer
    }
    
    // MARK: - 生成静音音频数据
    // 生成静音音频数据
    private func generateSilence(duration: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        // 修正：使用可选绑定处理AVAudioFormat?
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            fatalError("无法创建静音缓冲区")
        }
        
        buffer.frameLength = frameCount
        let floatBuffer = buffer.floatChannelData![0]
        
        for frame in 0..<Int(frameCount) {
            floatBuffer[frame] = 0.0
        }
        
        print("生成静音: \(duration)秒, 采样数: \(frameCount)")
        return buffer
    }

}
