import SwiftUI
import AVFoundation // 依然需要，因為 VocabularyItem 可能會用到，或者未來會再用

struct VocabularyItem: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let english_word: String
    let part_of_speech: String
    let chinese_meaning: String
    let example_sentence: String
    
    private enum CodingKeys: String, CodingKey {
        case english_word, part_of_speech, chinese_meaning, example_sentence
    }
}

// ⭐️ 新增這個結構，用來包裝你的選項文字，並讓它符合 Identifiable 協定
struct Option: Identifiable {
    let id = UUID() // 每個選項都給予一個唯一的 ID
    let text: String // 選項的實際中文意思
}

struct TestView: View {
    var vocabFile: String = "MyVocabulary02"
    var filter: ((VocabularyItem) -> Bool)? = nil
    @State private var vocabulary: [VocabularyItem] = []
    @State private var question: VocabularyItem?
    
    // ⭐️ 修改 options 的類型為 [Option]
    @State private var options: [Option] = [] // 現在儲存 Option 物件
    
    @State private var answerIndex: Int = 0 // 這個索引將是 options 陣列中正確選項的索引
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var selectedIdx: Int? = nil // 儲存使用者選擇的選項索引
    @State private var currentQuestion: Int = 1
    @State private var wrongWords: [VocabularyItem] = []
    @State private var showAnswerView: Bool = false
    var totalQuestions: Int = 10
    
    // ⭐️ 使用 @StateObject 來管理 SpeechSynthesizerManager 的生命週期
    @StateObject private var speechManager = SpeechSynthesizerManager()
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("單字測驗 \(currentQuestion)/\(totalQuestions)")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.top, 32)
                Spacer()
                if let question = question {
                    let _ = print("🟢 TestView body: 顯示問題 \(question.english_word)")
                    HStack(spacing: 12) {
                        Text(question.english_word)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Button(action: {
                            // ⭐️ 呼叫 speechManager 的 speak 方法
                            speechManager.speak(text: question.english_word)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("發音")
                    }
                    .padding()
                    VStack(spacing: 18) {
                        // ⭐️ 修改 ForEach 的迭代方式
                        // 直接迭代 options 陣列中的 Option 物件，並使用其 id 屬性
                        ForEach(options) { optionItem in
                            let _ = print("🟢 TestView body: 顯示選項 \(optionItem.text)") // 打印實際迭代的選項
                            Button(action: {
                                // 點擊後檢查答案的邏輯需要找到 optionItem 在 options 陣列中的索引
                                if selectedIdx == nil {
                                    if let currentIdx = options.firstIndex(where: { $0.id == optionItem.id }) {
                                        checkAnswer(currentIdx)
                                    }
                                }
                            }) {
                                Text(optionItem.text) // 使用 optionItem.text
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(22)
                                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                                    // 這裡的透明度判斷邏輯：
                                    // 如果還沒選，或是已經選了而且是當前這個選項，則為不透明。
                                    // 如果已經選了但不是當前這個選項，則為半透明。
                                    .opacity(selectedIdx == nil || (selectedIdx != nil && options[selectedIdx!].id == optionItem.id) ? 1 : 0.6)
                            }
                        }
                    }
                    // 這裡可以放置你顯示反饋的 UI 邏輯
                    if showFeedback {
                        Text(isCorrect ? "答對了！" : "答錯了！")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(isCorrect ? .green : .red)
                            .transition(.opacity) // 添加過渡效果
                    }
                } else {
                    Text("載入中...")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .fullScreenCover(isPresented: $showAnswerView) {
                AnswerView(wrongWords: wrongWords, dismiss: { showAnswerView = false })
            }
        }
        .onAppear(perform: loadVocabulary)
        // ⭐️ 當 View 消失時停止發音，避免資源洩漏或意外播放
        .onDisappear {
            speechManager.stopSpeaking()
        }
    }
    
    func loadVocabulary() {
        if let url = Bundle.main.url(forResource: vocabFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let items = try JSONDecoder().decode([VocabularyItem].self, from: data)
                print("🔵 成功解碼所有 \(items.count) 個單字。")
                
                if let filter = filter {
                    vocabulary = items.filter(filter)
                    print("✅ 過濾後，此測驗有 \(vocabulary.count) 個單字。")
                } else {
                    vocabulary = items
                    print("✅ 未使用過濾，此測驗有 \(vocabulary.count) 個單字。")
                }
                
                if vocabulary.count >= 4 {
                    generateQuestion()
                    print("✅ 已成功生成第一道題目。")
                } else {
                    print("❌ 單字數量不足 4 個 (\(vocabulary.count) 個)，無法生成題目。")
                    // 可以考慮在這裡顯示一個提示訊息給使用者
                }
                
            } catch {
                print("❌ 讀取或解碼 JSON 失敗，錯誤: \(error.localizedDescription)")
            }
        } else {
            print("❌ 找不到 JSON 檔案：\(vocabFile).json，請確認 Target Membership。")
        }
    }
    
    // ⭐️ 修改 generateQuestion() 函數以處理 Option 類型
    func generateQuestion() {
        guard vocabulary.count >= 4 else {
            print("🔴 單字數量不足 4 個 (\(vocabulary.count) 個)，無法生成題目。")
            question = nil // 清除問題，避免顯示舊的或錯誤的數據
            options = []  // 清除選項
            return
        }
        
        // 1. 隨機選擇正確答案
        question = vocabulary.randomElement()
        guard let correctAnswer = question else {
            print("🔴 無法從詞彙表中選取正確答案。")
            return
        }
        
        // 2. 收集所有唯一的中文意思，包括正確答案的
        var allUniqueMeanings = Set<String>()
        for item in vocabulary {
            allUniqueMeanings.insert(item.chinese_meaning)
        }
        
        // 確保正確答案的中文意思也在唯一的選項池中
        allUniqueMeanings.insert(correctAnswer.chinese_meaning)
        
        // 3. 從唯一的中文意思中，選出三個不同於正確答案的錯誤選項
        var wrongOptions: [String] = []
        let potentialWrongMeanings = allUniqueMeanings.filter { $0 != correctAnswer.chinese_meaning }
        
        // 如果可用的錯誤選項不足 3 個，就盡量選。
        if potentialWrongMeanings.count >= 3 {
            // 從可用的錯誤選項中隨機選取 3 個
            wrongOptions = Array(potentialWrongMeanings.shuffled().prefix(3))
        } else {
            // 如果不足 3 個，就使用所有可用的錯誤選項。這會導致選項少於 4 個。
            wrongOptions = Array(potentialWrongMeanings.shuffled())
            print("⚠️ 警告：可用的錯誤選項不足 3 個，只有 \(wrongOptions.count) 個錯誤選項。")
        }
        
        // 4. 組合成最終選項並隨機排序
        var finalOptionsStrings = [correctAnswer.chinese_meaning] // 先加入正確答案的字符串
        finalOptionsStrings.append(contentsOf: wrongOptions)       // 再加入選定的錯誤答案字符串
        
        // ⭐️ 將字符串陣列轉換為 Option 物件陣列
        // 這裡確保每個選項都帶有唯一的 ID，這是 ForEach 所需的穩定性
        options = finalOptionsStrings.shuffled().map { Option(text: $0) }
        
        // 5. 找到正確答案在隨機排序後的選項陣列中的索引
        // 現在需要從 Option 物件中找到正確的中文意思所對應的索引
        answerIndex = options.firstIndex(where: { $0.text == correctAnswer.chinese_meaning }) ?? 0
        
        // 6. 重置狀態
        selectedIdx = nil
        isCorrect = false
        showFeedback = false // 重置反饋顯示
        
        print("🟢 問題生成完成: \(correctAnswer.english_word)，選項: \(options.map(\.text))") // 日誌輸出時轉回字符串
        print("🟢 最終選項陣列內容 (從 generateQuestion 結束): \(options.map(\.text))")
        print("🟢 最終選項陣列數量 (從 generateQuestion 結束): \(options.count)")
    }
    
    // ⭐️ 修改 checkAnswer 函數以處理 Option 類型
    func checkAnswer(_ selectedOptionIndex: Int) {
        selectedIdx = selectedOptionIndex
        // 確保 selectedOptionIndex 不會越界
        guard selectedOptionIndex < options.count else { return }
        
        // ⭐️ 現在比較的是 Option 物件的 text 屬性
        isCorrect = options[selectedOptionIndex].text == question?.chinese_meaning
        showFeedback = true
        
        if !isCorrect, let q = question {
            wrongWords.append(q)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentQuestion < totalQuestions {
                currentQuestion += 1
                generateQuestion()
            } else {
                showAnswerView = true
            }
        }
    }
    
    func nextQuestion() {
        // 這個函數通常用於跳轉到下一題，但你的邏輯已經在 checkAnswer 裡處理了
        // 如果這個函數有被調用，請確保它符合你的需求
    }
}

struct AnswerView: View {
    let wrongWords: [VocabularyItem]
    let dismiss: () -> Void
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("你答錯的單字：")
                    .font(.title2)
                    .padding(.top, 24)
                if wrongWords.isEmpty {
                    Text("全部答對，太厲害了！")
                        .font(.title3)
                        .foregroundColor(.green)
                        .padding(.top, 32)
                } else {
                    List(wrongWords, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.english_word)
                                .font(.headline)
                            Text(item.chinese_meaning)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Text("返回主選單")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(22)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .navigationTitle("答錯單字")
        }
    }
}

#Preview {
    TestView()
}
