//
//  SavedPage.swift
//  Slayken Orbit
//
//  Created by Tufan Cakir on 03.04.26.
//

import Foundation

struct SavedPage: Identifiable, Codable, Equatable {
    enum Kind: String, Codable {
        case link
        case html
    }

    let id: UUID
    let title: String
    let kind: Kind
    let link: String?
    let html: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        kind: Kind,
        link: String? = nil,
        html: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.link = link
        self.html = html
        self.createdAt = createdAt
    }
}
