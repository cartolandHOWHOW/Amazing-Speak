import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    
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
        .environmentObject(dataManager)
    }
}






