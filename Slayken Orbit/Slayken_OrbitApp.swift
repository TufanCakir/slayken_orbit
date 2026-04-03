//
//  Slayken_OrbitApp.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

@main
struct Slayken_OrbitApp: App {
    @StateObject private var themeStore = ThemeStore()
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            Group {
                if networkMonitor.isConnected {
                    RootView()
                } else {
                    OfflineView()
                }
            }
            .environmentObject(themeStore)
            .preferredColorScheme(themeStore.preferredColorScheme)
        }
    }
}
