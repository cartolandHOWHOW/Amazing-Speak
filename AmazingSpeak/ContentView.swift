//
//  ContentView.swift
//  AmazingSpeak
//
//  Created by max on 2025/7/10.
//

import SwiftUI

struct ContentView: View {
    @State private var showTest = false
    @State private var bgIndex: Int = 0
    let bgImages = ["ForMenu", "ForMenu02", "ForMenu03", "ForMenu04"]
    let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    
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
                    showTest = true
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
                .sheet(isPresented: $showTest) {
                    TestView()
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

#Preview {
    ContentView()
}
