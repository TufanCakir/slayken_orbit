//
//  RootView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var themeStore: ThemeStore
    @AppStorage("has_seen_onboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                mainContent
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            }
        }
        .preferredColorScheme(themeStore.preferredColorScheme)
    }

    private var mainContent: some View {
        NavigationStack {
            TabView {
                BrowserView()
                    .tabItem {
                        Label(
                            "Browser",
                            systemImage: "globe.europe.africa.fill"
                        )
                    }

                AccountView()
                    .tabItem {
                        Label(
                            "Account",
                            systemImage: "person.crop.circle"
                        )
                    }
            }

        }
    }
}
