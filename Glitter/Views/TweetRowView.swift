//
//  TweetRowView.swift
//  Glitter
//
//  Created by David Mazza on 10/30/25.
//

import SwiftUI
import SwiftData

struct TweetRowView: View {
    @Environment(\.modelContext) private var modelContext
    let tweet: Tweet
    let currentUser: User?

    @State private var isLiked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Retweet indicator
            if tweet.isRetweet {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(tweet.author?.displayName ?? "Someone") retweeted")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 48)
            }

            HStack(alignment: .top, spacing: 12) {
                // Profile image
                Circle()
                    .fill(Color.blue)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(displayUser.displayName.prefix(1).uppercased())
                            .foregroundColor(.white)
                            .font(.body)
                            .bold()
                    }

                VStack(alignment: .leading, spacing: 4) {
                    // Header
                    HStack(spacing: 4) {
                        Text(displayUser.displayName)
                            .font(.headline)
                        Text("@\(displayUser.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("·")
                            .foregroundColor(.gray)
                        Text(timeAgoString(from: displayTweet.timestamp))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // Content with hashtag and mention highlighting
                    AttributedTweetText(content: displayTweet.content)
                        .font(.body)
                        .textSelection(.enabled)

                    // Action buttons
                    HStack(spacing: 64) {
                        // Reply
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.gray)
                        }

                        // Retweet
                        Button(action: { retweet() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.2.squarepath")
                                    .font(.subheadline)
                                if displayTweet.retweetCount > 0 {
                                    Text("\(displayTweet.retweetCount)")
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.gray)
                        }

                        // Like
                        Button(action: { toggleLike() }) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.subheadline)
                                if displayTweet.likeCount > 0 {
                                    Text("\(displayTweet.likeCount)")
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(isLiked ? .red : .gray)
                        }

                        // Share
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .onAppear {
            checkIfLiked()
        }
    }

    var displayTweet: Tweet {
        tweet.isRetweet ? (tweet.originalTweet ?? tweet) : tweet
    }

    var displayUser: User {
        displayTweet.author ?? User(username: "unknown", displayName: "Unknown")
    }

    private func checkIfLiked() {
        if let user = currentUser {
            isLiked = displayTweet.likedBy?.contains(where: { $0.id == user.id }) ?? false
        }
    }

    private func toggleLike() {
        guard let user = currentUser else { return }

        if isLiked {
            displayTweet.likedBy?.removeAll(where: { $0.id == user.id })
            displayTweet.likeCount = max(0, displayTweet.likeCount - 1)
            user.likedTweets?.removeAll(where: { $0.id == displayTweet.id })
        } else {
            if displayTweet.likedBy == nil {
                displayTweet.likedBy = []
            }
            displayTweet.likedBy?.append(user)
            displayTweet.likeCount += 1

            if user.likedTweets == nil {
                user.likedTweets = []
            }
            user.likedTweets?.append(displayTweet)
        }

        isLiked.toggle()
    }

    private func retweet() {
        guard let user = currentUser else { return }

        let retweet = Tweet(
            content: displayTweet.content,
            author: user,
            isRetweet: true,
            originalTweet: displayTweet
        )

        displayTweet.retweetCount += 1
        modelContext.insert(retweet)
    }

    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24

        if days > 0 {
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(max(1, seconds))s"
        }
    }
}

struct AttributedTweetText: View {
    let content: String

    var body: some View {
        Text(attributedString)
    }

    private var attributedString: AttributedString {
        var attributed = AttributedString(content)

        // Highlight hashtags
        if let hashtagRegex = try? NSRegularExpression(pattern: "#[a-zA-Z0-9_]+") {
            let matches = hashtagRegex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributed)!..<AttributedString.Index(range.upperBound, within: attributed)!
                    attributed[attributedRange].foregroundColor = .blue
                }
            }
        }

        // Highlight mentions
        if let mentionRegex = try? NSRegularExpression(pattern: "@[a-zA-Z0-9_]+") {
            let matches = mentionRegex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributed)!..<AttributedString.Index(range.upperBound, within: attributed)!
                    attributed[attributedRange].foregroundColor = .blue
                }
            }
        }

        return attributed
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tweet.self, User.self, configurations: config)

    let user = User(username: "johndoe", displayName: "John Doe", isCurrentUser: true)
    let tweet = Tweet(content: "Hello #SwiftUI and @everyone! This is a test tweet.", author: user)

    container.mainContext.insert(user)
    container.mainContext.insert(tweet)

    return TweetRowView(tweet: tweet, currentUser: user)
        .modelContainer(container)
}
