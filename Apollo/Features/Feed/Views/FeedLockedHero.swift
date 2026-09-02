//
//  FeedLockedHero.swift
//  Apollo
//
//  DESIGN-SYSTEM §11.3. The locked feed's hero: a ground glow anchored at
//  the bottom, the sunset countdown, and your people floating around it.
//  478pt tall on a 402pt frame — the height is Figma's and is not on the
//  spacing grid on purpose; it is sized to the glow, not to the type.
//
//  Orb positions are the Figma frame's, as fractions of the hero, so they
//  hold their composition at any width. Five positions; more people than
//  that cycle through them with a small offset.
//
//  Guest mode: long-press the countdown to pull the unlock to three seconds
//  away and watch the choreography; long-press again after to re-lock.
//

import SwiftUI

struct OrbPerson: Identifiable, Hashable {
    let id: UUID
    let name: String
    let avatarURL: URL?
    let isYou: Bool
}

struct FeedLockedHero: View {
    @EnvironmentObject private var sunsetClock: SunsetClock

    let people: [OrbPerson]
    var onPersonTap: (OrbPerson) -> Void

    /// Figma orb centres as fractions of the 402×478 hero.
    private static let slots: [CGPoint] = [
        CGPoint(x: 0.30, y: 0.08),
        CGPoint(x: 0.75, y: 0.21),
        CGPoint(x: 0.81, y: 0.42),
        CGPoint(x: 0.21, y: 0.54),
        CGPoint(x: 0.63, y: 0.69),
    ]
    private static let height: CGFloat = 478

    var body: some View {
        ZStack {
            glow

            GeometryReader { geo in
                ApolloCountdown(unlockDate: sunsetClock.unlockDate)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.40)
                    .onLongPressGesture(minimumDuration: 0.8) {
                        guard ApolloRepositories.isGuest else { return }
                        if sunsetClock.isUnlocked { sunsetClock.debugRelock() } else { sunsetClock.debugUnlock() }
                        ApolloHaptics.commit()
                    }

                ForEach(Array(people.prefix(10).enumerated()), id: \.element.id) { index, person in
                    let slot = Self.slots[index % Self.slots.count]
                    let lap = CGFloat(index / Self.slots.count) * 0.06
                    ApolloOrb(
                        name: person.isYou ? "You" : person.name,
                        avatarURL: person.avatarURL,
                        isYou: person.isYou,
                        showsPlus: person.isYou,
                        index: index,
                        action: { onPersonTap(person) }
                    )
                    .position(
                        x: geo.size.width * min(0.92, slot.x + lap),
                        y: geo.size.height * min(0.92, slot.y + lap)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .clipped()
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.apolloHairline)
                .frame(height: ApolloMetric.hairline)
        }
        .accessibilityElement(children: .contain)
    }

    /// Figma: radial gradient from the bottom centre, gray 300 at the core
    /// to the ground at the edge, blurred 2pt.
    private var glow: some View {
        RadialGradient(
            stops: [
                .init(color: Color.apolloGray300,               location: 0.00),
                .init(color: Color.apolloGray500.opacity(0.75), location: 0.25),
                .init(color: Color.apolloGray600.opacity(0.50), location: 0.50),
                .init(color: Color.apolloGray800.opacity(0.25), location: 0.75),
                .init(color: Color.apolloGround.opacity(0.00),  location: 1.00),
            ],
            center: UnitPoint(x: 0.5, y: 1.22),
            startRadius: 0,
            endRadius: Self.height * 0.98
        )
        .blur(radius: 2)
        .allowsHitTesting(false)
    }
}
