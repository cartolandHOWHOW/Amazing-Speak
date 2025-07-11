import AVFoundation

// 將 AVSpeechSynthesizer 封裝在一個類別中
// 這樣 TestView 就不會直接持有它，避免初始化阻塞
class SpeechSynthesizerManager: NSObject, ObservableObject { // 增加 ObservableObject 以便在 SwiftUI 中使用 @StateObject
    private var synthesizer: AVSpeechSynthesizer

    override init() {
        self.synthesizer = AVSpeechSynthesizer()
        super.init()
        // 可以選擇在這裡設定代理，以便處理語音事件，但對於基本發音不是必須的
        // self.synthesizer.delegate = self
    }

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 確保語言設置正確
        // 可以在這裡添加錯誤處理，例如檢查是否正在發音
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word) // 如果正在發音，先停止
        }
        synthesizer.speak(utterance)
    }

    // 當 View 消失時停止發音，避免資源洩漏或意外播放
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
