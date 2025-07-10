import SwiftUI

struct VocabularyItem: Codable, Identifiable {
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
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var bgIndex: Int = 0
    let bgImages = ["ForMenu", "ForMenu02", "ForMenu03", "ForMenu04"]
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(bgImages[bgIndex])
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: bgIndex)
                .transition(.opacity)
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("WordTrainer")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                    .padding(.top, 32)
                Spacer()
                if let question = question {
                    Text(question.english_word)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                        .padding()
                    VStack(spacing: 18) {
                        ForEach(options.indices, id: \.self) { idx in
                            Button(action: {
                                checkAnswer(idx)
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
                            }
                        }
                    }
                } else {
                    Text("載入中...")
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onReceive(timer) { _ in
            bgIndex = (bgIndex + 1) % bgImages.count
        }
        .alert(isPresented: $showResult) {
            Alert(
                title: Text(isCorrect ? "答對了！" : "答錯了"),
                message: Text(isCorrect ? "恭喜你！" : "正確答案：\(question?.chinese_meaning ?? "")"),
                dismissButton: .default(Text("下一題"), action: {
                    generateQuestion()
                })
            )
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
    }
    
    func checkAnswer(_ idx: Int) {
        isCorrect = (options[idx] == question?.chinese_meaning)
        showResult = true
    }
}

#Preview {
    TestView()
} 
