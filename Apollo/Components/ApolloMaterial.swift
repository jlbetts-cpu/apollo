//
//  ApolloMaterial.swift
//  Apollo
//
//  Glass. Read docs/DESIGN-SYSTEM.md §7.
//
//  Glass is for floating chrome over photos — the viewfinder's control
//  strip, the photo viewer's buttons, the tab bar — and nowhere else. On the
//  ground it is just a lighter gray with extra GPU work.
//
//  Three branches:
//    - Reduce Transparency on: solid `apolloRaised` + hairline.
//    - iOS 26+: the system Liquid Glass. Using the real thing is the only way
//      it refracts, catches light and morphs like the rest of the OS.
//    - iOS 17–18: ultraThinMaterial + hairline, which is what the Figma
//      `backdrop-blur 8 · rgba(8,8,8,.01) · #CECECE 0.2px` was drawing.
//

import SwiftUI

enum ApolloGlassShape {
    case control   // ApolloRadius.control
    case object    // ApolloRadius.object
    case capsule

    fileprivate var radius: CGFloat {
        switch self {
        case .control: return ApolloRadius.control
        case .object:  return ApolloRadius.object
        case .capsule: return 999
        }
    }
}

extension View {
    func apolloGlass(_ shape: ApolloGlassShape = .control) -> some View {
        modifier(ApolloGlassModifier(shape: shape))
    }

    /// The one hairline (§1.4), in the given shape.
    func apolloHairline(radius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.apolloHairline, lineWidth: ApolloMetric.hairline)
        )
    }
}

private struct ApolloGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let shape: ApolloGlassShape

    @ViewBuilder
    func body(content: Content) -> some View {
        let rect = RoundedRectangle(cornerRadius: shape.radius, style: .continuous)
        if reduceTransparency {
            content
                .background(Color.apolloRaised, in: rect)
                .apolloHairline(radius: shape.radius)
        } else {
            glass(content, in: rect)
        }
    }

    @ViewBuilder
    private func glass(_ content: Content, in rect: RoundedRectangle) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26, *) {
            content.glassEffect(.regular, in: rect)
        } else {
            content
                .background(.ultraThinMaterial, in: rect)
                .apolloHairline(radius: shape.radius)
        }
        #else
        content
            .background(.ultraThinMaterial, in: rect)
            .apolloHairline(radius: shape.radius)
        #endif
    }
}
