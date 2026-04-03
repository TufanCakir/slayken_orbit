//
//  ThemeStore.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class ThemeStore: ObservableObject {
    @Published private(set) var themes: [AppTheme] = []
    @Published var selectedThemeID: String {
        didSet {
            userDefaults.set(selectedThemeID, forKey: selectedThemeKey)
        }
    }

    private let selectedThemeKey = "selected_theme_id"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.selectedThemeID =
            userDefaults.string(forKey: selectedThemeKey) ?? "system"
        loadThemes()
        if selectedTheme == nil {
            selectedThemeID = themes.first?.id ?? "system"
        }
    }

    var selectedTheme: AppTheme? {
        themes.first(where: { $0.id == selectedThemeID })
    }

    var preferredColorScheme: ColorScheme? {
        selectedTheme?.appearance.colorScheme
    }

    func selectTheme(_ theme: AppTheme) {
        selectedThemeID = theme.id
    }

    private func loadThemes() {
        guard
            let url = Bundle.main.url(
                forResource: "Themes",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let decodedThemes = try? JSONDecoder().decode(
                [AppTheme].self,
                from: data
            )
        else {
            themes = fallbackThemes
            return
        }

        themes = decodedThemes
    }

    private var fallbackThemes: [AppTheme] {
        [
            AppTheme(id: "system", title: "System", appearance: .system),
            AppTheme(id: "light", title: "Light", appearance: .light),
            AppTheme(id: "dark", title: "Dark", appearance: .dark),
        ]
    }
}
