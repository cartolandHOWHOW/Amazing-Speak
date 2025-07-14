import SwiftUI

// MARK: - Multiple Choice View
struct MultipleChoiceView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var gameWords: [Word]
    @Binding var currentQuestion: Int
    @Binding var score: Int
    @Binding var selectedAnswer: String?
    @Binding var showResult: Bool
    @Binding var shuffledOptions: [String]
    let onGameEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if !gameWords.isEmpty {
                // Progress
                ProgressView(value: Double(currentQuestion) / Double(gameWords.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal)
                
                HStack {
                
                    Text("\(currentQuestion < gameWords.count ? currentQuestion + 1 : gameWords.count) / \(gameWords.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("分數: \(score)")
                        .font(.headline)
                        .foregroundStyle(.blue)
            
                }
                .padding(.horizontal)
                
                
                if currentQuestion < gameWords.count {
                    let word = gameWords[currentQuestion]
                    
                    // Question
                    VStack(spacing: 16) {
                        
                        Text(word.word)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                        
                        Text(word.phonetic)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(shuffledOptions, id: \.self) { option in
                            Button(action: {
                                selectedAnswer = option
                                checkAnswer(option, correctAnswer: word.definitions[0].definition)
                            }) {
                                Text(option)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        showResult ?
                                        (option == word.definitions[0].definition ? Color.green.opacity(0.3) :
                                            option == selectedAnswer ? Color.red.opacity(0.3) : Color(.systemGray6)) :
                                            Color(.systemGray6)
                                    )
                                    .cornerRadius(12)
                            }
                            .disabled(showResult)
                        }
                    }
                    .padding(.horizontal)
                    
                    if showResult {
                        Button {
                            if currentQuestion + 1 < gameWords.count {
                                // 還有下一題
                                currentQuestion += 1
                                nextQuestion()
                            } else {
                                // 這是最後一題，直接設定為遊戲結束狀態
                                currentQuestion = gameWords.count
                            }
                        } label: {
                            Text(currentQuestion + 1 < gameWords.count ? "下一題" : "查看結果")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                                .contentShape(Rectangle())
                                .padding(.horizontal)
                        }
                    }
                } else {
                    // Game Over
                    
 
                    
                    VStack(spacing: 16) {
                        Text("遊戲結束！")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("最終分數: \(score)")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        
                        // 顯示正確率
                        Text("正確率: \(Int(Double(score) / Double(gameWords.count * 10) * 100))%")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            Button {
                                // 重置遊戲狀態，重新開始同一個遊戲
                                resetGame()
                            } label: {
                                Text("重新開始")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .contentShape(Rectangle())
                            }
                            
                            
                            Button {
                                onGameEnd()
                            } label: {
                                Text("返回選單")
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
                }
                
                Spacer()
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 50))
                        .foregroundStyle(.gray)
                    
                    Text("沒有可用的單字進行遊戲")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func nextQuestion() {
        if currentQuestion < gameWords.count {
            let word = gameWords[currentQuestion]
            var options = [word.definitions[0].definition]
            
            // Add random wrong answers
            let otherWords = dataManager.app.words.filter { $0.id != word.id }.shuffled().prefix(3)
            options.append(contentsOf: otherWords.map { $0.definitions[0].definition })
            
            shuffledOptions = options.shuffled()
            selectedAnswer = nil
            showResult = false
        } else {
            currentQuestion = gameWords.count
        }
    }
    
    private func checkAnswer(_ answer: String, correctAnswer: String) {
        showResult = true
        if answer == correctAnswer {
            score += 10
        }
    }
    
    private func resetGame() {
        currentQuestion = 0
        score = 0
        gameWords = Array(dataManager.app.words.shuffled().prefix(min(10, dataManager.app.words.count)))
        nextQuestion()
    }
}
