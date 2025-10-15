import AVFoundation

class AudioTonePlayer: NSObject {
    // 摩斯码字典
    private let morseCodeDictionary: [Character: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
        "Z": "--..", "0": "-----", "1": ".----", "2": "..---", "3": "...--",
        "4": "....-", "5": ".....", "6": "-....", "7": "--...", "8": "---..",
        "9": "----.", " ": "/"
    ]
    
    // 音频配置
    private let sampleRate: Double = 44100
    private let frequency: Double = 800 // 蜂鸣频率，Hz
    private let dotDuration: Double = 3 // 点的时长，秒
    private let dashDuration: Double = 6 // 划的时长，秒
    private let symbolGap: Double = 6 // 符号之间的间隔，秒
    private let letterGap: Double = 6 // 字母之间的间隔，秒
    private let wordGap: Double = 14 // 单词之间的间隔，秒
    
    // 音频引擎组件
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var isPlaying = false
    
    override init() {
        super.init()
        setupAudioSession()
        setupAudioEngine()
    }
    
    // 配置音频会话 - 修复无声音的关键
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
        
        // 修正：使用可选绑定处理AVAudioFormat?
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            fatalError("无法创建音频格式")
        }
        
        audioEngine.connect(playerNode, to: mainMixer, format: audioFormat)
        
        // 设置主混音器音量
        mainMixer.outputVolume = 1.0
        
        print("音频引擎配置完成")
    }
    
    // 将文本转换为摩斯码
    private func textToMorseCode(_ text: String) -> String {
        let uppercaseText = text.uppercased()
        var morseCode = [String]()
        
        for char in uppercaseText {
            if let code = morseCodeDictionary[char] {
                morseCode.append(code)
            } else {
                print("警告: 字符 '\(char)' 没有对应的摩斯码")
            }
        }
        
        let result = morseCode.joined(separator: " ")
        print("转换的摩斯码: \(result)")
        return result
    }
    
    // 生成正弦波音频数据 - 增加音量
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
            // 增加音量从0.5到0.8
            floatBuffer[frame] = Float(sin(2 * Double.pi * frequency * time)) * 0.8
        }
        
        print("生成音调: \(duration)秒, 频率: \(frequency)Hz, 采样数: \(frameCount)")
        return buffer
    }
    
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
    
        // 播放摩斯码 - 增强错误处理
    func playMorseCode(for text: String) {
        guard !isPlaying else { 
            print("正在播放中，请等待完成")
            return 
        }
        
        guard !text.isEmpty else {
            print("错误: 输入文本为空")
            return
        }
        
        print("开始播放摩斯码: '\(text)'")
        let morseCode = textToMorseCode(text)
        
        guard !morseCode.isEmpty else {
            print("错误: 转换的摩斯码为空")
            return
        }
        
        let symbols = morseCode.components(separatedBy: " ")
        print("符号列表: \(symbols)")
        
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
            return
        }
        
        // 播放序列
        playSymbols(symbols, index: 0)
    }
    
    // 递归播放符号序列
    private func playSymbols(_ symbols: [String], index: Int) {
        guard index < symbols.count, isPlaying else {
            // 所有符号播放完毕
            print("播放完成")
            isPlaying = false
            
            // 延迟停止，确保最后声音播放完毕
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.stop()
            }
            return
        }
        
        let symbol = symbols[index]
        print("播放符号 \(index + 1)/\(symbols.count): '\(symbol)'")
        
        // 播放当前符号的所有点和划
        playSymbolCharacters(Array(symbol), index: 0) { [weak self] in
            guard let self = self else { return }
            
            // 符号之间的间隔
            let gap = index < symbols.count - 1 ? self.letterGap : 0
            print("符号间隔: \(gap)秒")
            let silence = self.generateSilence(duration: gap)
            
            self.playerNode.scheduleBuffer(silence) {
                self.playSymbols(symbols, index: index + 1)
            }
        }
    }
    
    // 递归播放单个符号的点和划
    private func playSymbolCharacters(_ characters: [Character], index: Int, completion: @escaping () -> Void) {
        guard index < characters.count, isPlaying else {
            completion()
            return
        }
        
        let char = characters[index]
        let isLast = index == characters.count - 1
        
        // 确定是点还是划
        let duration = char == "." ? dotDuration : dashDuration
        let charType = char == "." ? "点" : "划"
        print("播放\(charType): \(duration)秒")
        
        let tone = generateTone(duration: duration)
        
        playerNode.scheduleBuffer(tone) { [weak self] in
            guard let self = self else { return }
            
            // 如果不是最后一个字符，添加符号间间隔
            if !isLast {
                let silence = self.generateSilence(duration: self.symbolGap)
                self.playerNode.scheduleBuffer(silence) {
                    self.playSymbolCharacters(characters, index: index + 1, completion: completion)
                }
            } else {
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
    
    deinit {
        stop()
        print("AudioTonePlayer 已释放")
    }
}
