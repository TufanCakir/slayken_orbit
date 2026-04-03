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

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeStore)
        }
    }
}
