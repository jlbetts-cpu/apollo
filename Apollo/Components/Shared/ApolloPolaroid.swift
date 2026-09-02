//
//  ApolloPolaroid.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.7. What a photo looks like whenever it is shown whole:
//  a 5pt ground-coloured frame at `object` radius, the wordmark bottom-right
//  at 80%. Used by the Find albums, the viewer's Classic mode, Develop.
//
//  Polaroids are one of the two things in the app allowed to cast a shadow
//  (§7.1) — they are prints lying on a table. Pass `shadow: true` only when
//  the print is in a stack on the Find screen.
//

import SwiftUI

struct ApolloPolaroid<Photo: View>: View {
    private let frameWidth: CGFloat = 5
    var showWordmark: Bool = true
    var shadow: Bool = false
    @ViewBuilder let photo: () -> Photo

    var body: some View {
        photo()
            .clipShape(RoundedRectangle(cornerRadius: ApolloRadius.object - frameWidth, style: .continuous))
            .padding(frameWidth)
            .background(
                Color.apolloGround,
                in: RoundedRectangle(cornerRadius: ApolloRadius.object, style: .continuous)
            )
            .overlay(alignment: .bottomTrailing) {
                if showWordmark {
                    Image("ApolloWordmark")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 22)
                        .opacity(0.8)
                        .padding(ApolloSpace.xl)
                        .accessibilityHidden(true)
                }
            }
            .shadow(color: shadow ? Color.black.opacity(0.15) : .clear, radius: 6, x: 0, y: 4)
    }
}

/// The tilts a stack of prints sits at (§8.4).
enum ApolloTilt {
    /// The three thumbnails beside the shutter, back to front.
    static let shutterStack: [Double] = [-12, 4, 17]
    /// An album stack on Find, back to front.
    static let albumStack: [Double] = [2.3, 0, 0]
    /// Opacity of each print in an album stack, back to front.
    static let albumOpacity: [Double] = [0.5, 0.8, 1.0]
}
