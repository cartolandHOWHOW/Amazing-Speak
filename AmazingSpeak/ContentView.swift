import SwiftUI
import AVFoundation

// MARK: - Data Models
struct User: Codable {
    let id: String
    let name: String
    let email: String
    let level: String
    var totalScore: Int
    var streak: Int
    var settings: UserSettings
    var progress: UserProgress
}

struct UserSettings: Codable {
    var dailyGoal: Int
    var notifications: Bool
    var soundEnabled: Bool
    var theme: String
}

struct UserProgress: Codable {
    var wordsLearned: Int
    var wordsReviewed: Int
    var accuracy: Double
    var lastStudyDate: String
}

struct VocabularyCategory: Codable {
    let id: String
    let name: String
    let description: String
    let color: String
    let icon: String
    let wordCount: Int
    let difficulty: String
}

struct Word: Codable {
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

struct Definition: Codable {
    let definition: String
    let example: String
    let exampleTranslation: String
}

struct UserWordStatus: Codable {
    var learned: Bool
    var starred: Bool
    var reviewCount: Int
    var correctCount: Int
    var lastReviewed: String?
    var nextReview: String?
}

struct Achievement: Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: AchievementRequirement
    let unlocked: Bool
    let unlockedDate: String?
}

struct AchievementRequirement: Codable {
    let type: String
    let value: Int
}
// MARK: - JSON Data Structure
struct VocabularyData: Codable {
    let user: User
    let categories: [VocabularyCategory]
    let words: [Word]
    let achievements: [Achievement]
}

// MARK: - Data Manager
class DataManager: ObservableObject {
    @Published var user: User
    @Published var categories: [VocabularyCategory] = []
    @Published var words: [Word] = []
    @Published var achievements: [Achievement] = []
    @Published var isLoading = true
    @Published var loadError: String?
    
    init() {
        // Initialize with default user data
        self.user = User(
            id: "user_12345",
            name: "使用者",
            email: "user@example.com",
            level: "初學者",
            totalScore: 0,
            streak: 0,
            settings: UserSettings(dailyGoal: 20, notifications: true, soundEnabled: true, theme: "light"),
            progress: UserProgress(wordsLearned: 0, wordsReviewed: 0, accuracy: 0.0, lastStudyDate: "")
        )
        
        loadDataFromJSON()
    }
    
    func loadDataFromJSON() {
        guard let url = Bundle.main.url(forResource: "zdata", withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = "找不到 zdata.json 檔案"
                self.isLoading = false
            }
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let vocabularyData = try JSONDecoder().decode(VocabularyData.self, from: data)
            
            DispatchQueue.main.async {
                self.user = vocabularyData.user
                self.categories = vocabularyData.categories
                self.words = vocabularyData.words
                self.achievements = vocabularyData.achievements
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.loadError = "讀取資料時發生錯誤: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Data Operations
    func updateUser(_ updatedUser: User) {
        self.user = updatedUser
        saveDataToJSON()
    }
    
    func updateWordStatus(_ wordId: String, status: UserWordStatus) {
        if let index = words.firstIndex(where: { $0.id == wordId }) {
            words[index].userStatus = status
            saveDataToJSON()
        }
    }
    
    func addWord(_ word: Word) {
        words.append(word)
        saveDataToJSON()
    }
    
    func removeWord(_ wordId: String) {
        words.removeAll { $0.id == wordId }
        saveDataToJSON()
    }
    
    private func saveDataToJSON() {
        let vocabularyData = VocabularyData(
            user: user,
            categories: categories,
            words: words,
            achievements: achievements
        )
        
        do {
            let data = try JSONEncoder().encode(vocabularyData)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let saveURL = documentsPath.appendingPathComponent("zdata2.json")
            try data.write(to: saveURL)
        } catch {
            print("保存資料時發生錯誤: \(error.localizedDescription)")
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if dataManager.isLoading {
                LoadingView()
            } else if let error = dataManager.loadError {
                ErrorView(error: error) {
                    dataManager.loadDataFromJSON()
                }
            } else {
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
            }
        }
        .environmentObject(dataManager)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("載入中...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("載入失敗")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("重試") {
                retry()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 120, height: 44)
            .background(Color.blue)
            .cornerRadius(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}


// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("歡迎回來，\(dataManager.user.name)!")
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
                            Text("\(dataManager.user.streak)")
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
                                Text("目標：\(dataManager.user.settings.dailyGoal) 個單字")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                let progress = Double(dataManager.user.progress.wordsLearned % dataManager.user.settings.dailyGoal) / Double(dataManager.user.settings.dailyGoal)
                                ProgressView(value: progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                
                                Text("\(dataManager.user.progress.wordsLearned % dataManager.user.settings.dailyGoal)/\(dataManager.user.settings.dailyGoal)")
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
                        StatCard(title: "已學習", value: "\(dataManager.user.progress.wordsLearned)", icon: "book", color: .green)
                        StatCard(title: "準確率", value: "\(Int(dataManager.user.progress.accuracy * 100))%", icon: "target", color: .blue)
                        StatCard(title: "總分", value: "\(dataManager.user.totalScore)", icon: "star", color: .orange)
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
                                ForEach(dataManager.achievements.filter { $0.unlocked }, id: \.id) { achievement in
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

// MARK: - Category View
struct CategoryView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(dataManager.categories, id: \.id) { category in
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

// MARK: - Study View
struct StudyView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentWordIndex = 0
    @State private var showAnswer = false
    @State private var isCorrect: Bool?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !dataManager.words.isEmpty {
                    let word = dataManager.words[currentWordIndex]
                    
                    // Progress
                    ProgressView(value: Double(currentWordIndex + 1) / Double(dataManager.words.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                    
                    Text("\(currentWordIndex + 1) / \(dataManager.words.count)")
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
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("沒有可學習的單字")
                            .font(.headline)
                            .foregroundColor(.secondary)
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
        let word = dataManager.words[currentWordIndex]
        var updatedStatus = word.userStatus
        updatedStatus.reviewCount += 1
        
        if correct {
            updatedStatus.correctCount += 1
            updatedStatus.learned = true
        }
        
        dataManager.updateWordStatus(word.id, status: updatedStatus)
        
        showAnswer = false
        
        if currentWordIndex < dataManager.words.count - 1 {
            currentWordIndex += 1
        } else {
            currentWordIndex = 0
        }
    }
}

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
        gameWords = Array(dataManager.words.shuffled().prefix(min(10, dataManager.words.count)))
        currentQuestion = 0
        score = 0
        nextQuestion()
    }
    
    private func nextQuestion() {
        if currentQuestion < gameWords.count {
            let word = gameWords[currentQuestion]
            var options = [word.definitions[0].definition]
            
            // Add random wrong answers
            let otherWords = dataManager.words.filter { $0.id != word.id }.shuffled().prefix(3)
            options.append(contentsOf: otherWords.map { $0.definitions[0].definition })
            
            shuffledOptions = options.shuffled()
            selectedAnswer = nil
            showResult = false
        }
    }
    
    private func multipleChoiceView() -> some View {
        VStack(spacing: 20) {
            if !gameWords.isEmpty {
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
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("沒有可用的單字進行遊戲")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func checkAnswer(_ answer: String, correctAnswer: String) {
        showResult = true
        if answer == correctAnswer {
            score += 10
        }
    }
    
    private func endGame() {
        gameStarted = false
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

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(dataManager.user.name)
                                .font(.headline)
                            Text(dataManager.user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("等級: \(dataManager.user.level)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(dataManager.user.totalScore) 分")
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
                        Text("\(dataManager.user.progress.wordsLearned)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        Text("學習準確率")
                        Spacer()
                        Text("\(Int(dataManager.user.progress.accuracy * 100))%")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("連續學習天數")
                        Spacer()
                        Text("\(dataManager.user.streak) 天")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("成就") {
                    ForEach(dataManager.achievements, id: \.id) { achievement in
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
                        Text("\(dataManager.user.settings.dailyGoal) 個單字")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        Text("通知提醒")
                        Spacer()
                        Text(dataManager.user.settings.notifications ? "開啟" : "關閉")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.purple)
                        Text("音效")
                        Spacer()
                        Text(dataManager.user.settings.soundEnabled ? "開啟" : "關閉")
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
    @EnvironmentObject var dataManager: DataManager
    let category: VocabularyCategory
    @State private var searchText = ""
    @State private var sortOption = 0
    
    var filteredWords: [Word] {
        let categoryWords = dataManager.words.filter { $0.categoryId == category.id }
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
    @EnvironmentObject var dataManager: DataManager
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
