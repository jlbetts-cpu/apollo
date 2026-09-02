//
//  ApolloPostHeader.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.9.
//

import SwiftUI

struct ApolloPostHeader: View {
    var avatarURL: URL?
    let name: String
    /// Handle, or "12 Wins" — whichever the screen shows under the name.
    let subtitle: String
    var winsCount: Int?
    var onPersonTap: () -> Void
    var onMoreTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: ApolloSpace.rowAvatarToText) {
            Button(action: onPersonTap) {
                HStack(spacing: ApolloSpace.rowAvatarToText) {
                    ApolloAvatar(url: avatarURL, size: .post)
                    VStack(alignment: .leading, spacing: ApolloSpace.xs) {
                        Text(name)
                            .apolloText(.name)
                            .foregroundStyle(Color.apolloText)
                        Text(subtitle)
                            .apolloText(.caption)
                            .foregroundStyle(Color.apolloSecondary)
                    }
                    .lineLimit(1)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.apollo)

            Spacer(minLength: ApolloSpace.xl)

            if let winsCount {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(winsCount)")
                        .apolloText(.numeral)
                        .foregroundStyle(Color.apolloSecondary)
                        .contentTransition(.numericText())
                        .apolloAnimation(ApolloMotion.pop, value: winsCount)
                    Text("Wins")
                        .apolloText(.label)
                        .foregroundStyle(Color.apolloTertiary)
                }
            }

            ApolloIconButton(glyph: .symbol("ellipsis"), label: "More", action: onMoreTap)
        }
        .frame(minHeight: ApolloMetric.row)
        .padding(.leading, ApolloSpace.screen)
        .padding(.trailing, ApolloSpace.m)
    }
}
