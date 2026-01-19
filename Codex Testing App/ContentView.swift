//
//  ContentView.swift
//  Codex Testing App
//
//  Created by chase morgan on 1/19/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("chat_username") private var username: String = ""
    @State private var draftMessage = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showNamePrompt = false
    @State private var showSettings = false

    private let service = ChatService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading chat history...")
                        .padding(.top)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                List(messages) { message in
                    ChatMessageRow(message: message, isCurrentUser: message.username == username)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                .listStyle(.plain)

                Divider()

                HStack(spacing: 12) {
                    TextField("Write a message", text: $draftMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)

                    Button("Send") {
                        Task { await sendMessage() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Local Chat Room")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task { await loadMessages() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(username: $username)
            }
            .sheet(isPresented: $showNamePrompt) {
                NamePromptView(username: $username) {
                    showNamePrompt = false
                }
            }
            .task {
                await loadMessages()
                if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    showNamePrompt = true
                }
            }
        }
    }

    private func loadMessages() async {
        isLoading = true
        errorMessage = nil
        do {
            messages = try await service.fetchMessages()
        } catch {
            errorMessage = "Unable to load messages. Make sure the local server is running."
        }
        isLoading = false
    }

    private func sendMessage() async {
        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showNamePrompt = true
            return
        }

        let trimmedMessage = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        do {
            let newMessage = try await service.sendMessage(username: trimmedName, text: trimmedMessage)
            messages.append(newMessage)
            draftMessage = ""
        } catch {
            errorMessage = "Failed to send message."
        }
    }
}

#Preview {
    ContentView()
}
