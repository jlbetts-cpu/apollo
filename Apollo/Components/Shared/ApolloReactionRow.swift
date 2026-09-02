//
//  ApolloReactionRow.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.8. The mockups drew this four slightly different ways;
//  this is the one.
//

import SwiftUI

struct ApolloReactionRow: View {
    var reactorAvatars: [URL?]
    /// The first reactor's name, in serif.
    var leadName: String?
    var otherCount: Int
    var onReactionsTap: () -> Void
    var onCommentTap: () -> Void
    var onReactTap: () -> Void

    var body: some View {
        HStack(spacing: ApolloSpace.m) {
            Button(action: onReactionsTap) {
                HStack(spacing: ApolloSpace.m + 1) {
                    if !reactorAvatars.isEmpty {
                        ApolloAvatarStack(urls: reactorAvatars)
                    }
                    summary
                    Spacer(minLength: 0)
                }
                .frame(minHeight: ApolloMetric.target)
                .contentShape(Rectangle())
            }
            .buttonStyle(.apolloRow)

            ApolloIconButton(glyph: .asset("IconMessageCirclePlus"), label: "Comment", action: onCommentTap)
            ApolloIconButton(glyph: .asset("IconSmilePlus"), label: "React", action: onReactTap)
        }
        .padding(.leading, ApolloSpace.screen)
        .padding(.trailing, ApolloSpace.m)
    }

    @ViewBuilder
    private var summary: some View {
        if let leadName {
            HStack(alignment: .firstTextBaseline, spacing: ApolloSpace.s) {
                Text(leadName)
                    .apolloText(.name)
                    .foregroundStyle(Color.apolloText)
                Text(otherCount > 0 ? "& \(otherCount) others reacted" : "reacted")
                    .apolloText(.caption)
                    .foregroundStyle(Color.apolloSecondary)
            }
            .lineLimit(1)
        }
    }
}
