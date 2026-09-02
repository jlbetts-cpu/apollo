//
//  ApolloOrb.swift
//  Apollo
//
//  DESIGN-SYSTEM §10.11, §8.4. A floating friend on the locked feed: a 48pt
//  avatar with a serif name under it, drifting ±6pt on a slow cycle.
//
//  The float is 8–12s a cycle. Apple flags ~5s (0.2Hz) as vestibular; this
//  stays well under it. Under Reduce Motion the orbs are still.
//

import SwiftUI

struct ApolloOrb: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floated = false

    let name: String
    var avatarURL: URL?
    var isYou: Bool = false
    /// Marks your own orb with a `+` — the affordance to add a win.
    var showsPlus: Bool = false
    /// Staggers the float so six orbs never move in lockstep.
    var index: Int = 0
    let action: () -> Void

    private let amplitude: CGFloat = 6
    private var period: Double { 8 + Double(index % 5) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: ApolloSpace.s) {
                ApolloAvatar(url: avatarURL, size: .orb)
                    .overlay(alignment: .bottomTrailing) {
                        if showsPlus {
                            Image(systemName: "plus")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(Color.apolloGround)
                                .frame(width: 12, height: 12)
                                .background(Color.apolloTextSoft, in: Circle())
                                .offset(x: 1, y: 1)
                        }
                    }
                Text(name)
                    .apolloText(isYou ? .nameSmallYou : .nameSmall)
                    .foregroundStyle(Color.apolloTextSoft)
                    .lineLimit(1)
            }
            .frame(minWidth: ApolloMetric.target, minHeight: ApolloMetric.target)
            .contentShape(Rectangle())
        }
        .buttonStyle(ApolloPressStyle(scale: 0.94, dim: 0.85, haptic: .select))
        .offset(y: reduceMotion ? 0 : (floated ? -amplitude : amplitude))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: period / 2)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.7)
            ) {
                floated = true
            }
        }
        .accessibilityLabel(isYou ? "You" : name)
    }
}
