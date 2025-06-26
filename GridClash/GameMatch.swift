//
//  GameMatch.swift
//  GridClash
//
//  Created by Igor Camilo on 26.06.25.
//  Copyright © 2025 Igor Camilo. All rights reserved.
//

@preconcurrency import GameKit
import Observation
import os.log

private let logger = Logger(subsystem: "GridClash", category: "GameMatch")

@Observable
@MainActor
final class GameMatch {
    var isMyTurn: Bool
    let multiplayerMatch: GKTurnBasedMatch?

    init(multiplayerMatch: GKTurnBasedMatch?) {
        self.isMyTurn = multiplayerMatch?.currentParticipant?.player == GKLocalPlayer.local
        self.multiplayerMatch = multiplayerMatch
    }

    func endTurn() {
        logger.info("End turn")
        Task {
            do {
                isMyTurn = false
                if let multiplayerMatch {
                    logger.info("End multiplayer turn")
                    let nextParticipants = multiplayerMatch.participants.filter {
                        $0.player != GKLocalPlayer.local
                    }
                    try await multiplayerMatch.endTurn(
                        withNextParticipants: nextParticipants,
                        turnTimeout: 60,
                        match: Data()
                    )
                }
            } catch {
                logger.error("Error ending turn: \(error)")
                isMyTurn = multiplayerMatch?.currentParticipant?.player == GKLocalPlayer.local
            }
        }
    }
}
