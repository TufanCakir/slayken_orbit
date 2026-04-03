//
//  BrowserTabsMenuView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct BrowserTabsMenuView: View {
    let tabs: [BrowserTab]
    let selectedTabID: BrowserTab.ID?
    let onSelect: (BrowserTab.ID) -> Void
    let onClose: (BrowserTab.ID) -> Void
    let onAdd: () -> Void

    var body: some View {
        Menu {
            Button(action: onAdd) {
                Label("Neuer Tab", systemImage: "plus")
            }

            if !tabs.isEmpty {
                Divider()
            }

            ForEach(tabs) { tab in
                Button {
                    onSelect(tab.id)
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tab.title)
                                .lineLimit(1)
                            Text(
                                tab.isShowingStartPage
                                    ? "Startseite"
                                    : (tab.currentURL?.host ?? "Seite")
                            )
                            .font(.caption2)
                        }
                    } icon: {
                        Image(
                            systemName: tab.id == selectedTabID
                                ? "checkmark.circle.fill" : "square.on.square"
                        )
                    }
                }

                Button(role: .destructive) {
                    onClose(tab.id)
                } label: {
                    Label("Tab schliessen", systemImage: "xmark")
                }
            }
        } label: {
            Image(systemName: "square.on.square")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}
