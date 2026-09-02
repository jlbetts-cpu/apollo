//
//  ApolloRepositories.swift
//  Apollo
//
//  One place that decides which repository a screen gets. In guest mode the
//  mocks are handed out instead of Supabase, so the whole app can be walked
//  through — feed, camera, wins, friends, profile, memories, notifications —
//  with no account and no network, which is what building it needs.
//
//  Screens call these instead of constructing `SupabaseXRepository`
//  directly. `isGuest` is set by SessionStore and nothing else.
//

import Foundation

enum ApolloRepositories {
    /// Set by SessionStore.enterGuestMode() / leaveGuestMode(). Read-only
    /// everywhere else.
    static var isGuest: Bool = false

    /// The guest is the mock feed's own user, so "your" posts, reactions and
    /// wins behave as if you had made them.
    static var guestUser: CurrentUser {
        CurrentUser(
            id: MockFeedRepository.me.id,
            username: MockFeedRepository.me.username,
            avatarURL: MockFeedRepository.me.avatarURL
        )
    }

    static func feed(currentUserID: UUID) -> any FeedRepository {
        isGuest ? MockFeedRepository() : SupabaseFeedRepository(currentUserID: currentUserID)
    }

    static func comments(currentUserID: UUID, username: String, avatarURL: URL?) -> any CommentsRepository {
        isGuest
            ? MockCommentsRepository()
            : SupabaseCommentsRepository(currentUserID: currentUserID, username: username, avatarURL: avatarURL)
    }

    static func camera(currentUserID: UUID) -> any CameraRepository {
        isGuest ? MockCameraRepository() : SupabaseCameraRepository(currentUserID: currentUserID)
    }

    static func post(currentUserID: UUID) -> any PostRepository {
        isGuest ? MockPostRepository() : SupabasePostRepository(currentUserID: currentUserID)
    }

    static func winList(currentUserID: UUID) -> any WinListRepository {
        isGuest ? MockWinListRepository() : SupabaseWinListRepository(currentUserID: currentUserID)
    }

    static func profile(currentUserID: UUID, profileUserID: UUID) -> any ProfileRepositoryProtocol {
        isGuest
            ? MockProfileRepository()
            : SupabaseProfileRepository(currentUserID: currentUserID, profileUserID: profileUserID)
    }

    static func memories(userID: UUID) -> any MemoriesRepositoryProtocol {
        isGuest ? MockMemoriesRepository() : SupabaseMemoriesRepository(userID: userID)
    }

    static func friends(currentUserID: UUID) -> any FriendsRepositoryProtocol {
        isGuest ? MockFriendsRepository() : SupabaseFriendsRepository(currentUserID: currentUserID)
    }

    static func notifications(currentUserID: UUID) -> any NotificationsRepositoryProtocol {
        isGuest ? MockNotificationsRepository() : SupabaseNotificationsRepository(currentUserID: currentUserID)
    }
}
