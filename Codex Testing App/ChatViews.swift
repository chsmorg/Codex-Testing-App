//
//  ChatViews.swift
//  Codex Testing App
//
//  Created by chase morgan on 1/19/26.
//

import SwiftUI

struct ChatMessageRow: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 40) }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.username)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(message.text)
                    .font(.body)
                    .foregroundStyle(.primary)

                Text(message.timestamp, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(isCurrentUser ? Color.blue.opacity(0.15) : Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if !isCurrentUser { Spacer(minLength: 40) }
        }
    }
}

struct SettingsView: View {
    @Binding var username: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Display name", text: $username)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct NamePromptView: View {
    @Binding var username: String
    var onSave: () -> Void

    @State private var draftName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome to the chat room")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Enter a display name to start chatting.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                TextField("Your name", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal)

                Button("Save") {
                    let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    username = trimmed
                    onSave()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Your Name")
            .onAppear {
                draftName = username
            }
        }
    }
}
