//
//  RootTabView.swift
//  Apollo
//
//  The shell. DESIGN-SYSTEM §11.1: three tabs — Feed · Camera · Find — and
//  the app opens on the camera, because capturing has to be the easiest
//  thing to do and therefore the first thing you see.
//
//  The camera is a full-screen cover, not a tab's content: it is presented
//  on launch and again whenever the Camera tab is tapped, and dismissing it
//  (chevron or swipe-down) lands on whichever tab was underneath. That keeps
//  the viewfinder full-bleed with no tab bar over the shutter, exactly as
//  the Figma frame has it.
//
//  Profile lives behind your avatar in Find; notifications behind the bell
//  on Feed. North is out of scope for this pass.
//

import Supabase
import SwiftUI

struct RootTabView: View {
    enum TabSelection: Hashable {
        case feed, camera, find
    }

    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var notificationsService: NotificationsService
    @EnvironmentObject private var sunsetClock: SunsetClock
    @ObservedObject private var deepLinkRouter = DeepLinkRouter.shared

    @State private var selection: TabSelection = .feed
    @State private var showCamera: Bool = false
    @State private var hasOpenedCameraOnLaunch: Bool = false
    @State private var showPushPrompt: Bool = false

    private var selectionBinding: Binding<TabSelection> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue == .camera {
                    ApolloHaptics.commit()
                    showCamera = true
                } else {
                    if newValue != selection { ApolloHaptics.select() }
                    selection = newValue
                }
            }
        )
    }

    var body: some View {
        TabView(selection: selectionBinding) {
            FeedView(currentUser: sessionStore.currentUser)
                .tag(TabSelection.feed)
                .tabItem { Label("Feed", systemImage: "photo.stack") }

            // Never displayed — selectionBinding intercepts and presents the cover.
            Color.clear
                .tag(TabSelection.camera)
                .tabItem { Label("Camera", systemImage: "camera") }

            FriendsView(currentUser: sessionStore.currentUser)
                .tag(TabSelection.find)
                .tabItem { Label("Find", systemImage: "magnifyingglass") }
        }
        .onAppear {
            ApolloHaptics.prepare()
            sunsetClock.start()
            // Camera first. A cover presented in the same frame the TabView
            // appears can be dropped; a beat later is reliable.
            if !hasOpenedCameraOnLaunch {
                hasOpenedCameraOnLaunch = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    showCamera = true
                }
            }
        }
        .onDisappear { sunsetClock.stop() }
        // Deep links from push taps.
        .onChange(of: deepLinkRouter.targetTab) { _, newTab in
            guard let newTab else { return }
            switch newTab {
            case .feed:     selection = .feed
            case .friends:  selection = .find
            case .north:    selection = .feed
            case .profile:  selection = .find
            }
            deepLinkRouter.targetTab = nil
        }
        // Post-first-win push permission prompt.
        .onChange(of: notificationsService.shouldShowPermissionPrompt) { _, show in
            if show { showPushPrompt = true }
        }
        .sheet(isPresented: $showPushPrompt, onDismiss: {
            notificationsService.shouldShowPermissionPrompt = false
        }) {
            EnableNotificationsPromptView {
                showPushPrompt = false
                notificationsService.shouldShowPermissionPrompt = false
            }
            .environmentObject(notificationsService)
            .presentationDetents([.fraction(0.55)])
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.apolloRaised)
        }
        .fullScreenCover(isPresented: $showCamera) {
            let userID = sessionStore.currentUser?.id ?? supabase.auth.currentUser?.id ?? UUID()
            CameraView(
                repository: ApolloRepositories.camera(currentUserID: userID),
                postRepository: ApolloRepositories.post(currentUserID: userID),
                winListRepository: ApolloRepositories.winList(currentUserID: userID),
                onClose: { showCamera = false }
            )
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(SunsetClock.shared)
        .preferredColorScheme(.dark)
}
