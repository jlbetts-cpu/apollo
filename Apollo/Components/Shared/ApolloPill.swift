//
//  ApolloPill.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.5. Two looks, never a third. The visible pill is
//  smaller than 44pt; the hit area is not.
//

import SwiftUI

struct ApolloPill: View {
    enum Look {
        /// Light on dark — the committing action: Accept.
        case solid
        /// Dark on darker — the optional action: Invite.
        case quiet
    }

    let title: String
    var look: Look = .quiet
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .apolloText(.bodyMedium)
                .foregroundStyle(look == .solid ? Color.apolloRaised : Color.apolloPrimaryText)
                .padding(.horizontal, ApolloSpace.l)
                .padding(.vertical, 6)
                .background(
                    look == .solid ? Color.apolloPrimaryText : Color.apolloRaised,
                    in: Capsule()
                )
                .frame(minHeight: ApolloMetric.target)
                .contentShape(Rectangle())
        }
        .buttonStyle(look == .solid ? .apolloPrimary : .apollo)
    }
}
