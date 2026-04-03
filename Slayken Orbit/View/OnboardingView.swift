//
//  OnboardingView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Willkommen in Slayken Orbit",
            subtitle:
                "Ein Browser, der schnell zwischen Fokus, Verlauf und Tabs wechselt.",
            systemImage: nil,
            imageName: "orbit_logo",
            accentColor: Color(red: 0.14, green: 0.42, blue: 0.86)
        ),
        OnboardingPage(
            title: "Tabs mit Vorschau",
            subtitle:
                "Behalte mehrere Seiten gleichzeitig im Blick und spring direkt in den richtigen Tab.",
            systemImage: "tablecells.fill",
            imageName: nil,
            accentColor: Color(red: 0.10, green: 0.63, blue: 0.58)
        ),
        OnboardingPage(
            title: "Privat bleibt privat",
            subtitle:
                "Im privaten Modus werden weder Verlauf noch Vorschauen gespeichert.",
            systemImage: "hand.raised.fill",
            imageName: nil,
            accentColor: Color(red: 0.95, green: 0.47, blue: 0.24)
        ),
    ]

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                topBar

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) {
                        index,
                        page in
                        pageCard(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator

                actionButton
            }
            .padding()
        }
    }

    private var topBar: some View {
        HStack {

            Spacer()

            Button("Überspringen") {
                onContinue()
            }
            .font(.headline).bold()
            .foregroundStyle(.primary)
        }
    }

    private func pageCard(_ page: OnboardingPage) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    Color(.systemBackground)
                )
                .overlay {
                    ZStack {
                        if let imageName = page.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        } else if let systemImage = page.systemImage {
                            Image(systemName: systemImage)
                                .font(.system(size: 200, weight: .black))
                                .foregroundStyle(.primary)
                        }
                    }
                }

            VStack(alignment: .leading, spacing: 12) {
                Text(page.title)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)

                Text(page.subtitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            featureList(for: page)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.white.opacity(0.08))
        .overlay {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }

    private func featureList(for page: OnboardingPage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(page.highlights, id: \.self) { highlight in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(page.accentColor)

                    Text(highlight)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? .white : .white.opacity(0.26))
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: currentPage)
    }

    private var actionButton: some View {
        Button(action: advance) {
            Text(currentPage == pages.count - 1 ? "Orbit starten" : "Weiter")
                .font(.headline.weight(.black))
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }

    private var background: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentPage += 1
            }
        } else {
            onContinue()
        }
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String?
    let imageName: String?
    let accentColor: Color

    var highlights: [String] {
        switch title {
        case "Willkommen in Slayken Orbit":
            return [
                "Schneller Start mit Suche oder direkter URL",
                "Klare Navigation zwischen Browser und Account",
            ]
        case "Tabs mit Vorschau":
            return [
                "Visuelle Karten für offene Seiten",
                "Direktes Wechseln und Schließen ohne Umwege",
            ]
        default:
            return [
                "Kein Verlauf im privaten Surfen",
                "Keine gespeicherten Vorschauen im Incognito-Modus",
            ]
        }
    }
}

#Preview {
    OnboardingView(onContinue: {})
}
