//
//  BrowserStartView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct BrowserStartView: View {
    @Binding var searchText: String

    let isPrivateMode: Bool
    let onSubmit: () -> Void
    let onShowAddPage: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {

                VStack(spacing: 12) {
                    Text("SLAYKEN ORBIT")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.primary)

                    Text("Suche im Orbit oder gib direkt eine URL ein.")
                        .font(.footnote).bold()
                        .foregroundStyle(.primary)
                }

                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField(
                            "Website Suchen oder Öffnen",
                            text: $searchText
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit(onSubmit)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .buttonStyle(.plain)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            QuickSearchChip(
                                title: "Google",
                                query: "google.com",
                                searchText: $searchText,
                                onSubmit: onSubmit
                            )
                            QuickSearchChip(
                                title: "YouTube",
                                query: "youtube.com",
                                searchText: $searchText,
                                onSubmit: onSubmit
                            )
                            QuickSearchChip(
                                title: "Slayken Store",
                                query: "tufancakir.com",
                                searchText: $searchText,
                                onSubmit: onSubmit
                            )
                            QuickSearchChip(
                                title: "Slayken",
                                query: "slayken.com",
                                searchText: $searchText,
                                onSubmit: onSubmit
                            )
                            QuickSearchChip(
                                title: "Valtasia",
                                query: "valtasiagame.com",
                                searchText: $searchText,
                                onSubmit: onSubmit
                            )
                            QuickSearchChip(
                                title: "GitHub",
                                query: "github.com",
                                searchText: $searchText,
                                onSubmit: onSubmit
                            )
                            QuickSearchChip(
                                title: "Bing",
                                query: "bing.com",
                                searchText: $searchText,
                                onSubmit: onSubmit
                            )
                        }
                    }

                    if !isPrivateMode {
                        Button(action: onShowAddPage) {
                            Label(
                                "Eigene Seite hinzufuegen",
                                systemImage: "doc.badge.plus"
                            )
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 22,
                                    style: .continuous
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
    }
}

private struct QuickSearchChip: View {
    let title: String
    let query: String
    @Binding var searchText: String
    let onSubmit: () -> Void

    var body: some View {

        Button(title) {
            searchText = query
            onSubmit()
        }
        .foregroundStyle(.primary).bold()
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.capsule)
    }
}

#Preview {
    BrowserStartView(
        searchText: .constant(""),
        isPrivateMode: false,
        onSubmit: {},
        onShowAddPage: {}
    )
}
