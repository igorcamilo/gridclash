//
//  GridClashApp.swift
//  GridClash
//
//  Created by Igor Camilo on 15.06.25.
//

import GameKit
import SwiftUI

@main
struct GridClashApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
#else
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
#endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = (notification.object as? NSApplication)?.keyWindow
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController {
                window?.contentViewController?.presentAsModalWindow(viewController)
            }
        }
        GKAccessPoint.shared.location = .topTrailing
        GKAccessPoint.shared.parentWindow = window
        GKAccessPoint.shared.isActive = true
    }
}
#else
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let window = (scene as? UIWindowScene)?.keyWindow
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController {
                window?.rootViewController?.present(viewController, animated: true)
            }
        }
        GKAccessPoint.shared.location = .topTrailing
        GKAccessPoint.shared.parentWindow = window
        GKAccessPoint.shared.isActive = true
    }
}
#endif
