import SwiftUI
import AVFoundation // 為了播放音檔

// MARK: - 3. Learn New Word View (新增)
struct LearnNewWordView: View {
    @EnvironmentObject var data: DataManager
    @State private var currentWord: Word? // 當前顯示的單字
    @State private var showDefinition = false // 控制定義和例句的顯示
    @State private var progress: Double = 0.0 // 學習進度 (例如：今天已學習的單字數量 / 今日目標)

    // 語音播放器
    @State private var audioPlayer: AVPlayer?

    var body: some View {
        VStack {
            if data.isLoading {
                ProgressView("載入單字中...")
            } else if let error = data.loadError {
                Text("載入錯誤: \(error)")
                    .foregroundColor(.red)
            } else if let word = currentWord {
                ScrollView {
                    VStack(spacing: 20) {
                        // 進度條
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                            .padding(.horizontal)
                        
                        // 單字卡片
                        WordCard(word: word, showDefinition: showDefinition)
                            .padding(.horizontal)
                        
                        Spacer()

                        // 操作按鈕
                        VStack(spacing: 15) {
                            Button {
                                playAudio(from: word.audioUrl)
                            } label: {
                                Label("播放發音", systemImage: "speaker.wave.3.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button {
                                withAnimation {
                                    showDefinition.toggle()
                                }
                            } label: {
                                Text(showDefinition ? "隱藏解釋" : "顯示解釋")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                            
                            HStack(spacing: 15) {
                                Button {
                                    markWordAsLearned()
                                } label: {
                                    Label("我學會了", systemImage: "checkmark.circle.fill")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                
                                Button {
                                    loadNextWord()
                                } label: {
                                    Label("跳過", systemImage: "arrow.forward.circle.fill")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                // 沒有更多單字可供學習
                ContentUnavailableView {
                    Label("所有單字都已學過", systemImage: "checkmark.seal.fill")
                } description: {
                    Text("您已經完成了目前所有的單字學習！")
                } actions: {
                    Button("返回首頁") {
                        // 返回上一頁或主頁的邏輯
                    }
                }
            }
        }
        .navigationTitle("學習新單字")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupView)
    }

    // MARK: - Helper Functions
    
    private func setupView() {
        // 在視圖顯示時載入第一個未學習的單字
        if currentWord == nil {
            loadNextWord()
        }
        updateProgress()
    }

    private func loadNextWord() {
        // 查找一個未學習的單字
        currentWord = data.app.words.first(where: { !$0.userStatus.learned })
        showDefinition = false // 每次載入新單字都隱藏解釋
        updateProgress()
    }

    private func markWordAsLearned() {
        guard let word = currentWord else { return }

        // 更新單字狀態
        var updatedStatus = word.userStatus
        updatedStatus.learned = true
        updatedStatus.reviewCount += 1
        updatedStatus.correctCount += 1
        updatedStatus.lastReviewed = Date().formatted(date: .numeric, time: .omitted) // 簡單日期格式

        data.updateWordStatus(for: word.id, newStatus: updatedStatus)

        // 更新用戶進度
        var updatedUser = data.app.user
        updatedUser.progress.wordsLearned += 1
        updatedUser.progress.accuracy = calculateAccuracy() // 重新計算準確率
        updatedUser.progress.lastStudyDate = Date().formatted(date: .numeric, time: .omitted) // 更新最後學習日期

        data.updateUser(updatedUser)

        // 檢查是否達到每日目標，更新成就
        if updatedUser.progress.wordsLearned % updatedUser.settings.dailyGoal == 0 && updatedUser.progress.wordsLearned > 0 {
            // 達到今日目標，可以考慮彈出提示或解鎖成就
            print("恭喜！已達到今日學習目標。")
            // 實際應該檢查是否有對應的每日目標成就來解鎖
            // 這裡可以觸發成就相關邏輯
        }
        
        // 載入下一個單字
        loadNextWord()
    }
    
    private func calculateAccuracy() -> Double {
        let totalCorrect = data.app.words.reduce(0) { $0 + $1.userStatus.correctCount }
        let totalReviewed = data.app.words.reduce(0) { $0 + $1.userStatus.reviewCount }
        
        guard totalReviewed > 0 else { return 0.0 }
        return Double(totalCorrect) / Double(totalReviewed)
    }

    private func updateProgress() {
        let learnedToday = data.app.user.progress.wordsLearned % data.app.user.settings.dailyGoal
        let dailyGoal = data.app.user.settings.dailyGoal
        self.progress = Double(learnedToday) / Double(dailyGoal)
    }

    private func playAudio(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("無效的音頻 URL: \(urlString)")
            return
        }

        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
    }
}

// MARK: - Supporting View: WordCard

struct WordCard: View {
    let word: Word
    let showDefinition: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 分离标题部分
            titleSection
            
            // 分离语音部分
            phoneticSection
            
            // 分离词性部分
            partOfSpeechSection
            
            // 分离定义部分
            if showDefinition {
                definitionSection
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - 子视图组件
    
    private var titleSection: some View {
        Text(word.word)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    private var phoneticSection: some View {
        Text(word.phonetic)
            .font(.title2)
            .foregroundColor(.secondary)
    }
    
    private var partOfSpeechSection: some View {
        Text(word.partOfSpeech)
            .font(.headline)
            .foregroundColor(.gray)
    }
    
    private var definitionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()
            definitionList
        }
    }
    
    private var definitionList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(word.definitions.enumerated()), id: \.offset) { index, definition in
                DefinitionRow(definition: definition)
            }
        }
    }
}

// MARK: - 定義 Row 组件
struct DefinitionRow: View {
    let definition: Definition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            definitionText
            exampleText
            translationText
        }
        .padding(.bottom, 8)
    }
    
    private var definitionText: some View {
        Text(definition.definition)
            .font(.body)
            .foregroundColor(.primary)
    }
    
    private var exampleText: some View {
        Text("例句: \(definition.example)")
            .font(.body)
            .italic()
            .foregroundColor(.secondary)
    }
    
    private var translationText: some View {
        Text("翻譯: \(definition.exampleTranslation)")
            .font(.callout)
            .foregroundStyle(.tertiary)
    }
}
