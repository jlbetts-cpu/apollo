//
//  ApolloSearchField.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.10.
//

import SwiftUI

struct ApolloSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: ApolloSpace.l) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: ApolloMetric.iconSmall, weight: .light))
                .foregroundStyle(Color.apolloSecondary)
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.apolloSecondary))
                .apolloText(.body)
                .foregroundStyle(Color.apolloText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, ApolloSpace.xl)
        .frame(minHeight: ApolloMetric.target)
        .background(Color.apolloRaised, in: RoundedRectangle(cornerRadius: ApolloRadius.control, style: .continuous))
        .apolloHairline(radius: ApolloRadius.control)
        .padding(.horizontal, ApolloSpace.screen)
    }
}
