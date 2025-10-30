//
//  Tweet.swift
//  Glitter
//
//  Created by David Mazza on 10/30/25.
//

import Foundation
import SwiftData

@Model
final class Tweet {
    @Attribute(.unique) var id: UUID
    var content: String
    var timestamp: Date
    var likeCount: Int
    var retweetCount: Int

    var author: User?

    @Relationship(deleteRule: .cascade, inverse: \Tweet.originalTweet)
    var retweets: [Tweet]?

    var originalTweet: Tweet?
    var isRetweet: Bool

    @Relationship(deleteRule: .nullify)
    var likedBy: [User]?

    init(content: String, author: User?, isRetweet: Bool = false, originalTweet: Tweet? = nil) {
        self.id = UUID()
        self.content = content
        self.timestamp = Date()
        self.likeCount = 0
        self.retweetCount = 0
        self.author = author
        self.isRetweet = isRetweet
        self.originalTweet = originalTweet
        self.retweets = []
        self.likedBy = []
    }

    var hashtags: [String] {
        let pattern = "#[a-zA-Z0-9_]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        return matches.compactMap { match in
            if let range = Range(match.range, in: content) {
                return String(content[range])
            }
            return nil
        }
    }

    var mentions: [String] {
        let pattern = "@[a-zA-Z0-9_]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        return matches.compactMap { match in
            if let range = Range(match.range, in: content) {
                return String(content[range])
            }
            return nil
        }
    }
}
