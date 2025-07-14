import SwiftUI

// MARK: - 1. Home View
struct HomeView: View {
    @EnvironmentObject var data: DataManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("歡迎回來，\(data.app.user.name)!")
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
                            Text("\(data.app.user.streak)")
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
                                Text("目標：\(data.app.user.settings.dailyGoal) 個單字")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                
                                
                                
                                ProgressView(value: Double(data.app.user.progress.wordsLearned % data.app.user.settings.dailyGoal) / Double(data.app.user.settings.dailyGoal))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                
                                Text("\(data.app.user.progress.wordsLearned % data.app.user.settings.dailyGoal)/\(data.app.user.settings.dailyGoal)")
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
                        StatCard(title: "已學習", value: "\(data.app.user.progress.wordsLearned)", icon: "book", color: .green)
                        StatCard(title: "準確率", value: "\(Int(data.app.user.progress.accuracy * 100))%", icon: "target", color: .blue)
                        StatCard(title: "總分", value: "\(data.app.user.totalScore)", icon: "star", color: .orange)
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
                            
                            // 導航到 LearnNewWordView
                            NavigationLink {
                                LearnNewWordView()
                            } label: {
                                QuickActionCard(title: "學習新單字", icon: "plus.circle", color: .blue)
                            }
                            
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
                        /*
                         ScrollView(.horizontal, showsIndicators: false) {
                         HStack(spacing: 12) {
                         ForEach(data.achievements.filter { $0.unlocked }, id: \.id) { achievement in
                         AchievementCard(achievement: achievement)
                         }
                         }
                         .padding(.horizontal)
                         }
                         */
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("單字大師")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
