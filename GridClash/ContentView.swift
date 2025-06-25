//
//  ContentView.swift
//  GridClash
//
//  Created by Igor Camilo on 15.06.25.
//

import SwiftUI

struct ContentView: View {
    @Bindable var gameManager: GameManager

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
        }
        .padding()
        .buttonStyle(.borderedProminent)
        .alert(
            "Multiplayer Disabled",
            isPresented: $gameManager.isMultiplayerRestrictedAlertPresented
        ) {
            Button("OK") {}
        }
    }
}

#Preview {
    ContentView(gameManager: GameManager())
}
