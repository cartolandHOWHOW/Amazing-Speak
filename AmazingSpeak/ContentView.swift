//
//  ContentView.swift
//  AmazingSpeak
//
//  Created by max on 2025/7/10.
//

import SwiftUI

struct ContentView: View {
    @State private var showTestSelection = false
    @State private var bgIndex: Int = 0
    let bgImages = ["ForMenu", "ForMenu02", "ForMenu03", "ForMenu04"]
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(bgImages[bgIndex])
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: bgIndex)
                .transition(.opacity)
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 32) {
                Text("WordTrainer")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                    .padding(.top, 32)
                Spacer()
                Button(action: {
                    showTestSelection = true
                }) {
                    Text("開始測驗")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(22)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .padding(.bottom, 60)
                .sheet(isPresented: $showTestSelection) {
                    TestSelectionView()
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onReceive(timer) { _ in
            bgIndex = (bgIndex + 1) % bgImages.count
        }
    }
}

struct TestSelectionView: View {
    let tests: [TestCard] = [
        TestCard(title: "A 開頭單字", image: "a.circle.fill", color: .blue, filter: { $0.english_word.first?.uppercased() == "A" }),
        TestCard(title: "B 開頭單字", image: "b.circle.fill", color: .purple, filter: { $0.english_word.first?.uppercased() == "B" })
    ]
    @Environment(\.dismiss) var dismiss
    @State private var showTestView = false
    @State private var selectedTest: TestCard? = nil
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    ForEach(tests) { test in
                        Button(action: {
                            selectedTest = test
                            showTestView = true
                        }) {
                            HStack {
                                Image(systemName: test.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                                    .padding(12)
                                    .background(test.color.opacity(0.15))
                                    .clipShape(Circle())
                                Text(test.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(test.color.opacity(0.18))
                                    .shadow(color: test.color.opacity(0.18), radius: 8, x: 0, y: 4)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
            }
            .navigationTitle("選擇單字分類")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("關閉") { dismiss() }
                }
            }
            .sheet(isPresented: $showTestView) {
                if let selected = selectedTest {
                    TestView(filter: selected.filter)
                }
            }
        }
    }
}

struct TestCard: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let color: Color
    let filter: (VocabularyItem) -> Bool
}

#Preview {
    ContentView()
}
