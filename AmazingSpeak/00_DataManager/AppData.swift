// MARK: - Data Models

// MARK: zdata.json
struct AppData: Codable {
    var user: User
    var categories: [VocabularyCategory]
    var words: [Word]
    //var achievements: [Achievement]
}

struct User: Codable {
    let id: String
    var name: String
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

// 讓 Category 遵循 Identifiable，方便 SwiftUI 使用
struct VocabularyCategory: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let color: String
    let icon: String
    let wordCount: Int
    let difficulty: String
}

struct Word: Codable, Identifiable {
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

// MARK: - Data Models
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

struct Achievement: Codable, Identifiable { // 讓 Achievement 遵循 Identifiable
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
