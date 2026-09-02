//
//  CameraView.swift
//  Apollo
//
//  Camera screen — Apollo's primary capture surface. Composes the live
//  viewfinder, the "Shooting for" label, the nav bar, and the bottom
//  controls. After shutter tap, presents CameraCaptureReviewView
//  full-screen. Honors swipe-down dismissal per PRD §5.
//

import SwiftUI

struct CameraView: View {
    @State private var viewModel: CameraViewModel
    @State private var dragOffset: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var onClose: () -> Void

    private let winListRepository: WinListRepository

    init(
        repository: CameraRepository = MockCameraRepository(),
        postRepository: PostRepository = MockPostRepository(),
        winListRepository: WinListRepository = MockWinListRepository(),
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: CameraViewModel(
            repository: repository,
            postRepository: postRepository
        ))
        self.winListRepository = winListRepository
        self.onClose = onClose
    }

    init(viewModel: CameraViewModel, winListRepository: WinListRepository = MockWinListRepository(), onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.winListRepository = winListRepository
        self.onClose = onClose
    }

    var body: some View {
        Group {
            switch viewModel.phase {
            case .permissionDenied:
                CameraPermissionView(onClose: onClose, onOpenSettings: viewModel.openSettings)
            default:
                activeBody
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    // MARK: - Active body

    private var activeBody: some View {
        @Bindable var viewModel = viewModel
        return ZStack(alignment: .top) {
            Color.apolloGround.ignoresSafeArea()

            VStack(spacing: 0) {
                // The viewfinder takes everything above the control block and
                // runs under the status bar; only its bottom corners are
                // rounded (Figma 13646:7518, §3.3).
                viewfinderContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(CameraThirdsGrid())
                    .clipShape(UnevenRoundedRectangle(
                        bottomLeadingRadius: ApolloRadius.viewfinder,
                        bottomTrailingRadius: ApolloRadius.viewfinder,
                        style: .continuous
                    ))
                    .ignoresSafeArea(edges: .top)

                CameraControlStrip(
                    flash: viewModel.flash,
                    activeWin: viewModel.activeWin,
                    isFlipping: viewModel.isFlipping,
                    onToggleFlash: viewModel.cycleFlash,
                    onTapWin: viewModel.openWinPicker,
                    onFlip: { viewModel.flipCamera(reduceMotion: reduceMotion) }
                )
                .padding(.top, ApolloSpace.l)

                if viewModel.isAtMaxPhotos {
                    MaxedOutLabel()
                        .padding(.top, ApolloSpace.m)
                }

                CameraShutterRow(
                    isPressed: viewModel.shutterPressed,
                    isDisabled: viewModel.isAtMaxPhotos,
                    photoCount: viewModel.todaySummary.photoCount,
                    thumbnailURL: viewModel.todaySummary.gridURL,
                    onShutter: viewModel.capture
                )
                .padding(.bottom, ApolloSpace.m)
            }

            CameraTopBar(onClose: onClose)

            if let message = viewModel.transientErrorMessage, !viewModel.isCaptureReviewPresented {
                ErrorToast(
                    message: message,
                    actionLabel: nil,
                    onAction: nil,
                    onDismiss: viewModel.clearTransientError
                )
                .padding(.top, 88)
                .zIndex(10)
            }
        }
        .offset(y: max(0, dragOffset))
        .gesture(
            DragGesture(minimumDistance: 12)
                .onChanged { value in
                    if value.translation.height > 0 { dragOffset = value.translation.height }
                }
                .onEnded { value in
                    if value.translation.height > 120 {
                        onClose()
                    } else {
                        withAnimation(.spring(response: 0.25)) { dragOffset = 0 }
                    }
                }
        )
        .sheet(isPresented: $viewModel.isWinPickerPresented) {
            WinListView(
                repository: winListRepository,
                onSelectWin: { item in
                    viewModel.selectWin(
                        Win(id: item.id, name: item.name, currentStreak: item.currentStreak)
                    )
                }
            )
        }
        .fullScreenCover(isPresented: $viewModel.isCaptureReviewPresented) {
            CameraCaptureReviewView(viewModel: viewModel, onClose: onClose)
        }
        .onChange(of: viewModel.didCommitPhoto) { _, committed in
            if committed { onClose() }
        }
    }

    // MARK: - Viewfinder

    @ViewBuilder
    private var viewfinderContent: some View {
        switch viewModel.phase {
        case .active, .configuring:
            ZStack {
                CameraPreview(
                    session: viewModel.cameraSession.session,
                    isMirrored: viewModel.isMirrored,
                    onTapToFocus: viewModel.tapToFocus,
                    onZoomChange: viewModel.pinchChanged
                )

                FocusExposureOverlay(
                    point: viewModel.focusUIPoint,
                    exposureBias: viewModel.exposureBias,
                    onExposureChange: viewModel.setExposureBias,
                    onInteraction: viewModel.scheduleFocusUIDismissPublic
                )
            }
        case .unsupported:
            Color.apolloBackground
                .overlay(
                    Text("Camera unavailable")
                        .font(.sfPro(14))
                        .foregroundStyle(Color.apolloErrorToastBody)
                )
        default:
            Color.apolloBackground
        }
    }
}

#Preview("With wins") {
    CameraView(
        repository: MockCameraRepository(forceState: .withWins),
        onClose: {}
    )
}

#Preview("No wins") {
    CameraView(
        repository: MockCameraRepository(forceState: .noWins),
        onClose: {}
    )
}

#Preview("Maxed out") {
    CameraView(
        repository: MockCameraRepository(forceState: .maxedOut),
        onClose: {}
    )
}
