//
//  ContentView.swift
//  GridClash
//
//  Created by Igor Camilo on 15.06.25.
//

import SwiftUI

struct ContentView: View {
    @Environment(GameManager.self) private var gameManager

    var body: some View {
        VStack {
            Text("Welcome to Grid Clash!")
                .font(.title)
            Button("Single Player") {
                gameManager.startGame()
            }
            Button("Multiplayer") {
                gameManager.startMultiplayerGame()
            }
            .disabled(!gameManager.initialized)
        }
        .padding()
        .buttonStyle(.borderedProminent)
        .task {
            gameManager.initialize()
        }
    }
}

#Preview {
    ContentView()
}
