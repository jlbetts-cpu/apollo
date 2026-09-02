//
//  ApolloIconButton.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.3. A 24pt glyph in a 44pt target. `onGlass` wraps it
//  in the control-shape material and lifts the tint one step (§7.2).
//

import SwiftUI

struct ApolloIconButton: View {
    enum Glyph {
        /// A Lucide asset in Assets.xcassets, e.g. "IconBell".
        case asset(String)
        /// An SF Symbol, used only where Lucide has no equivalent (§6).
        case symbol(String)
    }

    let glyph: Glyph
    let label: String
    var onGlass: Bool = false
    let action: () -> Void

    var body: some View {
        if onGlass {
            button.apolloGlass(.control)
        } else {
            button
        }
    }

    private var button: some View {
        Button(action: action) {
            glyphView
                .foregroundStyle(onGlass ? Color.apolloTextSoft : Color.apolloPrimaryText)
                .frame(width: ApolloMetric.target, height: ApolloMetric.target)
                .contentShape(Rectangle())
        }
        .buttonStyle(.apolloIcon)
        .accessibilityLabel(label)
    }

    @ViewBuilder
    private var glyphView: some View {
        switch glyph {
        case .asset(let name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: ApolloMetric.icon, height: ApolloMetric.icon)
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: ApolloMetric.icon - 2, weight: .light))
                .frame(width: ApolloMetric.icon, height: ApolloMetric.icon)
        }
    }
}
