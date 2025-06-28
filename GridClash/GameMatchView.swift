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
                .font(.largeTitle)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .foregroundStyle(Color.primaryText)
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
                    slot.view
                        .font(.largeTitle)
                        .frame(width: 50, height: 50)
                }
                .tint(slot.color)
                .disabled(slot != .empty)
            }
        }
    }
}

private extension BoardSlot {
    var color: Color {
        switch self {
        case .empty: .accent
        case .player1: .player1
        case .player2: .player2
        }
    }

    @ViewBuilder var view: some View {
        switch self {
        case .empty: Image("")
        case .player1: Image(systemName: "xmark")
        case .player2: Image(systemName: "circle")
        }
    }
}

#Preview {
    GameMatchView(
        gameManager: GameManager(),
        gameMatch: GameMatch(
            board: [
                .empty, .player1, .player2,
                .player1, .player2, .empty,
                .player2, .empty, .player1
            ],
            multiplayerMatchID: nil
        )
    )
}
