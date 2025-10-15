import AVFoundation

class AudioTonePlayer: NSObject {
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
    private let tapPlayerNode = AVAudioPlayerNode()
    private var isPlaying = false
    private var isTapPlaying = false // 专门跟踪 tapPlayerNode 的播放状态
    
    // MARK: - 音频基础设置

    // 设置频率
    func setFrequency(_ frequency: Int) {
        self.frequency = Double(frequency)
    }

    // 设置速度（每分钟单词数），主要设置的是点的时长，其他的都是根据点的时长计算出来的。
    func setSpeed(_ wpm: Int) {
        let _wpm = (60.0 / Double(wpm)) / 50.0
        self.dotDuration = _wpm
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
        
        // 为 tapPlayerNode 安排持续的音频缓冲区
        let continuousTone = generateTone(duration: 1) // 1秒的长音，循环播放
        tapPlayerNode.scheduleBuffer(continuousTone, at: nil, options: .loops, completionHandler: nil)
    }
    
    // MARK: - 生命周期方法 初始化和销毁
    init(sampleRate: Double) {
        super.init()
        self.sampleRate = sampleRate
        setupAudioSession()
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
        audioEngine.attach(tapPlayerNode)
        
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            fatalError("无法创建音频格式")
        }
        
        audioEngine.connect(playerNode, to: mainMixer, format: audioFormat)
        audioEngine.connect(tapPlayerNode, to: mainMixer, format: audioFormat)
        
        print("音频引擎配置完成")
    }
    
    // 结束
    deinit {
        stopMorseCode() // 停止播放摩斯码
        playStop() // 停止按键播放
        tapPlayerNode.stop()
        tapPlayerNode.reset()
        print("AudioTonePlayer 已释放")
    }
    
    // MARK: - 播放/停止 摩斯码
    
    // 播放摩斯码，只接受".", "-", " "，这三种数据。
    func playMorseCode(for morseCode: String) -> Int {
        guard !isPlaying else {
            print("正在播放中，请等待完成")
            return 1
        }
        
        // 如果 tapPlayerNode 正在播放，先停止它
        if isTapPlaying {
            tapPlayerNode.pause()
            isTapPlaying = false
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
        playSymbols(symbols, index: 0)
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
    
    // 递归播放符号序列
    private func playSymbols(_ symbols: [String], index: Int) {
        guard index < symbols.count, isPlaying else {
            // 所有符号播放完毕
            print("播放完成")
            isPlaying = false
            
            // 延迟停止，确保最后声音播放完毕
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.stopMorseCode()
            }
            return
        }
        
        let symbol = symbols[index]
        print("播放符号 \(index + 1)/\(symbols.count): '\(symbol)'")
        
        // 播放当前符号的所有点和划
        playSymbolCharacters(Array(symbol), index: 0) { [weak self] in
            self?.playFinishedNotify()
            print("play finished")
        }
    }
    
    // 递归播放单个符号的点和划
    private func playSymbolCharacters(_ characters: [Character], index: Int, completion: @escaping () -> Void) {
        guard index < characters.count, isPlaying else {
            completion()
            return
        }
        
        let char = characters[index]
//        let isLast = index == characters.count - 1

        var duration = Double(0);
        if char == "." {
            // 播放一个点
            duration = self.dotDuration
        } else if char == "-" {
            // 播放一个划
            duration = self.dashDuration
        } else if char == "i" {
            // 播放一个点和划之间的间隔
            duration = self.dotDashDuration
        } else if char == "o" {
            // 播放一个字母之间的间隔
            duration = self.oneWhiteSpaceDuration
        } else if char == "t" {
            // 播放一个单词之间的间隔
            duration = self.twoWhiteSpacesDuration
        }
        
        // 确定是点划，播放声音
        if (char == ".") || (char == "-") {
            // 播放一个点或划
            let tone = generateTone(duration: duration)
            playerNode.scheduleBuffer(tone) {
                self.playSymbolCharacters(characters, index: index + 1, completion: completion)
            }
        } else {
            // 其他则静音
            let silence = generateSilence(duration: duration)
            playerNode.scheduleBuffer(silence) {
                self.playSymbolCharacters(characters, index: index + 1, completion: completion)
            }
        }

        // 如果是第一个字符，需要启动播放
        if index == 0 {
            print("开始播放节点")
            playerNode.play()
        }
    }
    
    // 停止播放
    func stopMorseCode() {
        isPlaying = false
        isTapPlaying = false
        
        if playerNode.isPlaying {
            playerNode.stop()
        }
        
        if tapPlayerNode.isPlaying {
            tapPlayerNode.stop()
            tapPlayerNode.reset()
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

    // 打印当前时间（精确到纳秒）
    func displayTime(_ title: String) {
        // 打印当前时间（精确到纳秒）
        let now = CACurrentMediaTime()
        print("\(title) \(now)")
    }
    
    // 播放完成通知
    func playFinishedNotify() {
        self.isPlaying = false
    }
    
    // 检查音频是否真的在播放
    func isActuallyPlaying() -> Bool {
        return tapPlayerNode.isPlaying && audioEngine.isRunning
    }

    // MARK: - 声音播放控制

    // 播放
    func playNow() {
        displayTime("开始播放1")
        
        // 如果已经在播放，先停止之前的
        if isTapPlaying {
            tapPlayerNode.pause()
//            tapPlayerNode.reset()
            // 给音频系统一点时间来处理停止操作
            Thread.sleep(forTimeInterval: 0.05)
        }
        
        isTapPlaying = true
        
        // 确保音频引擎正在运行
        do {
            if !audioEngine.isRunning {
                try audioEngine.start()
                print("音频引擎启动成功")
                // 音频引擎启动后需要一点时间来稳定
                Thread.sleep(forTimeInterval: 0.1)
            }
        } catch {
            print("音频引擎启动失败: \(error.localizedDescription)")
            isTapPlaying = false
            return
        }
        
        displayTime("真正播放6")
        // 开始一直播放，直到调用stop()
        tapPlayerNode.play()
        displayTime("真正播放7")
        // 等待音频真正开始播放
        while !tapPlayerNode.isPlaying {
        }
        
        if tapPlayerNode.isPlaying {
            displayTime("真正播放8")
        } else {
            print("警告：音频可能未能正常开始播放")
        }

        displayTime("开始播放9")
    }

    func playStop() {
        // 打印当前时间（精确到纳秒）
        displayTime("停止播放1")
        
        // 停止播放节点
        if tapPlayerNode.isPlaying {
            tapPlayerNode.pause()
            // 延迟重置，确保停止操作完成
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//                self?.tapPlayerNode.reset()
//            }
        }
        
        // 给音频系统一点时间来处理停止操作
        Thread.sleep(forTimeInterval: 0.05)
        
        displayTime("停止播放2")
        print("============")
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
