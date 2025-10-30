//
//  User.swift
//  Glitter
//
//  Created by David Mazza on 10/30/25.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var username: String
    var displayName: String
    var bio: String
    var profileImageName: String?
    var joinedDate: Date
    var isCurrentUser: Bool

    @Relationship(deleteRule: .cascade, inverse: \Tweet.author)
    var tweets: [Tweet]?

    @Relationship(deleteRule: .nullify)
    var likedTweets: [Tweet]?

    init(username: String, displayName: String, bio: String = "", isCurrentUser: Bool = false) {
        self.id = UUID()
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.joinedDate = Date()
        self.isCurrentUser = isCurrentUser
        self.tweets = []
        self.likedTweets = []
    }
}
