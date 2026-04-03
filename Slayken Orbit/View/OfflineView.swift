//
//  OfflineView.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 58, weight: .black))
                    .foregroundStyle(.primary)
                    .frame(width: 110, height: 110)
                    .background(Color.white.opacity(0.08), in: Circle())

                VStack(spacing: 10) {
                    Text("Offline")
                        .font(
                            .system(size: 36, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.primary)

                    Text(
                        "Slayken Orbit benoetigt eine aktive Internetverbindung. Verbinde dein Geraet mit dem Internet, um die App zu starten."
                    )
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.78))
                }
            }
            .padding()
        }
    }
}

#Preview {
    OfflineView()
}
