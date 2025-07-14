import SwiftUI
import AVFoundation

// MARK: - Data Models
struct User {
    let id: String
    let name: String
    let email: String
    let level: String
    var totalScore: Int
    var streak: Int
    var settings: UserSettings
    var progress: UserProgress
}

struct UserSettings {
    var dailyGoal: Int
    var notifications: Bool
    var soundEnabled: Bool
    var theme: String
}

struct UserProgress {
    var wordsLearned: Int
    var wordsReviewed: Int
    var accuracy: Double
    var lastStudyDate: String
}

struct VocabularyCategory {
    let id: String
    let name: String
    let description: String
    let color: String
    let icon: String
    let wordCount: Int
    let difficulty: String
}

struct Word {
    let id: String
    let word: String
    let phonetic: String
    let partOfSpeech: String
    let difficulty: String
    let frequency: Double
    let categoryId: String
    let definitions: [Definition]
    let synonyms: [String]
    let antonyms: [String]
    let tags: [String]
    let audioUrl: String
    let imageUrl: String
    let dateAdded: String
    var userStatus: UserWordStatus
}

struct Definition {
    let definition: String
    let example: String
    let exampleTranslation: String
}

struct UserWordStatus {
    var learned: Bool
    var starred: Bool
    var reviewCount: Int
    var correctCount: Int
    var lastReviewed: String
    var nextReview: String
}

struct Achievement {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: AchievementRequirement
    let unlocked: Bool
    let unlockedDate: String?
}

struct AchievementRequirement {
    let type: String
    let value: Int
}

// MARK: - Sample Data
class VocabularyData: ObservableObject {
    @Published var user = User(
        id: "user_12345",
        name: "John Doe",
        email: "john@example.com",
        level: "intermediate",
        totalScore: 2850,
        streak: 7,
        settings: UserSettings(dailyGoal: 20, notifications: true, soundEnabled: true, theme: "light"),
        progress: UserProgress(wordsLearned: 156, wordsReviewed: 89, accuracy: 0.85, lastStudyDate: "2025-07-11")
    )
    
    @Published var categories = [
        VocabularyCategory(id: "cat_001", name: "商業英語", description: "商業場合常用單字", color: "#FF6B6B", icon: "briefcase", wordCount: 120, difficulty: "intermediate"),
        VocabularyCategory(id: "cat_002", name: "日常生活", description: "生活中常見單字", color: "#4ECDC4", icon: "house", wordCount: 200, difficulty: "beginner"),
        VocabularyCategory(id: "cat_003", name: "學術英語", description: "學術研究相關單字", color: "#45B7D1", icon: "graduationcap", wordCount: 180, difficulty: "advanced")
    ]
    
    @Published var words = [
        Word(
            id: "word_001",
            word: "accomplish",
            phonetic: "/əˈkʌmplɪʃ/",
            partOfSpeech: "verb",
            difficulty: "intermediate",
            frequency: 0.75,
            categoryId: "cat_001",
            definitions: [
                Definition(definition: "完成；達成", example: "She accomplished her goal of learning 1000 new words.", exampleTranslation: "她完成了學習1000個新單字的目標。")
            ],
            synonyms: ["achieve", "complete", "fulfill"],
            antonyms: ["fail", "abandon"],
            tags: ["business", "achievement"],
            audioUrl: "https://example.com/audio/accomplish.mp3",
            imageUrl: "https://example.com/images/accomplish.jpg",
            dateAdded: "2025-07-01",
            userStatus: UserWordStatus(learned: true, starred: false, reviewCount: 3, correctCount: 2, lastReviewed: "2025-07-10", nextReview: "2025-07-15")
        ),
        Word(
            id: "word_002",
            word: "serendipity",
            phonetic: "/ˌserənˈdɪpɪti/",
            partOfSpeech: "noun",
            difficulty: "advanced",
            frequency: 0.15,
            categoryId: "cat_002",
            definitions: [
                Definition(definition: "意外的幸運發現", example: "Meeting my future business partner was pure serendipity.", exampleTranslation: "遇見我未來的商業夥伴純屬意外的幸運。")
            ],
            synonyms: ["chance", "fortune", "luck"],
            antonyms: ["misfortune", "planned"],
            tags: ["luck", "discovery"],
            audioUrl: "https://example.com/audio/serendipity.mp3",
            imageUrl: "https://example.com/images/serendipity.jpg",
            dateAdded: "2025-07-05",
            userStatus: UserWordStatus(learned: false, starred: true, reviewCount: 1, correctCount: 0, lastReviewed: "2025-07-08", nextReview: "2025-07-12")
        )
    ]
    
    @Published var achievements = [
        Achievement(id: "ach_001", name: "初學者", description: "學習第一個單字", icon: "star", requirement: AchievementRequirement(type: "words_learned", value: 1), unlocked: true, unlockedDate: "2025-06-15"),
        Achievement(id: "ach_002", name: "連續7天", description: "連續7天學習單字", icon: "flame", requirement: AchievementRequirement(type: "streak_days", value: 7), unlocked: true, unlockedDate: "2025-07-10"),
        Achievement(id: "ach_003", name: "單字達人", description: "學習500個單字", icon: "trophy", requirement: AchievementRequirement(type: "words_learned", value: 500), unlocked: false, unlockedDate: nil)
    ]
}


// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var data = VocabularyData()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首頁")
                }
                .tag(0)
            
            CategoryView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("分類")
                }
                .tag(1)
            
            StudyView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("學習")
                }
                .tag(2)
            
            GameView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("遊戲")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("個人")
                }
                .tag(4)
        }
        .environmentObject(data)
    }
}

// MARK: - 1. Home View
struct HomeView: View {
    @EnvironmentObject var data: VocabularyData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("歡迎回來，\(data.user.name)!")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("今天也要加油學習喔！")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(data.user.streak)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Progress Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("今日進度")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("目標：\(data.user.settings.dailyGoal) 個單字")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                ProgressView(value: Double(data.user.progress.wordsLearned % data.user.settings.dailyGoal) / Double(data.user.settings.dailyGoal))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                
                                Text("\(data.user.progress.wordsLearned % data.user.settings.dailyGoal)/\(data.user.settings.dailyGoal)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "target")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Statistics
                    HStack(spacing: 16) {
                        StatCard(title: "已學習", value: "\(data.user.progress.wordsLearned)", icon: "book", color: .green)
                        StatCard(title: "準確率", value: "\(Int(data.user.progress.accuracy * 100))%", icon: "target", color: .blue)
                        StatCard(title: "總分", value: "\(data.user.totalScore)", icon: "star", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("快速開始")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickActionCard(title: "學習新單字", icon: "plus.circle", color: .blue)
                            QuickActionCard(title: "複習單字", icon: "repeat", color: .green)
                            QuickActionCard(title: "單字遊戲", icon: "gamecontroller", color: .purple)
                            QuickActionCard(title: "我的收藏", icon: "heart", color: .red)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Achievements
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("最近成就")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(data.achievements.filter { $0.unlocked }, id: \.id) { achievement in
                                    AchievementCard(achievement: achievement)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("VocabMaster")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - 2. Category View
struct CategoryView: View {
    @EnvironmentObject var data: VocabularyData
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(data.categories, id: \.id) { category in
                        CategoryCard(category: category)
                    }
                }
                .padding()
            }
            .navigationTitle("分類")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - 3. Study View
struct StudyView: View {
    @EnvironmentObject var data: VocabularyData
    @State private var currentWordIndex = 0
    @State private var showAnswer = false
    @State private var isCorrect: Bool?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !data.words.isEmpty {
                    let word = data.words[currentWordIndex]
                    
                    // Progress
                    ProgressView(value: Double(currentWordIndex + 1) / Double(data.words.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                    
                    Text("\(currentWordIndex + 1) / \(data.words.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Word Card
                    VStack(spacing: 16) {
                        Text(word.word)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(word.phonetic)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
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
                        
                        Button(action: {
                            // Play audio
                        }) {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
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
                                            .foregroundColor(.secondary)
                                        Text(definition.exampleTranslation)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                    
                    // Action Buttons
                    if !showAnswer {
                        Button("顯示答案") {
                            showAnswer = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        HStack(spacing: 16) {
                            Button("不認識") {
                                nextWord(correct: false)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                            
                            Button("認識") {
                                nextWord(correct: true)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
            .navigationTitle("學習")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func nextWord(correct: Bool) {
        isCorrect = correct
        showAnswer = false
        
        if currentWordIndex < data.words.count - 1 {
            currentWordIndex += 1
        } else {
            currentWordIndex = 0
        }
    }
}

// MARK: - 4. Game View
struct GameView: View {
    @EnvironmentObject var data: VocabularyData
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
        NavigationView {
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
                        multipleChoiceView()
                    } else {
                        Text("遊戲開發中...")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("遊戲")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func startGame() {
        gameStarted = true
        gameWords = Array(data.words.shuffled().prefix(10))
        currentQuestion = 0
        score = 0
        nextQuestion()
    }
    
    private func nextQuestion() {
        if currentQuestion < gameWords.count {
            let word = gameWords[currentQuestion]
            var options = [word.definitions[0].definition]
            
            // Add random wrong answers
            let otherWords = data.words.filter { $0.id != word.id }.shuffled().prefix(3)
            options.append(contentsOf: otherWords.map { $0.definitions[0].definition })
            
            shuffledOptions = options.shuffled()
            selectedAnswer = nil
            showResult = false
        }
    }
    
    private func multipleChoiceView() -> some View {
        VStack(spacing: 20) {
            // Progress
            ProgressView(value: Double(currentQuestion) / Double(gameWords.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
            
            Text("\(currentQuestion + 1) / \(gameWords.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("分數: \(score)")
                .font(.headline)
                .foregroundColor(.blue)
            
            Spacer()
            
            if currentQuestion < gameWords.count {
                let word = gameWords[currentQuestion]
                
                // Question
                VStack(spacing: 16) {
                    Text("這個單字的意思是？")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(word.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(word.phonetic)
                        .font(.title3)
                        .foregroundColor(.secondary)
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
                                .foregroundColor(.primary)
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
                    Button("下一題") {
                        currentQuestion += 1
                        if currentQuestion < gameWords.count {
                            nextQuestion()
                        } else {
                            endGame()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            } else {
                // Game Over
                VStack(spacing: 16) {
                    Text("遊戲結束！")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("最終分數: \(score)")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Button("重新開始") {
                        gameStarted = false
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
    }
    
    private func checkAnswer(_ answer: String, correctAnswer: String) {
        showResult = true
        if answer == correctAnswer {
            score += 10
        }
    }
    
    private func endGame() {
        // Handle game end
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

// MARK: - 5. Profile View
struct ProfileView: View {
    @EnvironmentObject var data: VocabularyData
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(data.user.name)
                                .font(.headline)
                            Text(data.user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("等級: \(data.user.level)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(data.user.totalScore) 分")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("學習統計") {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.green)
                        Text("已學習單字")
                        Spacer()
                        Text("\(data.user.progress.wordsLearned)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        Text("學習準確率")
                        Spacer()
                        Text("\(Int(data.user.progress.accuracy * 100))%")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("連續學習天數")
                        Spacer()
                        Text("\(data.user.streak) 天")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("成就") {
                    ForEach(data.achievements, id: \.id) { achievement in
                        HStack {
                            Image(systemName: achievement.icon)
                                .foregroundColor(achievement.unlocked ? .yellow : .gray)
                            VStack(alignment: .leading) {
                                Text(achievement.name)
                                    .font(.headline)
                                Text(achievement.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if achievement.unlocked {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Section("設定") {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        Text("每日目標")
                        Spacer()
                        Text("\(data.user.settings.dailyGoal) 個單字")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        Text("通知提醒")
                        Spacer()
                        Text(data.user.settings.notifications ? "開啟" : "關閉")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.purple)
                        Text("音效")
                        Spacer()
                        Text(data.user.settings.soundEnabled ? "開啟" : "關閉")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("個人資料")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.yellow)
            Text(achievement.name)
                .font(.caption)
                .fontWeight(.semibold)
            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120, height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryCard: View {
    let category: VocabularyCategory
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text(category.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(category.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Text("\(category.wordCount) 個單字")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(category.difficulty)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(getDifficultyColor(category.difficulty).opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "beginner": return .green
        case "intermediate": return .orange
        case "advanced": return .red
        default: return .gray
        }
    }
}

// MARK: - Word Detail View
struct WordDetailView: View {
    let word: Word
    @State private var showTranslation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Word Header
                VStack(spacing: 12) {
                    Text(word.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(word.phonetic)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
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
                            .background(getDifficultyColor(word.difficulty).opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    Button(action: {
                        // Play pronunciation
                    }) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Definitions
                VStack(alignment: .leading, spacing: 16) {
                    Text("定義")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(word.definitions.indices, id: \.self) { index in
                        let definition = word.definitions[index]
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(index + 1). \(definition.definition)")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("例句:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                                
                                Text(definition.example)
                                    .font(.body)
                                    .italic()
                                    .foregroundColor(.primary)
                                
                                if showTranslation {
                                    Text(definition.exampleTranslation)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.leading, 12)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    Button(action: {
                        showTranslation.toggle()
                    }) {
                        Text(showTranslation ? "隱藏翻譯" : "顯示翻譯")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // Synonyms and Antonyms
                if !word.synonyms.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("同義字")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(word.synonyms, id: \.self) { synonym in
                                    Text(synonym)
                                        .font(.body)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                if !word.antonyms.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("反義字")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(word.antonyms, id: \.self) { antonym in
                                    Text(antonym)
                                        .font(.body)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Tags
                if !word.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("標籤")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(word.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(6)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Learning Status
                VStack(alignment: .leading, spacing: 8) {
                    Text("學習狀態")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("已學習: \(word.userStatus.learned ? "是" : "否")")
                                .font(.body)
                            Text("複習次數: \(word.userStatus.reviewCount)")
                                .font(.body)
                            Text("正確次數: \(word.userStatus.correctCount)")
                                .font(.body)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("收藏: \(word.userStatus.starred ? "是" : "否")")
                                .font(.body)
                            Text("上次複習: \(word.userStatus.lastReviewed)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("下次複習: \(word.userStatus.nextReview)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(word.word)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Toggle star
                }) {
                    Image(systemName: word.userStatus.starred ? "heart.fill" : "heart")
                        .foregroundColor(word.userStatus.starred ? .red : .gray)
                }
            }
        }
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "beginner": return .green
        case "intermediate": return .orange
        case "advanced": return .red
        default: return .gray
        }
    }
}

// MARK: - Word List View
struct WordListView: View {
    @EnvironmentObject var data: VocabularyData
    let category: VocabularyCategory
    @State private var searchText = ""
    @State private var sortOption = 0
    
    var filteredWords: [Word] {
        let categoryWords = data.words.filter { $0.categoryId == category.id }
        let searchFiltered = searchText.isEmpty ? categoryWords : categoryWords.filter {
            $0.word.localizedCaseInsensitiveContains(searchText) ||
            $0.definitions.contains { $0.definition.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch sortOption {
        case 0: return searchFiltered.sorted { $0.word < $1.word }
        case 1: return searchFiltered.sorted { $0.difficulty < $1.difficulty }
        case 2: return searchFiltered.sorted { $0.userStatus.learned && !$1.userStatus.learned }
        default: return searchFiltered
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter
                HStack {
                    TextField("搜尋單字...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("排序", selection: $sortOption) {
                        Text("字母").tag(0)
                        Text("難度").tag(1)
                        Text("狀態").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
                .padding()
                
                // Word List
                List(filteredWords, id: \.id) { word in
                    NavigationLink(destination: WordDetailView(word: word)) {
                        WordRowView(word: word)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WordRowView: View {
    let word: Word
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(word.phonetic)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let firstDefinition = word.definitions.first {
                    Text(firstDefinition.definition)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Text(word.partOfSpeech)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(word.difficulty)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(getDifficultyColor(word.difficulty).opacity(0.2))
                        .cornerRadius(4)
                }
                
                HStack {
                    if word.userStatus.learned {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    if word.userStatus.starred {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "beginner": return .green
        case "intermediate": return .orange
        case "advanced": return .red
        default: return .gray
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var data: VocabularyData
    @State private var dailyGoal = 20
    @State private var notifications = true
    @State private var soundEnabled = true
    @State private var selectedTheme = 0
    
    let themes = ["自動", "淺色", "深色"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("學習設定") {
                    HStack {
                        Text("每日目標")
                        Spacer()
                        Stepper("\(dailyGoal) 個單字", value: $dailyGoal, in: 1...100)
                    }
                    
                    Toggle("推播通知", isOn: $notifications)
                    Toggle("音效", isOn: $soundEnabled)
                }
                
                Section("外觀") {
                    Picker("主題", selection: $selectedTheme) {
                        ForEach(0..<themes.count, id: \.self) { index in
                            Text(themes[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("資料") {
                    Button("匯出學習記錄") {
                        // Export data
                    }
                    
                    Button("匯入單字庫") {
                        // Import vocabulary
                    }
                    
                    Button("清除所有資料") {
                        // Clear data
                    }
                    .foregroundColor(.red)
                }
                
                Section("關於") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("意見回饋") {
                        // Feedback
                    }
                    
                    Button("隱私政策") {
                        // Privacy policy
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
