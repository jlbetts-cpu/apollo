//
//  ApolloCountdown.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.12. The sunset clock. Lining tabular figures so the
//  digits tick without the layout breathing; colons one step quieter than
//  the digits, as in Figma.
//

import SwiftUI

struct ApolloCountdown: View {
    /// The moment the feed unlocks. When it has passed, shows "Unlocked".
    let unlockDate: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = max(0, unlockDate.timeIntervalSince(context.date))
            VStack(spacing: ApolloSpace.m) {
                Text("Wins unlock @ sunset")
                    .apolloText(.caption)
                    .foregroundStyle(Color.apolloSecondary)

                if remaining > 0 {
                    clock(remaining)
                        .contentTransition(.numericText(countsDown: true))
                        .apolloAnimation(ApolloMotion.state, value: Int(remaining))
                } else {
                    Text("Unlocked")
                        .apolloText(.title)
                        .foregroundStyle(Color.apolloText)
                        .apolloTransition(.opacity)
                }

                Text(unlockDate, format: .dateTime.hour().minute())
                    .apolloText(.caption)
                    .foregroundStyle(Color.apolloSecondary)
            }
            .apolloAnimation(ApolloMotion.reveal, value: remaining > 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func clock(_ seconds: TimeInterval) -> some View {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return (
            Text(String(h)).foregroundStyle(Color.apolloText)
            + Text(":").foregroundStyle(Color.apolloSecondary)
            + Text(String(format: "%02d", m)).foregroundStyle(Color.apolloText)
            + Text(":").foregroundStyle(Color.apolloSecondary)
            + Text(String(format: "%02d", s)).foregroundStyle(Color.apolloText)
        )
        .apolloText(.countdown)
    }
}
