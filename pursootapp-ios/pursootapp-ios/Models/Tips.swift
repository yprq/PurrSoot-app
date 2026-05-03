//
//  Tips.swift
//  pursootapp-ios
//
//  Created by Yaprak Aslan on 3.05.2026.
//

struct Tip: Identifiable, Codable {
    let id: Int
    let title: String
    let subtitle: String
    let image_name: String?
    let content: String? // Bunu eklemeyi unutma!
}
