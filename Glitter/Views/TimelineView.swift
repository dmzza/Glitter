//
//  TimelineView.swift
//  Glitter
//
//  Created by David Mazza on 10/30/25.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tweet.timestamp, order: .reverse) private var tweets: [Tweet]
    @Query(filter: #Predicate<User> { $0.isCurrentUser }) private var currentUsers: [User]

    @State private var showComposeTweet = false

    var currentUser: User? {
        currentUsers.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(tweets) { tweet in
                        VStack(spacing: 0) {
                            TweetRowView(tweet: tweet, currentUser: currentUser)
                            Divider()
                        }
                    }

                    if tweets.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No tweets yet")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Be the first to tweet!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                    }
                }
            }
            .navigationTitle("Glitter")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showComposeTweet = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showComposeTweet) {
                ComposeTweetView()
            }
            .onAppear {
                ensureCurrentUserExists()
            }
        }
    }

    private func ensureCurrentUserExists() {
        if currentUsers.isEmpty {
            let user = User(
                username: "you",
                displayName: "You",
                bio: "Default user account",
                isCurrentUser: true
            )
            modelContext.insert(user)
        }
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: [Tweet.self, User.self], inMemory: true)
}
