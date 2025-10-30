//
//  ComposeTweetView.swift
//  Glitter
//
//  Created by David Mazza on 10/30/25.
//

import SwiftUI
import SwiftData

struct ComposeTweetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<User> { $0.isCurrentUser }) private var currentUsers: [User]

    @State private var tweetText: String = ""
    let maxCharacters = 280

    var currentUser: User? {
        currentUsers.first
    }

    var remainingCharacters: Int {
        maxCharacters - tweetText.count
    }

    var canTweet: Bool {
        !tweetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        tweetText.count <= maxCharacters
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    // Profile image placeholder
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 48, height: 48)
                        .overlay {
                            Text(currentUser?.displayName.prefix(1).uppercased() ?? "?")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                        }

                    // Text editor
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $tweetText)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .font(.body)
                            .overlay(alignment: .topLeading) {
                                if tweetText.isEmpty {
                                    Text("What's happening?")
                                        .foregroundColor(.gray)
                                        .font(.body)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            }

                        Divider()

                        // Character count
                        HStack {
                            Spacer()
                            Text("\(remainingCharacters)")
                                .font(.caption)
                                .foregroundColor(remainingCharacters < 0 ? .red : remainingCharacters < 20 ? .orange : .gray)
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("New Tweet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Tweet") {
                        postTweet()
                    }
                    .bold()
                    .disabled(!canTweet)
                }
            }
        }
    }

    private func postTweet() {
        guard canTweet, let user = currentUser else { return }

        let newTweet = Tweet(content: tweetText, author: user)
        modelContext.insert(newTweet)

        dismiss()
    }
}

#Preview {
    ComposeTweetView()
        .modelContainer(for: [Tweet.self, User.self], inMemory: true)
}
