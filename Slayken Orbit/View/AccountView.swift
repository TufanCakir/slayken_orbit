//
//  AccountView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var themeStore: ThemeStore

    var body: some View {
        NavigationStack {
            Form {
                themeSection
                aboutSection
            }
        }
    }
}

// MARK: - Sections
extension AccountView {

    fileprivate var themeSection: some View {
        Section("Theme") {
            Menu {
                ForEach(themeStore.themes) { theme in
                    Button {
                        themeStore.selectTheme(theme)
                    } label: {
                        HStack {
                            Text(theme.title)
                            Spacer()

                            if themeStore.selectedTheme?.id == theme.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(themeStore.selectedTheme?.title ?? "Default")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        }
    }

    fileprivate var aboutSection: some View {
        Section("About") {
            InfoRow(title: "App Version", value: AppInfo.version)
            InfoRow(title: "Build", value: AppInfo.build)
            InfoRow(title: "System", value: AppInfo.system)
            InfoRow(title: "Device", value: AppInfo.device)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - App Info Helper
enum AppInfo {

    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "-"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
    }

    static var system: String {
        #if os(iOS)
            return "iOS \(UIDevice.current.systemVersion)"
        #elseif os(macOS)
            return
                "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
        #else
            return "Unknown OS"
        #endif
    }

    static var device: String {
        #if os(iOS)
            return UIDevice.current.model
        #else
            return "Mac"
        #endif
    }
}

// MARK: - Preview
#Preview {
    AccountView()
        .environmentObject(ThemeStore())
}
