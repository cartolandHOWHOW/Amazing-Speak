//
//  GameView.swift
//  MyVocab
//
//  Created by 戴老師環境 on 2025-07-13.
//
import SwiftUI

// MARK: - Game View
struct GameView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedGame = 0
    @State private var gameStarted = false
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var gameWords: [Word] = []
    @State private var shuffledOptions: [String] = []
    
    let gameTypes = ["單字配對", "拼字挑戰", "選擇題"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !gameStarted {
                    // Game Selection
                    VStack(spacing: 16) {
                        Text("選擇遊戲模式")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(0..<gameTypes.count, id: \.self) { index in
                            Button(action: {
                                selectedGame = index
                                startGame()
                            }) {
                                HStack {
                                    Image(systemName: getGameIcon(for: index))
                                        .font(.title2)
                                    Text(gameTypes[index])
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .padding()
                } else {
                    // Game Content
                    if selectedGame == 2 { // Multiple Choice
                        MultipleChoiceView(
                            gameWords: $gameWords,
                            currentQuestion: $currentQuestion,
                            score: $score,
                            selectedAnswer: $selectedAnswer,
                            showResult: $showResult,
                            shuffledOptions: $shuffledOptions,
                            onGameEnd: { gameStarted = false }
                        )
                    } else {
                        VStack(spacing: 20) {
                            Text("遊戲開發中...")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Button {
                                // 重置遊戲狀態，返回遊戲選擇頁面
                                gameStarted = false
                            } label: {
                                Text("返回")
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
                    }
                }
            }
            .navigationTitle("遊戲")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func startGame() {
        gameStarted = true
        gameWords = Array(dataManager.app.words.shuffled().prefix(min(10, dataManager.app.words.count)))
        currentQuestion = 0
        score = 0
        nextQuestion()
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
        }
    }
    
    private func getGameIcon(for index: Int) -> String {
        switch index {
        case 0: return "rectangle.connected.to.line.below"
        case 1: return "keyboard"
        case 2: return "questionmark.circle"
        default: return "gamecontroller"
        }
    }
}
