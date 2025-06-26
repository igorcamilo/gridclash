//
//  GameManager.swift
//  GridClash
//
//  Created by Igor Camilo on 25.06.25.
//  Copyright © 2025 Igor Camilo. All rights reserved.
//

import GameKit
import Observation
import os.log

private let logger = Logger(subsystem: "GridClash", category: "GameManager")

@Observable
@MainActor
final class GameManager: NSObject {
    var gameMatch: GameMatch?
    var isMultiplayerRestrictedAlertPresented = false

    @ObservationIgnored private var isAuthenticateCalled = false

    func authenticate() {
        logger.info("Authenticating Game Center")
        guard !isAuthenticateCalled else {
            logger.info("Game Center authentication already called")
            return
        }
        isAuthenticateCalled = true
        GKAccessPoint.shared.parentWindow = window
        GKAccessPoint.shared.isActive = true
        GKLocalPlayer.local.register(self)
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            logger.info("Game Center authentication handler called")
            guard let self else {
                logger.error("Self is nil in Game Center authentication handler")
                return
            }
            if let viewController {
                present(viewController)
            }
            if let error {
                logger.error("Error authenticating Game Center: \(error)")
            }
        }
    }

    func closeGame() {
        logger.info("Closing game")
        gameMatch = nil
    }

    func startGame() {
        logger.info("Starting single player game")
    }

    func startMultiplayerGame() {
        guard GKLocalPlayer.local.isAuthenticated else {
            logger.info("Game Center not authenticated, presenting authentication UI")
            GKAccessPoint.shared.trigger {
                logger.info("Authentication UI presented")
            }
            return
        }
        if GKLocalPlayer.local.isMultiplayerGamingRestricted {
            logger.info("Multiplayer gaming restricted")
            isMultiplayerRestrictedAlertPresented = true
            return
        }
        logger.info("Starting multiplayer game")
        let request = GKMatchRequest()
        request.maxPlayers = 2
        let viewController = GKTurnBasedMatchmakerViewController(matchRequest: request)
        viewController.turnBasedMatchmakerDelegate = self
        present(viewController)
    }
}

extension GameManager: GKLocalPlayerListener {}

extension GameManager: @preconcurrency GKTurnBasedEventListener {
    func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
        logger.info("Player \(player) requested a match with other players: \(playersToInvite)")
    }

    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        logger.info("Player received a turn event for match")
        if didBecomeActive {
            logger.info("Player is now active in the match")
            gameMatch = GameMatch(multiplayerMatch: match)
            return
        }
    }
}

extension GameManager: @preconcurrency GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        logger.info("Matchmaker view controller cancelled")
        #if os(macOS)
        viewController.dismiss(self)
        #else
        viewController.dismiss(animated: true)
        #endif
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: any Error) {
        logger.error("Matchmaker view controller failed: \(error)")
        #if os(macOS)
        viewController.dismiss(self)
        #else
        viewController.dismiss(animated: true)
        #endif
    }
}

#if os(macOS)
private extension GameManager {
    var window: NSWindow? {
        NSApplication.shared.windows.first
    }

    func present(_ viewController: NSViewController) {
        guard let window else {
            logger.error("Could not find window")
            return
        }
        guard let mainViewController = window.contentViewController else {
            logger.error("Could not find main view controller")
            return
        }
        mainViewController.presentAsSheet(viewController)
    }
}
#else
private extension GameManager {
    var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first else {
            logger.error("Could not find scene")
            return nil
        }
        guard let windowScene = scene as? UIWindowScene else {
            logger.error("Could not find window scene")
            return nil
        }
        return windowScene.windows.first
    }

    func present(_ viewController: UIViewController) {
        guard let window else {
            logger.error("Could not find window")
            return
        }
        guard let mainViewController = window.rootViewController else {
            logger.error("Could not find main view controller")
            return
        }
        mainViewController.present(viewController, animated: true)
    }
}
#endif
