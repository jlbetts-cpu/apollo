//
//  ApolloPressStyle.swift
//  Apollo
//
//  Press feedback for every button in the app.
//
//  Every one of the app's 63 buttons was `.buttonStyle(.plain)`, which is
//  SwiftUI's "draw the label and nothing else" — no scale, no dim, no haptic.
//  Tapping anything produced no acknowledgement at all until the network came
//  back, so the whole app read as unresponsive even when it was fast.
//
//  This style keeps everything `.plain` gave us (no tint, no chrome, the label
//  renders exactly as written) and adds the acknowledgement back.
//

import SwiftUI

struct ApolloPressStyle: ButtonStyle {
    /// How far the label shrinks while held. Big targets can take less.
    var scale: CGFloat = 0.96
    /// Opacity while held.
    var dim: Double = 0.72
    /// Fired once on press-down, not on release, so it lands with the finger.
    var haptic: ApolloHaptics.Kind? = .tap

    func makeBody(configuration: Configuration) -> some View {
        PressBody(configuration: configuration, scale: scale, dim: dim, haptic: haptic)
    }

    // Named PressBody, not Body: `ButtonStyle` inherits an associated type
    // called `Body`, so a nested type with that name gets picked up as the
    // witness for it — and a private nested type can't satisfy a requirement
    // of an internal protocol conformance. Renaming lets Swift infer `Body`
    // from makeBody's return type, which is what we actually want.
    private struct PressBody: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @Environment(\.isEnabled) private var isEnabled

        let configuration: ButtonStyleConfiguration
        let scale: CGFloat
        let dim: Double
        let haptic: ApolloHaptics.Kind?

        var body: some View {
            configuration.label
                // Reduce Motion removes the travel but keeps the dim, so the
                // press is still acknowledged.
                .scaleEffect(reduceMotion || !configuration.isPressed ? 1 : scale)
                .opacity(configuration.isPressed ? dim : 1)
                // Deliberately no disabled dimming here: the shutter, the two
                // send buttons and the save button each already dim themselves,
                // and a second multiplier on top took them to ~0.2 opacity.
                .animation(ApolloMotion.press, value: configuration.isPressed)
                .onChange(of: configuration.isPressed) { _, pressed in
                    guard pressed, isEnabled, let haptic else { return }
                    ApolloHaptics.fire(haptic)
                }
        }
    }
}

extension ButtonStyle where Self == ApolloPressStyle {
    /// Default: text buttons, pills, cards. Scale plus dim plus a light tap.
    static var apollo: ApolloPressStyle { ApolloPressStyle() }

    /// Small icon buttons in a 44pt target. The glyph is small, so it needs a
    /// deeper scale and dim to register at all.
    static var apolloIcon: ApolloPressStyle {
        ApolloPressStyle(scale: 0.88, dim: 0.55, haptic: .tap)
    }

    /// Full-width rows and list cells. Scaling a full-bleed row looks like a
    /// bug, so this one only dims.
    static var apolloRow: ApolloPressStyle {
        ApolloPressStyle(scale: 1.0, dim: 0.55, haptic: .tap)
    }

    /// Tabs and segmented controls — selection feedback, not impact.
    static var apolloTab: ApolloPressStyle {
        ApolloPressStyle(scale: 0.97, dim: 0.7, haptic: .select)
    }

    /// The primary action on a screen: sign in, continue, save, capture. The
    /// heavier haptic marks it as a commitment.
    static var apolloPrimary: ApolloPressStyle {
        ApolloPressStyle(scale: 0.97, dim: 0.85, haptic: .commit)
    }

    /// Non-committal affordances layered over content (photo taps, overlay
    /// chrome) where a haptic on every touch would be noise.
    static var apolloSilent: ApolloPressStyle {
        ApolloPressStyle(scale: 0.98, dim: 0.8, haptic: nil)
    }

    /// Photo and media surfaces: no scale (it would crop the image edge) and a
    /// gentle dim only.
    static var apolloMedia: ApolloPressStyle {
        ApolloPressStyle(scale: 1.0, dim: 0.86, haptic: nil)
    }
}
