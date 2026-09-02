//
//  FeedView.swift
//  Apollo
//
//  The Feed screen — Apollo's primary social surface. Composes the nav bar,
//  tab row, and a phase-driven scroll container of PostCards. Owns navigation
//  destinations (push, sheet, full-screen cover, action sheet, alerts) and
//  routes them to placeholder screens that future agents can swap in.
//

import Supabase
import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var notificationsService: NotificationsService
    @EnvironmentObject private var sunsetClock: SunsetClock
    @ObservedObject private var deepLinkRouter = DeepLinkRouter.shared
    @State private var viewModel: FeedViewModel
    @State private var navigationPath = NavigationPath()
    @State private var sheetItem: FeedSheetItem?
    @State private var fullScreenItem: FeedFullScreenItem?
    @State private var actionSheetPost: Post?
    @State private var isActionSheetPresented = false
    @State private var deleteCandidate: Post?

    let currentUser: CurrentUser?

    init(
        repository: FeedRepository? = nil,
        commentsRepository: CommentsRepository? = nil,
        currentUser: CurrentUser? = nil
    ) {
        self.currentUser = currentUser
        let userID = currentUser?.id ?? supabase.auth.currentUser?.id ?? UUID()
        let feedRepo: FeedRepository = repository ?? ApolloRepositories.feed(currentUserID: userID)
        let commentsRepo: CommentsRepository = commentsRepository ?? ApolloRepositories.comments(
            currentUserID: userID,
            username: currentUser?.username ?? "you",
            avatarURL: currentUser?.avatarURL
        )
        _viewModel = State(initialValue: FeedViewModel(
            repository: feedRepo,
            commentsRepository: commentsRepo
        ))
    }

    init(viewModel: FeedViewModel) {
        self.currentUser = nil
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                Color.apolloBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    contentArea
                }

                if let message = viewModel.transientErrorMessage {
                    ErrorToast(
                        message: message,
                        actionLabel: viewModel.phase == .error ? "Try again" : nil,
                        onAction: viewModel.phase == .error ? {
                            viewModel.clearTransientError()
                            Task { await viewModel.load(initial: true) }
                        } : nil,
                        onDismiss: {
                            withAnimation(ApolloMotion.state) {
                                viewModel.clearTransientError()
                            }
                        }
                    )
                    .padding(.top, 4)
                    .zIndex(10)
                    .apolloTransition(.move(edge: .top).combined(with: .opacity))
                }

                if !viewModel.pendingNewPosts.isEmpty {
                    NewPostsBanner(count: viewModel.pendingNewPostsCount) {
                        withAnimation(ApolloMotion.move) {
                            viewModel.applyPendingNewPosts()
                        }
                    }
                    .padding(.top, 110)
                    .zIndex(5)
                    .apolloTransition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    LinearGradient(
                        colors: [Color.apolloBackground.opacity(0), Color.apolloBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 91)
                    .frame(maxWidth: .infinity)
                }
                .allowsHitTesting(false)
                .zIndex(2)
            }
            .apolloAnimation(ApolloMotion.move, value: viewModel.transientErrorMessage)
            .apolloAnimation(ApolloMotion.move, value: viewModel.pendingNewPostsCount)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("ApolloWordmark")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
                        .accessibilityLabel("Apollo")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigationPath.append(FeedDestination.notifications)
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image("IconBell")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundStyle(Color.apolloPrimaryText)

                            if notificationsService.unreadCount > 0 {
                                Circle()
                                    .fill(Color.apolloBadge)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 3, y: -3)
                                    .apolloTransition(.scale(scale: 0.3).combined(with: .opacity))
                            }
                        }
                        .apolloAnimation(ApolloMotion.pop, value: notificationsService.unreadCount > 0)
                    }
                    .accessibilityLabel(
                        notificationsService.unreadCount > 0
                            ? "Notifications, \(notificationsService.unreadCount) unread"
                            : "Notifications"
                    )
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationDestination(for: FeedDestination.self) { dest in
                switch dest {
                case .notifications:
                    NotificationsView(currentUser: currentUser)
                        .environmentObject(notificationsService)
                case .profile(let user):
                    ProfileView(userID: user.id, currentUser: currentUser)
                case .shareStrip(let post):
                    ShareStripPlaceholder(post: post)
                }
            }
            .sheet(item: $sheetItem) { item in
                switch item {
                case .comments(let post):
                    CommentsSheet(post: post, repository: viewModel.commentsRepository)
                case .reactions(let post):
                    ReactionsBreakdownSheet(post: post, repository: viewModel.repository)
                case .report(let post):
                    ReportFlowPlaceholder(post: post) {
                        sheetItem = nil
                    }
                case .customEmoji(let post):
                    EmojiPickerSheet(
                        onSelect: { emoji in
                            sheetItem = nil
                            viewModel.toggleReaction(post: post, emoji: emoji)
                            Analytics.track(.customEmojiUsed, ["emoji": emoji, "post_id": post.id.uuidString])
                        },
                        onDismiss: {
                            sheetItem = nil
                            viewModel.dismissCustomEmoji()
                        }
                    )
                    .presentationDetents([.height(260)])
                    .presentationBackground(Color.apolloBackground)
                }
            }
            .fullScreenCover(item: $fullScreenItem) { item in
                switch item {
                case .photoViewer(let post, let index):
                    FullScreenPhotoViewer(post: post, startingIndex: index) {
                        fullScreenItem = nil
                    }
                case .camera:
                    let userID = supabase.auth.currentUser?.id ?? UUID()
                    CameraView(
                        repository: ApolloRepositories.camera(currentUserID: userID),
                        postRepository: ApolloRepositories.post(currentUserID: userID),
                        winListRepository: ApolloRepositories.winList(currentUserID: userID),
                        onClose: { fullScreenItem = nil }
                    )
                }
            }
            .postActionSheet(
                post: actionSheetPost,
                isOwnPost: actionSheetPost.map(viewModel.isOwnPost) ?? false,
                isPresented: $isActionSheetPresented,
                onIntent: handleActionSheetIntent
            )
            .alert(
                "Delete this post?",
                isPresented: .init(
                    get: { deleteCandidate != nil },
                    set: { if !$0 { deleteCandidate = nil } }
                ),
                presenting: deleteCandidate
            ) { post in
                Button("Delete", role: .destructive) {
                    withAnimation(ApolloMotion.move) {
                        viewModel.delete(post: post)
                    }
                    deleteCandidate = nil
                }
                Button("Cancel", role: .cancel) {
                    deleteCandidate = nil
                }
            } message: { _ in
                Text("This can't be undone.")
            }
            .onAppear {
                viewModel.onAppear()
                syncTabToSunset()
            }
            .onDisappear { viewModel.onDisappear() }
            .onChange(of: sunsetClock.isUnlocked) { _, unlocked in
                // §8.4 step 3: the haptic lands on the same frame as the word.
                if unlocked { ApolloHaptics.success() }
                syncTabToSunset()
            }
            .onChange(of: viewModel.customEmojiTarget) { _, targetID in
                guard let targetID,
                      let post = viewModel.posts.first(where: { $0.id == targetID }) else { return }
                sheetItem = .customEmoji(post)
            }
            .onReceive(NotificationCenter.default.publisher(for: .apolloFeedShouldRefresh)) { _ in
                Task { await viewModel.refresh() }
            }
            // Deep link: scroll/push to a specific post from a notification tap.
            .onChange(of: deepLinkRouter.targetPostID) { _, postID in
                guard let postID else { return }
                deepLinkRouter.targetPostID = nil
                if let post = viewModel.posts.first(where: { $0.id == postID }) {
                    if deepLinkRouter.openComments {
                        deepLinkRouter.openComments = false
                        sheetItem = .comments(post)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Content area (phase-driven)

    private var contentArea: some View {
        ZStack {
            phaseContent
                .id(viewModel.phase)
                .apolloTransition(.opacity)
        }
        // One declaration covers all four scroll views below it: a bright
        // indicator track over a full-bleed dark photo feed is the loudest
        // non-content pixel on the screen.
        .scrollIndicators(.hidden)
        .apolloAnimation(ApolloMotion.reveal, value: viewModel.phase)
        .apolloAnimation(ApolloMotion.settle, value: sunsetClock.isUnlocked)
    }

    // MARK: - Sunset

    /// Before sunset the feed shows yesterday; after it, today. The view
    /// model's tab is derived from the clock, never chosen.
    private func syncTabToSunset() {
        let wanted: FeedTab = sunsetClock.isUnlocked ? .now : .yesterday
        if viewModel.tab != wanted {
            withAnimation(ApolloMotion.settle) { viewModel.switchTab(wanted) }
        }
    }

    /// What sits above the posts (§11.3–11.4): the locked hero and its
    /// "Yesterday" label before sunset; the "Today" label after.
    @ViewBuilder
    private var feedLead: some View {
        if !sunsetClock.isUnlocked {
            FeedLockedHero(people: orbPeople) { person in
                guard !person.isYou else { return }
                navigationPath.append(FeedDestination.profile(
                    PostUser(id: person.id, username: person.name, avatarURL: person.avatarURL, streak: 0)
                ))
            }
            .apolloTransition(.move(edge: .top).combined(with: .opacity))
            ApolloSectionLabel(text: "Yesterday")
                .padding(.top, ApolloSpace.section)
        } else {
            ApolloSectionLabel(text: "Today")
                .padding(.top, ApolloSpace.xl)
        }
    }

    /// The orbs are you plus everyone whose win you're about to see — so
    /// when the feed unlocks, the people who were floating are the people
    /// on the screen (§8.4 step 4).
    private var orbPeople: [OrbPerson] {
        var seen = Set<UUID>()
        var out: [OrbPerson] = []
        if let me = currentUser {
            out.append(OrbPerson(id: me.id, name: me.username, avatarURL: me.avatarURL, isYou: true))
            seen.insert(me.id)
        }
        for post in viewModel.posts where !seen.contains(post.user.id) {
            seen.insert(post.user.id)
            out.append(OrbPerson(id: post.user.id, name: post.user.username, avatarURL: post.user.avatarURL, isYou: false))
        }
        return out
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {
        case .loading:
            ScrollView {
                VStack(spacing: 0) {
                    feedLead
                    FeedSkeleton().padding(.top, 8)
                }
            }
        case .loaded:
            postsScroll
        case .empty:
            ScrollView {
                VStack(spacing: 0) {
                    feedLead
                    EmptyFeedView {
                        fullScreenItem = .camera
                    }
                }
            }
        case .partial:
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    feedLead
                    ForEach(viewModel.posts) { post in
                        postCard(for: post)
                    }
                    PartialEmptyView()
                    EndOfFeedView(quote: viewModel.quote)
                }
            }
            .refreshable { await viewModel.refresh() }
        case .yesterdayEmpty:
            ScrollView {
                VStack(spacing: 0) {
                    feedLead
                    YesterdayEmptyView()
                }
            }
        case .error:
            ScrollView {
                VStack(spacing: 0) {
                    feedLead
                    FeedSkeleton().padding(.top, 8).opacity(0.4)
                }
            }
            .refreshable { await viewModel.refresh() }
        }
    }

    private var postsScroll: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                feedLead
                ForEach(viewModel.posts) { post in
                    postCard(for: post)
                }

                if viewModel.isLoadingMore {
                    Circle()
                        .fill(Color.apolloMuted)
                        .frame(width: 6, height: 6)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }

                if !viewModel.hasMore {
                    EndOfFeedView(quote: viewModel.quote)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await viewModel.refresh() }
        .simultaneousGesture(
            TapGesture().onEnded {
                if viewModel.activeReactionPicker != nil {
                    viewModel.dismissReactionPicker()
                }
            }
        )
    }

    private func postCard(for post: Post) -> some View {
        PostCard(
            viewModel: viewModel,
            post: post,
            onProfileTap: { user in
                navigationPath.append(FeedDestination.profile(user))
            },
            onMoreTap: { post in
                actionSheetPost = post
                isActionSheetPresented = true
            },
            onCommentTap: { post in
                sheetItem = .comments(post)
            },
            onReactionsLineTap: { post in
                sheetItem = .reactions(post)
                Analytics.track(.breakdownOpened, ["post_id": post.id.uuidString, "total_reactions": post.reactions.count])
            },
            onPhotoTap: { post, index in
                fullScreenItem = .photoViewer(post, index)
            }
        )
        .id(post.id)
    }

    // MARK: - Action sheet routing

    private func handleActionSheetIntent(_ intent: PostActionSheetIntent) {
        switch intent {
        case .editOwn(let post):
            sheetItem = .comments(post)
            // TODO: route to Post Details Sheet when that screen ships.
        case .shareStripOwn(let post):
            navigationPath.append(FeedDestination.shareStrip(post))
        case .deleteOwn(let post):
            deleteCandidate = post
        case .shareOthers:
            // TODO: present iOS Share Sheet with post URL when share infra exists.
            viewModel.transientErrorMessage = "Share sheet coming soon."
        case .reportOthers(let post):
            sheetItem = .report(post)
        }
    }
}

// MARK: - Routing types

enum FeedDestination: Hashable {
    case notifications
    case profile(PostUser)
    case shareStrip(Post)
}

enum FeedSheetItem: Identifiable {
    case comments(Post)
    case reactions(Post)
    case report(Post)
    case customEmoji(Post)

    var id: String {
        switch self {
        case .comments(let p):    return "comments-\(p.id)"
        case .reactions(let p):   return "reactions-\(p.id)"
        case .report(let p):      return "report-\(p.id)"
        case .customEmoji(let p): return "customEmoji-\(p.id)"
        }
    }
}

enum FeedFullScreenItem: Identifiable {
    case photoViewer(Post, Int)
    case camera

    var id: String {
        switch self {
        case .photoViewer(let p, let i): return "photo-\(p.id)-\(i)"
        case .camera: return "camera"
        }
    }
}

// MARK: - Previews

#Preview("Loaded") {
    FeedView(
        repository: MockFeedRepository(forceState: .loaded),
        commentsRepository: MockCommentsRepository(forceState: .populated)
    )
}

#Preview("Empty") {
    FeedView(
        repository: MockFeedRepository(forceState: .empty),
        commentsRepository: MockCommentsRepository(forceState: .empty)
    )
}

#Preview("Partial") {
    FeedView(
        repository: MockFeedRepository(forceState: .partial),
        commentsRepository: MockCommentsRepository(forceState: .populated)
    )
}

#Preview("Yesterday Empty") {
    FeedView(
        repository: MockFeedRepository(forceState: .yesterdayEmpty),
        commentsRepository: MockCommentsRepository(forceState: .empty)
    )
}

#Preview("Error") {
    FeedView(
        repository: MockFeedRepository(forceState: .error),
        commentsRepository: MockCommentsRepository(forceState: .error)
    )
}
