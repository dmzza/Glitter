//
//  SearchView.swift
//  Glitter
//
//  Created by David Mazza on 10/30/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tweet.timestamp, order: .reverse) private var allTweets: [Tweet]
    @Query(filter: #Predicate<User> { $0.isCurrentUser }) private var currentUsers: [User]

    @State private var searchText = ""
    @State private var selectedTab = 0

    var currentUser: User? {
        currentUsers.first
    }

    var filteredTweets: [Tweet] {
        if searchText.isEmpty {
            return allTweets
        }
        return allTweets.filter { tweet in
            tweet.content.localizedCaseInsensitiveContains(searchText) ||
            tweet.author?.displayName.localizedCaseInsensitiveContains(searchText) ?? false ||
            tweet.author?.username.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    var hashtags: [String] {
        var allHashtags: [String] = []
        for tweet in allTweets {
            allHashtags.append(contentsOf: tweet.hashtags)
        }

        let uniqueHashtags = Array(Set(allHashtags))
        if searchText.isEmpty {
            return uniqueHashtags.sorted()
        }
        return uniqueHashtags.filter { $0.localizedCaseInsensitiveContains(searchText) }.sorted()
    }

    var hashtagCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for tweet in allTweets {
            for hashtag in tweet.hashtags {
                counts[hashtag, default: 0] += 1
            }
        }
        return counts
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Search Type", selection: $selectedTab) {
                    Text("Tweets").tag(0)
                    Text("Hashtags").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    // Tweets
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredTweets) { tweet in
                                VStack(spacing: 0) {
                                    TweetRowView(tweet: tweet, currentUser: currentUser)
                                    Divider()
                                }
                            }

                            if filteredTweets.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("No tweets found")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    if !searchText.isEmpty {
                                        Text("Try a different search term")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(40)
                            }
                        }
                    }
                } else {
                    // Hashtags
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(hashtags, id: \.self) { hashtag in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(hashtag)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text("\(hashtagCounts[hashtag] ?? 0) tweets")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                Divider()
                            }

                            if hashtags.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "number")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("No hashtags found")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    if !searchText.isEmpty {
                                        Text("Try a different search term")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Hashtags from tweets will appear here")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search Glitter")
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Tweet.self, User.self], inMemory: true)
}
