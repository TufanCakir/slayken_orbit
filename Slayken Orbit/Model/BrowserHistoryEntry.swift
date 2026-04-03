//
//  BrowserHistoryEntry.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import Foundation

struct BrowserHistoryEntry: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let url: URL
    let visitedAt: Date
    let isPrivate: Bool
}
