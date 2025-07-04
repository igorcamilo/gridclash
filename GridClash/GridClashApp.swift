//
//  GridClashApp.swift
//  GridClash
//
//  Created by Igor Camilo on 15.06.25.
//

import SwiftUI

@main
struct GridClashApp: App {
    @State private var gameManager = GameManager()

    var body: some Scene {
        #if os(macOS) || os(visionOS)
        Window("Grid Clash", id: "MainWindow") {
            ContentView(gameManager: gameManager)
                .onAppear { gameManager.authenticate() }
        }
        #else
        WindowGroup("Grid Clash", id: "MainWindow") {
            ContentView(gameManager: gameManager)
                .onAppear { gameManager.authenticate() }
        }
        #endif
    }
}
