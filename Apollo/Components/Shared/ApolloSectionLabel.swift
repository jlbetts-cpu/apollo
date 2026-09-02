//
//  ApolloSectionLabel.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.2. Uppercase is applied by the `label` role — write
//  the string in sentence case.
//

import SwiftUI

struct ApolloSectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .apolloText(.label)
            .foregroundStyle(Color.apolloSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ApolloSpace.screen)
            .padding(.bottom, ApolloSpace.labelToContent)
            .accessibilityAddTraits(.isHeader)
    }
}
