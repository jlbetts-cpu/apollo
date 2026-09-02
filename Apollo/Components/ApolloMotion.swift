//
//  ApolloMotion.swift
//  Apollo
//
//  The motion ladder.
//
//  Every animation in the app should name a rung here instead of inventing a
//  duration at the call site. Before this file there were fifteen distinct
//  curve/duration pairs across the codebase, most of them `.easeInOut`, which
//  is why the app moved like a prototype: nothing was related to anything else.
//
//  Rungs are ordered by how much travel the thing does, not by how important
//  it is. Pick the rung that matches the movement.
//

import SwiftUI

enum ApolloMotion {
    /// Tap acknowledgement — the press-down scale and its release. Short
    /// enough to read as a response to the finger rather than as an animation.
    static let press = Animation.easeOut(duration: 0.10)

    /// A control changing state in place: colour, opacity, selection. No
    /// travel, so no spring.
    static let state = Animation.easeOut(duration: 0.16)

    /// Something moving or resizing — rows reordering, a banner sliding in, a
    /// sheet settling. Overdamped so it arrives without wobbling.
    static let move = Animation.spring(response: 0.34, dampingFraction: 0.88)

    /// Something arriving with intent: the reaction picker, a count ticking
    /// up, a pill appearing. Looser damping gives a small deliberate overshoot.
    static let pop = Animation.spring(response: 0.28, dampingFraction: 0.68)

    /// Content dissolving in or out — skeleton to loaded, feed phase changes.
    static let reveal = Animation.easeInOut(duration: 0.30)

    /// Apple's default for a repositioned object (WWDC 2018, *Designing Fluid
    /// Interfaces*): critically damped, no overshoot. For anything that moves
    /// because of state, not because of a finger.
    static let settle = Animation.spring(response: 0.40, dampingFraction: 1.00)

    /// After a flick or a drag release *only*. The small overshoot is earned
    /// by the momentum the finger gave it; on a menu that merely appeared it
    /// would feel wrong.
    static let `throw` = Animation.spring(response: 0.40, dampingFraction: 0.80)

    /// Sheets and drawers.
    static let sheet = Animation.spring(response: 0.30, dampingFraction: 0.80)

    /// The single curve used when Reduce Motion is on: a cross-fade with no
    /// spring, no travel and no overshoot.
    static let reduced = Animation.easeInOut(duration: 0.20)

    /// Collapses any rung to `reduced` when the accessibility setting is on.
    static func resolved(_ animation: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? reduced : animation
    }
}

extension View {
    /// `.animation(_:value:)` that collapses to a cross-fade under Reduce
    /// Motion. Prefer this over the raw modifier anywhere the animation moves
    /// or scales something.
    func apolloAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(ApolloAnimationModifier(animation: animation, value: value))
    }

    /// A transition that degrades to a plain opacity fade under Reduce Motion.
    func apolloTransition(_ transition: AnyTransition) -> some View {
        modifier(ApolloTransitionModifier(transition: transition))
    }
}

private struct ApolloAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(
            ApolloMotion.resolved(animation, reduceMotion: reduceMotion),
            value: value
        )
    }
}

private struct ApolloTransitionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let transition: AnyTransition

    func body(content: Content) -> some View {
        content.transition(reduceMotion ? .opacity : transition)
    }
}
