//
//  Untitled.swift
//  MyVocab
//
//  Created by 戴老師環境 on 2025-07-13.
//
import SwiftUI

// MARK: - Data Manager
class DataManager: ObservableObject {
    @Published var app: AppData // 儲存所有資料的根物件
    @Published var isLoading = true
    @Published var loadError: String?
    
    private let jsonFileName = "zdata.json"
    private var documentDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var dataFileURL: URL {
        documentDirectoryURL.appendingPathComponent(jsonFileName)
    }
    
    init() {
        // 初始化一個預設的 appData
        // 這些資料僅用於初始建構 AppData 物件，實際資料會從檔案載入或複製
        self.app = AppData(
            user: User(
                id: "user_12345",
                name: "使用者",
                email: "user@example.com",
                level: "初學者",
                totalScore: 0,
                streak: 0,
                settings: UserSettings(dailyGoal: 20, notifications: true, soundEnabled: true, theme: "light"),
                progress: UserProgress(wordsLearned: 0, wordsReviewed: 0, accuracy: 0.0, lastStudyDate: "")
            ),
            categories: [], // 預設為空，等待載入
            words: [],      // 預設為空，等待載入
            //achievements: [] // 預設為空，等待載入
        )
        
        loadInitialData()
    }
    
    func loadInitialData() {
        
        print(dataFileURL.path)
        
        // 檢查 Document 目錄是否存在 zdata.json
        if FileManager.default.fileExists(atPath: dataFileURL.path) {
            print("zdata.json 檔案已存在於 Document 目錄，從 Document 載入。")
            loadDataFromDocument()
        } else {
            print("zdata.json 檔案不存在於 Document 目錄，從 Bundle 複製並載入。")
            copyBundleDataToDocument()
        }
    }
    
    // MARK: - Data Operations
    
    // 從 Document 目錄載入資料
    private func loadDataFromDocument() {
        do {
            let data = try Data(contentsOf: dataFileURL)
            let decodedData = try JSONDecoder().decode(AppData.self, from: data)
            DispatchQueue.main.async {
                self.app = decodedData
                self.isLoading = false
                self.loadError = nil
                print(" user 資料已成功從 Document 載入。")
            }
        } catch {
            DispatchQueue.main.async {
                self.loadError = "從 Document 載入資料失敗: \(error.localizedDescription)"
                self.isLoading = false
                print("錯誤: 從 Document 載入資料失敗: \(error)") // 印出完整的 error 物件
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("解碼錯誤：找不到鍵 '\(key.stringValue)'。上下文: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("解碼錯誤：找不到類型 '\(type)' 的值。上下文: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("解碼錯誤：類型不匹配，預期 \(type)。上下文: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("解碼錯誤：資料損壞。上下文: \(context.debugDescription)")
                    @unknown default:
                        print("未知的解碼錯誤")
                    }
                }
            }
        }
    }
    
    // 將 Bundle 中的 zdata.json 複製到 Document 目錄
    private func copyBundleDataToDocument() {
        
        // 使用小數點 "." 作為分隔符號
        guard let fileNameWithoutExtension = jsonFileName.components(separatedBy: ".").first else {
            print("無法提取檔名（可能沒有小數點）")
            return // 如果無法提取，則直接返回，不執行後續程式碼
        }
        
        guard let bundleURL = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: "json") else {
            DispatchQueue.main.async {
                self.loadError = "找不到 Bundle 中的 " + self.jsonFileName + " 檔案。"
                self.isLoading = false
                print("錯誤: 找不到 Bundle 中的" + self.jsonFileName + "檔案。")
            }
            return
        }
        
        do {
            try FileManager.default.copyItem(at: bundleURL, to: dataFileURL)
            print("zdata.json 已成功從 Bundle 複製到 Document 目錄。")
            loadDataFromDocument() // 複製成功後，從 Document 載入資料
        } catch {
            DispatchQueue.main.async {
                self.loadError = "複製 Bundle 資料到 Document 失敗: \(error.localizedDescription)"
                self.isLoading = false
                print("錯誤: 複製 Bundle 資料到 Document 失敗: \(error.localizedDescription)")
            }
        }
    }
    
    // 將當前 appData 儲存到 Document 目錄
    func saveDataToDocument() {
        DispatchQueue.global(qos: .background).async {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // 為了可讀性，實際部署可移除
                let data = try encoder.encode(self.app)
                try data.write(to: self.dataFileURL)
                print("資料已成功儲存到 Document 目錄。")
                DispatchQueue.main.async {
                    self.loadError = nil // 清除之前的錯誤訊息
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadError = "儲存資料到 Document 失敗: \(error.localizedDescription)"
                    print("錯誤: 儲存資料到 Document 失敗: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Public Data Modification Methods (範例)
    // 您可以在這裡添加更多方法來修改 appData 中的特定部分
    
    func updateUser(_ updatedUser: User) {
        self.app.user = updatedUser
        saveDataToDocument() // 資料變更後自動儲存
    }
    
    func updateWordStatus(for wordId: String, newStatus: UserWordStatus) {
        if let index = app.words.firstIndex(where: { $0.id == wordId }) {
            app.words[index].userStatus = newStatus
            saveDataToDocument()
        } else {
            print("錯誤: 找不到 ID 為 \(wordId) 的單字來更新狀態。")
        }
    }
    
    
    //       func unlockAchievement(achievementId: String, unlockDate: String) {
    //           if let index = app.achievements.firstIndex(where: { $0.id == achievementId }) {
    //               appData.achievements[index].unlocked = true
    //               appData.achievements[index].unlockedDate = unlockDate
    //               saveDataToDocument()
    //           } else {
    //               print("錯誤: 找不到 ID 為 \(achievementId) 的成就來解鎖。")
    //           }
    //       }
    
    // 您可以根據需求添加更多如：
    // func addWord(_ newWord: Word)
    // func deleteWord(id: String)
    // func updateCategory(_ updatedCategory: VocabularyCategory)
    
}
