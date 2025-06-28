//
//  GameMatch.swift
//  GridClash
//
//  Created by Igor Camilo on 26.06.25.
//  Copyright © 2025 Igor Camilo. All rights reserved.
//

import GameKit
import Observation
import os.log

private let logger = Logger(subsystem: "GridClash", category: "GameMatch")

@Observable
@MainActor
final class GameMatch {
    let multiplayerMatchID: String?

    var board = [BoardSlot](repeating: .empty, count: 9)
    var isErrorAlertPresented = false
    var isMyTurn = false
    var localPlayerIndex: Int?

    init(multiplayerMatchID: String?) {
        self.multiplayerMatchID = multiplayerMatchID
    }

    nonisolated func endMatch() {
        logger.info("End match")
        Task {
            do {
                if let multiplayerMatchID {
                    logger.info("End multiplayer match")
                    let multiplayerMatch = try await GKTurnBasedMatch.load(
                        withID: multiplayerMatchID
                    )
                    for participant in multiplayerMatch.participants {
                        if participant.player == GKLocalPlayer.local {
                            participant.matchOutcome = .won
                        } else {
                            participant.matchOutcome = .lost
                        }
                    }
                    try await multiplayerMatch.endMatchInTurn(
                        withMatch: Data(board.map(\.rawValue))
                    )
                }
            } catch {
                logger.error("Error ending match: \(error)")
                await MainActor.run { isErrorAlertPresented = true }
            }
        }
    }

    nonisolated func playTurn(index: Int) {
        logger.info("Play turn index: \(index)")
        Task {
            do {
                let slot = await board[index]
                guard slot == .empty else {
                    logger.info("Invalid turn: slot is not empty")
                    return
                }
                switch await localPlayerIndex {
                case 0:
                    await MainActor.run { board[index] = .player1 }
                case 1:
                    await MainActor.run { board[index] = .player2 }
                default:
                    throw GameMatchError.invalidLocalPlayerIndex
                }
                await MainActor.run { isMyTurn = false }
                if let multiplayerMatchID {
                    logger.info("End multiplayer turn")
                    let multiplayerMatch = try await GKTurnBasedMatch.load(
                        withID: multiplayerMatchID
                    )
                    let nextParticipants = multiplayerMatch.participants.filter {
                        $0.player != GKLocalPlayer.local
                    }
                    try await multiplayerMatch.endTurn(
                        withNextParticipants: nextParticipants,
                        turnTimeout: 3600,
                        match: Data(board.map(\.rawValue))
                    )
                }
            } catch {
                logger.error("Error ending turn: \(error)")
                await MainActor.run { isErrorAlertPresented = true }
            }
        }
    }

    func updateMultiplayerMatch(_ match: GKTurnBasedMatch) {
        logger.info("Updating multiplayer match")
        guard multiplayerMatchID == match.matchID else {
            logger.info("Ignoring match update: wrong match ID")
            return
        }
        Task {
            if let data = try? await match.loadMatchData(), data.count == 9 {
                board = data.map { BoardSlot(rawValue: $0) ?? .empty }
            } else {
                board = [BoardSlot](repeating: .empty, count: 9)
            }
            isMyTurn = match.currentParticipant?.player == GKLocalPlayer.local
            localPlayerIndex = match.participants.firstIndex {
                $0.player == GKLocalPlayer.local
            }
            logger.info("Updated multiplayer match, board: \(self.board)")
        }
    }
}

enum GameMatchError: Error {
    case invalidLocalPlayerIndex
}
