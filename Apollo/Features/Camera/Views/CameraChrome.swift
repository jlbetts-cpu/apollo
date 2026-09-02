//
//  CameraChrome.swift
//  Apollo
//
//  The camera's chrome, built from Figma `Camera-notset` (13646:7517) and
//  DESIGN-SYSTEM §11.2. Three pieces:
//
//    CameraTopBar      — wordmark top-left, glass chevron top-right, over
//                        the viewfinder.
//    CameraControlStrip — under the viewfinder: flash · "Add a win ^" · flip.
//    CameraShutterRow  — the shutter centred, today's prints stacked at the
//                        right margin.
//
//  Nothing here casts a shadow, nothing is italic, and the only serif is
//  the 24pt win title — a header, so it qualifies (§2.1).
//

import SwiftUI

// MARK: - Top bar

struct CameraTopBar: View {
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Image("ApolloWordmark")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .accessibilityLabel("Apollo")
            Spacer(minLength: ApolloSpace.xl)
            ApolloIconButton(glyph: .asset("IconChevronDown"), label: "Close camera", onGlass: true, action: onClose)
        }
        .padding(.horizontal, ApolloSpace.screen)
        .padding(.top, ApolloSpace.xl)
    }
}

// MARK: - Control strip

struct CameraControlStrip: View {
    let flash: CameraFlashMode
    let activeWin: Win?
    let isFlipping: Bool
    let onToggleFlash: () -> Void
    let onTapWin: () -> Void
    let onFlip: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            flashButton
            Spacer(minLength: ApolloSpace.m)
            winButton
            Spacer(minLength: ApolloSpace.m)
            flipButton
        }
        .padding(.horizontal, ApolloSpace.screen + ApolloSpace.m)
        .frame(minHeight: 52)
    }

    private var flashButton: some View {
        Button(action: onToggleFlash) {
            Image(systemName: flashSymbol)
                .font(.system(size: ApolloMetric.icon - 2, weight: .light))
                .foregroundStyle(flashTint)
                .frame(width: ApolloMetric.target, height: ApolloMetric.target)
                .contentShape(Rectangle())
        }
        .buttonStyle(.apolloIcon)
        .apolloAnimation(ApolloMotion.state, value: flash)
        .accessibilityLabel("\(flash.voiceOverLabel). Double tap to change.")
    }

    private var flashSymbol: String {
        switch flash {
        case .off:  return "bolt.slash"
        case .on:   return "bolt.fill"
        case .auto: return "bolt.badge.automatic"
        }
    }

    private var flashTint: Color {
        switch flash {
        case .off:  return .apolloTertiary
        case .on:   return .apolloText
        case .auto: return .apolloFlashAuto
        }
    }

    private var winButton: some View {
        Button(action: onTapWin) {
            HStack(alignment: .firstTextBaseline, spacing: ApolloSpace.m) {
                Text(activeWin?.name ?? "Add a win")
                    .apolloText(.title)
                    .foregroundStyle(Color.apolloText)
                    .lineLimit(1)
                if let win = activeWin, win.currentStreak > 0 {
                    Text("\(win.currentStreak)d")
                        .apolloText(.caption)
                        .foregroundStyle(Color.apolloSecondary)
                }
                Image(systemName: "chevron.up")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.apolloText)
            }
            .frame(minHeight: ApolloMetric.target)
            .contentShape(Rectangle())
        }
        .buttonStyle(.apollo)
        .accessibilityLabel(activeWin.map { "Shooting for \($0.name)" } ?? "Add a win")
        .accessibilityHint("Opens your wins")
    }

    private var flipButton: some View {
        Button(action: onFlip) {
            Image("IconCameraFlip")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: ApolloMetric.icon, height: ApolloMetric.icon)
                .foregroundStyle(Color.apolloText)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : (isFlipping ? 180 : 0)), axis: (x: 0, y: 1, z: 0))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: isFlipping)
                .frame(width: ApolloMetric.target, height: ApolloMetric.target)
                .contentShape(Rectangle())
        }
        .buttonStyle(.apolloIcon)
        .accessibilityLabel("Switch camera")
    }
}

// MARK: - Shutter row

struct CameraShutterRow: View {
    let isPressed: Bool
    let isDisabled: Bool
    let photoCount: Int
    let thumbnailURL: URL?
    let onShutter: () -> Void

    var body: some View {
        ZStack {
            shutter
            HStack {
                Spacer()
                if photoCount > 0 {
                    printStack
                        .accessibilityLabel("Today's photos, \(photoCount)")
                }
            }
            .padding(.trailing, ApolloSpace.screen + ApolloSpace.s)
        }
        .frame(height: 96)
    }

    /// Figma: 80pt ring, 1pt `#E6E6E6`; 66pt disc, same colour. Press-down
    /// shrinks the disc on the hand-tuned `spring(response: 0.1)` from the
    /// view model — not on the ladder, on purpose (§8.2).
    private var shutter: some View {
        Button(action: onShutter) {
            ZStack {
                Circle()
                    .strokeBorder(Color.apolloText, lineWidth: 1)
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(isDisabled ? Color.apolloTertiary : Color.apolloText)
                    .frame(width: isPressed ? 60 : 66, height: isPressed ? 60 : 66)
                    .animation(.spring(response: 0.1), value: isPressed)
            }
            .frame(width: 88, height: 88)
            .contentShape(Circle())
        }
        .buttonStyle(ApolloPressStyle(scale: 1.0, dim: 1.0, haptic: .commit))
        .disabled(isDisabled)
        .accessibilityLabel(isDisabled ? "Daily photo limit reached" : "Take photo")
    }

    /// Three 37×39 prints at Figma's tilts, 19pt apart, hairline-edged.
    private var printStack: some View {
        ZStack {
            ForEach(Array(ApolloTilt.shutterStack.enumerated()), id: \.offset) { index, tilt in
                print(index: index)
                    .rotationEffect(.degrees(tilt))
                    .offset(x: CGFloat(index - 1) * 19)
            }
        }
        .frame(width: 84, height: 48)
    }

    @ViewBuilder
    private func print(index: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: ApolloRadius.thumbnail, style: .continuous)
        Group {
            if index < photoCount, let thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Color.apolloSurface
                    }
                }
            } else {
                Color.apolloSurface
            }
        }
        .frame(width: 37, height: 39)
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.apolloHairline, lineWidth: ApolloMetric.hairline))
    }
}

// MARK: - Viewfinder helpers

/// Rule-of-thirds grid, hairline weight.
struct CameraThirdsGrid: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width, h = geo.size.height
                for f in [1.0 / 3.0, 2.0 / 3.0] {
                    path.move(to: CGPoint(x: w * f, y: 0));  path.addLine(to: CGPoint(x: w * f, y: h))
                    path.move(to: CGPoint(x: 0, y: h * f));  path.addLine(to: CGPoint(x: w, y: h * f))
                }
            }
            .stroke(Color.apolloHairline, lineWidth: ApolloMetric.hairline)
        }
        .allowsHitTesting(false)
    }
}
