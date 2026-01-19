//
//  ChatMessage.swift
//  Codex Testing App
//
//  Created by chase morgan on 1/19/26.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: Int
    let username: String
    let text: String
    let timestamp: Date
}
