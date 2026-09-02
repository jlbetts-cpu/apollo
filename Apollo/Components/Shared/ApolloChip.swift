//
//  ApolloChip.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.6. A selectable toggle in a row: Full · Classic · New.
//

import SwiftUI

struct ApolloChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .apolloText(.heading)
                .foregroundStyle(Color.apolloText)
                .padding(.horizontal, ApolloSpace.l)
                .padding(.vertical, 5)
                .background(Color.apolloGround, in: RoundedRectangle(cornerRadius: ApolloRadius.control, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ApolloRadius.control, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.apolloTextSoft : Color.apolloHairline,
                            lineWidth: isSelected ? 2 : ApolloMetric.hairline
                        )
                )
                .frame(minHeight: ApolloMetric.target)
                .contentShape(Rectangle())
        }
        .buttonStyle(.apolloTab)
        .apolloAnimation(ApolloMotion.state, value: isSelected)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
