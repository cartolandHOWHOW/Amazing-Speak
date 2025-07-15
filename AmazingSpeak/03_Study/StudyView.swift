
import SwiftUI
import AVFoundation


// MARK: - 3. Study View
struct StudyView: View {
    
    let synthesizer = AVSpeechSynthesizer() // MARK: 夏志先修改的發音常數
    
    @EnvironmentObject var dataManager: DataManager
    @State private var currentWordIndex = 0
    @State private var showAnswer = false
    @State private var isCorrect: Bool?
    
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !dataManager.app.words.isEmpty {
                    let word = dataManager.app.words[currentWordIndex]
                    
                    // Progress
                    ProgressView(value: Double(currentWordIndex + 1) / Double(dataManager.app.words.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                    
                    Text("\(currentWordIndex + 1) / \(dataManager.app.words.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    
                    // MARK: Word Card
                    VStack(spacing: 16) {
                        Text(word.word)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(word.phonetic)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text(word.partOfSpeech)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(6)
                            
                            Text(word.difficulty)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(6)
                        }
                        
                        Button(action: { // MARK: 夏志先修改的發音按鈕
                            let utterance = AVSpeechUtterance(string: "Hello World")
                            utterance.voice = AVSpeechSynthesisVoice(identifier:"com.apple.speech.synthesis.voice.Fred")
                            synthesizer.speak(utterance)
                            
                            // Play audio
                        }) {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        
                        if showAnswer {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(word.definitions, id: \.definition) { definition in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(definition.definition)
                                            .font(.headline)
                                        Text(definition.example)
                                            .font(.subheadline)
                                            .italic()
                                            .foregroundStyle(.secondary)
                                        Text(definition.exampleTranslation)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // MARK: Action Buttons
                    if !showAnswer {
                        
                        Button { // 移除了 label 參數，直接將內容放在 closure 裡
                            showAnswer = true
                        } label: {
                            Text("顯示答案")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity) // 讓內容填滿按鈕的寬度
                                .frame(height: 50)           // 讓內容填滿按鈕的高度
                                .background(Color.blue)      // 背景放在這裡
                                .cornerRadius(12)
                            // 這裡很關鍵：告訴 SwiftUI 按鈕的可點擊區域是這個內容的整個矩形
                                .contentShape(Rectangle())
                            
                        }
                        .padding(.horizontal) // Padding 放在 Button 外面
                        
                    } else {
                        HStack(spacing: 16) {
                            Button(action: {
                                nextWord(correct: false)
                            }) {
                                Text("不認識")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.red)
                                    .cornerRadius(12)
                                    .contentShape(Rectangle())
                            }
                            
                            
                            Button(action: {
                                nextWord(correct: true)
                            }) {
                                Text("認識")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .contentShape(Rectangle())
                            }
                            
                        }
                        .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                        
                        Text("沒有可學習的單字")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.vertical)
            .navigationTitle("學習")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func nextWord(correct: Bool) {
        let word = dataManager.app.words[currentWordIndex]
        var updatedStatus = word.userStatus
        updatedStatus.reviewCount += 1
        
        if correct {
            updatedStatus.correctCount += 1
            updatedStatus.learned = true
        }
        
        dataManager.updateWordStatus(for: word.id, newStatus: updatedStatus)
        
        showAnswer = false
        
        if currentWordIndex < dataManager.app.words.count - 1 {
            currentWordIndex += 1
        } else {
            currentWordIndex = 0
        }
    }
}
