//
//  ContentView.swift
//  GridClash
//
//  Created by Igor Camilo on 15.06.25.
//

import GridClash3D
import os.log
import RealityKit
import SwiftUI

private let logger = Logger(subsystem: "GridClash", category: "ContentView")

struct ContentView: View {
    @Bindable var gameManager: GameManager

    var body: some View {
        RealityView { content in
            do {
                let entity = try await Entity(named: "Main", in: gridClash3DBundle)
                content.add(entity)
            } catch {
                logger.error("Failed to load main entity: \(error)")
            }
        } update: { content in
            // Update
        } placeholder: {
            ProgressView()
        }
        #if os(iOS) || os(macOS)
        .realityViewCameraControls(.orbit)
        #endif
    }

    @ViewBuilder private var oldContent: some View {
        if let gameMatch = gameManager.gameMatch {
            GameMatchView(
                gameManager: gameManager,
                gameMatch: gameMatch
            )
        } else {
            mainMenu
        }
    }

    private var mainMenu: some View {
        VStack {
            Text("Welcome to Grid Clash!")
                .font(.largeTitle)
            Button("Single Player") {
                gameManager.startGame()
            }
            Button("Multiplayer") {
                gameManager.startMultiplayerGame()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .foregroundStyle(Color.primaryText)
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
