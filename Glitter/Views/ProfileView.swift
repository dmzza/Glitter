//
//  ProfileView.swift
//  Glitter
//
//  Created by David Mazza on 10/30/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<User> { $0.isCurrentUser }) private var currentUsers: [User]
    @Query(sort: \Tweet.timestamp, order: .reverse) private var allTweets: [Tweet]

    @State private var showEditProfile = false

    var currentUser: User? {
        currentUsers.first
    }

    var userTweets: [Tweet] {
        guard let user = currentUser else { return [] }
        return allTweets.filter { tweet in
            if tweet.isRetweet {
                return tweet.author?.id == user.id
            } else {
                return tweet.author?.id == user.id
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile header
                    VStack(spacing: 16) {
                        // Banner placeholder
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 120)

                        VStack(spacing: 12) {
                            // Profile image
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Text(currentUser?.displayName.prefix(1).uppercased() ?? "?")
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                        .bold()
                                }
                                .offset(y: -40)
                                .padding(.bottom, -40)

                            // User info
                            VStack(spacing: 4) {
                                Text(currentUser?.displayName ?? "Unknown")
                                    .font(.title2)
                                    .bold()
                                Text("@\(currentUser?.username ?? "unknown")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            if let bio = currentUser?.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                    Text("Joined \(formattedJoinDate)")
                                        .font(.caption)
                                }
                                .foregroundColor(.gray)
                            }

                            // Stats
                            HStack(spacing: 24) {
                                VStack {
                                    Text("\(userTweets.count)")
                                        .font(.headline)
                                        .bold()
                                    Text("Tweets")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                VStack {
                                    Text("\(currentUser?.likedTweets?.count ?? 0)")
                                        .font(.headline)
                                        .bold()
                                    Text("Likes")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 8)

                            Button(action: { showEditProfile = true }) {
                                Text("Edit Profile")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                    }

                    Divider()
                        .padding(.top, 16)

                    // User's tweets
                    LazyVStack(spacing: 0) {
                        ForEach(userTweets) { tweet in
                            VStack(spacing: 0) {
                                TweetRowView(tweet: tweet, currentUser: currentUser)
                                Divider()
                            }
                        }

                        if userTweets.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "text.bubble")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No tweets yet")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            .padding(40)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }

    private var formattedJoinDate: String {
        guard let date = currentUser?.joinedDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct EditProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<User> { $0.isCurrentUser }) private var currentUsers: [User]

    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""

    var currentUser: User? {
        currentUsers.first
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Information") {
                    TextField("Display Name", text: $displayName)
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Bio") {
                    TextEditor(text: $bio)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                displayName = currentUser?.displayName ?? ""
                username = currentUser?.username ?? ""
                bio = currentUser?.bio ?? ""
            }
        }
    }

    private func saveProfile() {
        guard let user = currentUser else { return }

        user.displayName = displayName
        user.username = username
        user.bio = bio

        dismiss()
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Tweet.self, User.self], inMemory: true)
}
