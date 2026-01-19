//
//  ChatService.swift
//  Codex Testing App
//
//  Created by chase morgan on 1/19/26.
//

import Foundation

final class ChatService {
    private let baseURL = URL(string: "http://localhost:3000")!
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func fetchMessages() async throws -> [ChatMessage] {
        let url = baseURL.appending(path: "messages")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode([ChatMessage].self, from: data)
    }

    func sendMessage(username: String, text: String) async throws -> ChatMessage {
        let url = baseURL.appending(path: "messages")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(NewMessageRequest(username: username, text: text))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(ChatMessage.self, from: data)
    }
}

private struct NewMessageRequest: Codable {
    let username: String
    let text: String
}
