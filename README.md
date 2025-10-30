# Glitter - Local Twitter Clone

A fully-functional Twitter clone built with SwiftUI and SwiftData that runs entirely on-device with no backend required.

## Features

### Core Functionality
- **Post Tweets** - Compose tweets with a 280-character limit
- **Timeline Feed** - View all tweets in reverse chronological order
- **User Profile** - View and edit your profile information
- **Like & Retweet** - Interact with tweets through likes and retweets
- **Search** - Search for tweets and discover trending hashtags
- **Hashtags & Mentions** - Automatic detection and highlighting of #hashtags and @mentions

### Technical Features
- **SwiftData Persistence** - All data stored locally on device
- **SwiftUI Interface** - Modern, responsive UI
- **Multi-platform Support** - Works on iOS, macOS, iPadOS, and visionOS
- **Real-time Updates** - Instant feedback for all interactions

## Project Structure

```
Glitter/
├── Models/
│   ├── Tweet.swift       # Tweet data model with hashtag/mention parsing
│   └── User.swift        # User profile data model
├── Views/
│   ├── TimelineView.swift      # Main feed of all tweets
│   ├── ComposeTweetView.swift  # Tweet composition with character counter
│   ├── TweetRowView.swift      # Individual tweet display with actions
│   ├── ProfileView.swift       # User profile and edit functionality
│   └── SearchView.swift        # Search tweets and hashtags
├── ContentView.swift     # Tab-based navigation
└── GlitterApp.swift      # App entry point
```

## How to Use

### Getting Started
1. Open the project in Xcode
2. Select your target device (iPhone, iPad, Mac, or Vision Pro simulator)
3. Build and run (⌘R)

### Using the App

#### Posting a Tweet
1. Tap the compose button (pencil icon) in the top-right corner
2. Type your tweet (up to 280 characters)
3. Tap "Tweet" to publish
4. Use #hashtags and @mentions in your content

#### Interacting with Tweets
- **Like**: Tap the heart icon
- **Retweet**: Tap the retweet icon to share to your timeline
- **View Details**: Tweets show timestamp, author, and interaction counts

#### Managing Your Profile
1. Navigate to the Profile tab
2. Tap "Edit Profile" to update:
   - Display name
   - Username
   - Bio

#### Searching
1. Navigate to the Search tab
2. Switch between "Tweets" and "Hashtags" using the segmented control
3. Type in the search bar to filter results
4. View hashtag usage statistics

## Data Models

### Tweet
- Content (string)
- Author (User relationship)
- Timestamp
- Like count & Retweet count
- Retweet support (original tweet reference)
- Computed properties for hashtags and mentions

### User
- Username & Display name
- Bio
- Profile creation date
- Relationships to tweets and liked tweets
- Current user flag for the active account

## Requirements

- Xcode 15.0+
- iOS 17.0+ / macOS 14.0+ / iPadOS 17.0+ / visionOS 1.0+
- Swift 5.9+
- SwiftUI
- SwiftData

## Building and Running

```bash
# Build from command line
xcodebuild -project Glitter.xcodeproj -scheme Glitter -destination 'platform=iOS Simulator,name=iPhone 16' build

# Or open in Xcode
open Glitter.xcodeproj
```

## Architecture

The app uses modern iOS development practices:
- **MVVM Pattern** - Models separate from Views
- **SwiftData** - Apple's modern data persistence framework
- **Declarative UI** - SwiftUI for all interface components
- **Relationships** - Proper data modeling with cascading deletes
- **Query System** - SwiftData queries for efficient data fetching

## Future Enhancements

Potential features to add:
- Image attachments
- Video support
- Direct messages
- Multiple user accounts
- Tweet threads
- Bookmarks
- Lists
- Dark mode support
- iPad split-view optimization
- Export/import data

## License

This is a demonstration project created for educational purposes.
