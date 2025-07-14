//
//  CategoryWordsView.swift
//  MyVocab
//
//  Created by 戴老師環境 on 2025-07-13.
//


import SwiftUI

// MARK: - Category Words View (新增)
struct CategoryWordsView: View {
    @EnvironmentObject var data: DataManager
    let selectedCategory: VocabularyCategory // 接收從 CategoryView 傳遞過來的分類

    @State private var wordsForCategory: [Word] = [] // 儲存該分類下的單字

    var body: some View {
        VStack {
            if data.isLoading {
                ProgressView("載入單字中...")
            } else if data.loadError != nil {
                Text("載入錯誤：\(data.loadError ?? "未知錯誤")")
                    .foregroundColor(.red)
            } else if wordsForCategory.isEmpty {
                ContentUnavailableView {
                    Label("此分類暫無單字", systemImage: "xmark.octagon.fill")
                } description: {
                    Text("請稍後再回來看看！")
                }
            } else {
                // 這裡您可以設計單字學習或列表的 UI
                // 範例：顯示一個單字列表
                List {
                    Section(header: Text("分類：\(selectedCategory.name)")) {
                        ForEach(wordsForCategory) { word in
                            // 您可以將這裡替換成更複雜的單字學習卡片或導航到單字詳情頁
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(word.word)
                                        .font(.headline)
                                    Text(word.partOfSpeech)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                // 顯示學習狀態（例如，是否已學習）
                                Image(systemName: word.userStatus.learned ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(word.userStatus.learned ? .green : .gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(selectedCategory.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadWords) // 視圖出現時載入單字
    }

    private func loadWords() {
        // 從 DataManager 中篩選出屬於當前分類的單字
        self.wordsForCategory = data.app.words.filter { $0.categoryId == selectedCategory.id }
    }
}
