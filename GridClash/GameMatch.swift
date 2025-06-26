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
    var isMyTurn = false
    private var multiplayerMatch: GKTurnBasedMatch?

    init(multiplayerMatch: GKTurnBasedMatch?) {
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
                    let _: Void = try await withCheckedThrowingContinuation { continuation in
                        // As of Xcode 16.4, the async version of this method creates warnings
                        multiplayerMatch.endTurn(
                            withNextParticipants: nextParticipants,
                            turnTimeout: 60,
                            match: Data()
                        ) { error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume()
                            }
                        }
                    }
                }
            } catch {
                logger.error("Error ending turn: \(error)")
                isMyTurn = multiplayerMatch?.currentParticipant?.player == GKLocalPlayer.local
            }
        }
    }

    func updateMultiplayerMatch(_ match: GKTurnBasedMatch) {
        guard multiplayerMatch?.matchID == match.matchID else {
            return
        }
        isMyTurn = match.currentParticipant?.player == GKLocalPlayer.local
        multiplayerMatch = match
    }
}
