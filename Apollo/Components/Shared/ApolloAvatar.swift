//
//  ApolloAvatar.swift
//  Apollo
//
//  DESIGN-SYSTEM §5.1, §10.4. Always a circle, sizes from the ladder,
//  `apolloSurface` when empty — never initials, never a glyph.
//

import Kingfisher
import SwiftUI

struct ApolloAvatar: View {
    var url: URL?
    var size: ApolloAvatarSize
    /// The 1pt ground-coloured ring used when avatars overlap in a stack.
    var ring: Bool = false

    var body: some View {
        Group {
            if let url {
                KFImage(url)
                    .resizable()
                    .placeholder { Color.apolloSurface }
                    .scaledToFill()
            } else {
                Color.apolloSurface
            }
        }
        .frame(width: size.rawValue, height: size.rawValue)
        .clipShape(Circle())
        .overlay {
            if ring {
                Circle().strokeBorder(Color.apolloGround, lineWidth: 1)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Overlapping reactor stack: 16pt avatars, −2 overlap, ringed (§5.1).
struct ApolloAvatarStack: View {
    var urls: [URL?]
    var max: Int = 3

    var body: some View {
        HStack(spacing: -2) {
            ForEach(Array(urls.prefix(max).enumerated()), id: \.offset) { _, url in
                ApolloAvatar(url: url, size: .stack, ring: true)
            }
        }
    }
}
