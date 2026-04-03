//
//  AppTheme.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct AppTheme: Identifiable, Decodable, Equatable {
    let id: String
    let title: String
    let appearance: AppearanceMode

    enum AppearanceMode: String, Decodable {
        case system
        case light
        case dark

        var colorScheme: ColorScheme? {
            switch self {
            case .system:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }

        var description: String {
            switch self {
            case .system:
                return "Folgt automatisch dem System."
            case .light:
                return "Helle Darstellung."
            case .dark:
                return "Dunkle Darstellung."
            }
        }
    }
}
