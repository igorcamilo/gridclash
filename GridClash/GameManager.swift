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
    var isMultiplayerRestrictedAlertPresented = false

    override init() {
        super.init()
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
        let viewController = GKTurnBasedMatchmakerViewController(matchRequest: request)
        viewController.turnBasedMatchmakerDelegate = self
        present(viewController)
    }
}

extension GameManager: GKLocalPlayerListener {}

extension GameManager: @preconcurrency GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        #if os(macOS)
        viewController.dismiss(self)
        #endif
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: any Error) {}
}

#if os(macOS)
private extension GameManager {
    func present(_ viewController: NSViewController) {
        guard let window = NSApplication.shared.windows.first else {
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
    func present(_ viewController: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first else {
            logger.error("Could not find scene")
            return
        }
        guard let windowScene = scene as? UIWindowScene else {
            logger.error("Could not find window scene")
            return
        }
        guard let window = windowScene.windows.first else {
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
