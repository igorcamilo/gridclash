//
//  GameMatchView.swift
//  GridClash
//
//  Created by Igor Camilo on 26.06.25.
//  Copyright © 2025 Igor Camilo. All rights reserved.
//

import SwiftUI

struct GameMatchView: View {
    let gameManager: GameManager
    let gameMatch: GameMatch

    var body: some View {
        VStack {
            Text("Game Match")
            Text("Is My Turn: \(gameMatch.isMyTurn)")
            Button("End Turn") {
                gameMatch.endTurn()
            }
            .disabled(!gameMatch.isMyTurn)
            Button("Back to Main Menu") {
                gameManager.closeGame()
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    GameMatchView(
        gameManager: GameManager(),
        gameMatch: GameMatch(multiplayerMatch: nil)
    )
}
