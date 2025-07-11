import SwiftUI

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

struct TestView: View {
    @State private var vocabulary: [VocabularyItem] = []
    @State private var question: VocabularyItem?
    @State private var options: [String] = []
    @State private var answerIndex: Int = 0
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var selectedIdx: Int? = nil
    @State private var currentQuestion: Int = 1
    @State private var wrongWords: [VocabularyItem] = []
    @State private var showAnswerView: Bool = false
    
    var totalQuestions: Int = 10
    
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
                    Text(question.english_word)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding()
                    VStack(spacing: 18) {
                        ForEach(options.indices, id: \.self) { idx in
                            Button(action: {
                                if selectedIdx == nil {
                                    checkAnswer(idx)
                                }
                            }) {
                                Text(options[idx])
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
                                    .opacity(selectedIdx == nil || selectedIdx == idx ? 1 : 0.6)
                            }
                        }
                    }
                    if showFeedback, let selected = selectedIdx {
                        if isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                                .padding(.top, 16)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.red)
                                Text("正確答案：\(question.chinese_meaning)")
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                            .padding(.top, 16)
                        }
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
                AnswerView(wrongWords: wrongWords)
            }
        }
        .onAppear(perform: loadVocabulary)
    }
    
    func loadVocabulary() {
        if let url = Bundle.main.url(forResource: "MyVocabulary", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let items = try? JSONDecoder().decode([VocabularyItem].self, from: data) {
            vocabulary = items
            generateQuestion()
        }
    }
    
    func generateQuestion() {
        guard vocabulary.count >= 4 else { return }
        let questionItem = vocabulary.randomElement()!
        var optionsSet: Set<String> = [questionItem.chinese_meaning]
        while optionsSet.count < 4 {
            if let random = vocabulary.randomElement()?.chinese_meaning {
                optionsSet.insert(random)
            }
        }
        let shuffledOptions = Array(optionsSet).shuffled()
        question = questionItem
        options = shuffledOptions
        answerIndex = shuffledOptions.firstIndex(of: questionItem.chinese_meaning) ?? 0
        showFeedback = false
        selectedIdx = nil
    }
    
    func checkAnswer(_ idx: Int) {
        selectedIdx = idx
        isCorrect = (options[idx] == question?.chinese_meaning)
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
}

struct AnswerView: View {
    let wrongWords: [VocabularyItem]
    var body: some View {
        NavigationView {
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
            }
            .padding(.horizontal, 24)
            .navigationTitle("答錯單字")
        }
    }
}

#Preview {
    TestView()
} 
