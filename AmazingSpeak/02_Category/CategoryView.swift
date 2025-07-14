import SwiftUI

// MARK: - 2. Category View
struct CategoryView: View {
    @EnvironmentObject var data: DataManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(data.app.categories, id: \.id) { category in
                        // 將 CategoryCard 包裹在 NavigationLink 中
                        NavigationLink {
                            CategoryWordsView(selectedCategory: category) // 導航到新的視圖，並傳遞選定的分類
                        } label: {
                            CategoryCard(category: category)
                        }
                        // 移除 NavigationLink 的預設高亮效果，讓卡片看起來正常
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("分類")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}


extension Color {
    init?(hex: String) {
        let r, g, b, a: Double
        
        let start = hex.hasPrefix("#") ? hex.index(hex.startIndex, offsetBy: 1) : hex.startIndex
        var hexColor = String(hex[start...])
        
        if hexColor.count == 6 { // RGB
            hexColor += "FF" // 添加 Alpha 值
        }
        
        guard hexColor.count == 8 else { return nil }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        r = Double((hexNumber & 0xff000000) >> 24) / 255
        g = Double((hexNumber & 0x00ff0000) >> 16) / 255
        b = Double((hexNumber & 0x0000ff00) >> 8) / 255
        a = Double(hexNumber & 0x000000ff) / 255
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
