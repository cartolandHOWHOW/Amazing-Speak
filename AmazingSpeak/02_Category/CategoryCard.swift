import SwiftUI

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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Text("\(category.wordCount) 個單字")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
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
