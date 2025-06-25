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
    private(set) var isAuthenticated = false

    override init() {
        super.init()
        GKAccessPoint.shared.isActive = true
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
                isAuthenticated = false
                logger.error("Error authenticating Game Center: \(error)")
            } else {
                isAuthenticated = true
                logger.info("Game Center authenticated")
            }
        }
    }

    func startGame() {
        logger.info("Starting single player game")
    }

    func startMultiplayerGame() {
        logger.info("Starting multiplayer game")
    }

    #if os(macOS)
    private func present(_ viewController: NSViewController) {
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
    #else
    private func present(_ viewController: UIViewController) {
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
    #endif
}
