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
    @Bindable var gameMatch: GameMatch

    var body: some View {
        VStack {
            Text("Game Match")
            Text("Is My Turn: \(gameMatch.isMyTurn)")
            Grid {
                gridRow(0..<3)
                gridRow(3..<6)
                gridRow(6..<9)
            }
            .disabled(!gameMatch.isMyTurn)
            Button("End Match") {
                gameMatch.endMatch()
            }
            .disabled(!gameMatch.isMyTurn)
            Button("Back to Main Menu") {
                gameManager.closeGame()
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
        .alert("Error", isPresented: $gameMatch.isErrorAlertPresented) {
            Button("Close Game") {
                gameManager.closeGame()
            }
        }
    }

    private func gridRow(_ range: Range<Int>) -> some View {
        GridRow {
            ForEach(range, id: \.self) { index in
                let slot = gameMatch.board[index]
                Button {
                    gameMatch.playTurn(index: index)
                } label: {
                    Text(verbatim: slot.title)
                        .frame(width: 50, height: 50)
                }
                .disabled(slot != .empty)
            }
        }
    }
}

private extension BoardSlot {
    var title: String {
        switch self {
        case .empty: ""
        case .player1: "⭕️"
        case .player2: "❌"
        }
    }
}

#Preview {
    GameMatchView(
        gameManager: GameManager(),
        gameMatch: GameMatch(multiplayerMatchID: nil)
    )
}
