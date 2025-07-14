//
//  QuickActionCard.swift
//  MyVocab
//
//  Created by 戴老師環境 on 2025-07-13.
//
import SwiftUI

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
