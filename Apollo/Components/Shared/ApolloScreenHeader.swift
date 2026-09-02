//
//  ApolloScreenHeader.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.1. The top row of every root screen: the wordmark or a
//  `display` title on the left, up to two icon buttons on the right.
//
//  Figma places this 64pt from the screen top on a 48pt status bar, i.e.
//  16pt below the safe area. Devices differ in status-bar height, so the
//  safe-area-relative value is the one that matches the design everywhere.
//

import SwiftUI

struct ApolloScreenHeader<Trailing: View>: View {
    enum Leading {
        case wordmark
        case title(String)
    }

    let leading: Leading
    @ViewBuilder let trailing: () -> Trailing

    init(_ leading: Leading, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.leading = leading
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            leadingView
            Spacer(minLength: ApolloSpace.xl)
            HStack(spacing: ApolloSpace.l) {
                trailing()
            }
        }
        .frame(minHeight: ApolloMetric.headerHeight)
        .padding(.horizontal, ApolloSpace.screen)
        .padding(.top, ApolloSpace.xl)
    }

    @ViewBuilder
    private var leadingView: some View {
        switch leading {
        case .wordmark:
            Image("ApolloWordmark")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(height: 48)
                .accessibilityLabel("Apollo")
        case .title(let text):
            Text(text)
                .apolloText(.display)
                .foregroundStyle(Color.apolloPrimaryText)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

extension ApolloScreenHeader where Trailing == EmptyView {
    init(_ leading: Leading) {
        self.leading = leading
        self.trailing = { EmptyView() }
    }
}
