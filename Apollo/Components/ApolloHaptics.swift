//
//  ApolloHaptics.swift
//  Apollo
//
//  One vocabulary for touch feedback.
//
//  Before this file, haptics existed in four files out of 151 — the invite
//  card, two win-list view models and the photo viewer — so the core loops
//  (react, comment, switch tab, take a photo, complete a win) were silent.
//  Silence is the thing that makes an app feel like a web page.
//
//  Generators are retained and `prepare()`d rather than constructed at the
//  call site: a cold generator can take ~100ms to spin up the Taptic Engine,
//  which is long enough for the tap to feel late.
//

import UIKit

enum ApolloHaptics {
    /// What the feedback means, not which generator it uses. Call sites should
    /// describe the event; this file decides how it feels.
    enum Kind {
        /// A control was pressed. The lightest thing in the vocabulary.
        case tap
        /// A selection moved — tabs, segments, pickers.
        case select
        /// A real action landed: a reaction, a sent comment, a shutter.
        case commit
        /// Something completed that the user was working toward: a win marked
        /// done, a post published, a streak extended.
        case success
        /// A destructive or blocking outcome.
        case warning
        /// An action failed.
        case failure
    }

    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let selection = UISelectionFeedbackGenerator()
    private static let notification = UINotificationFeedbackGenerator()

    static func fire(_ kind: Kind) {
        switch kind {
        case .tap:
            lightImpact.impactOccurred()
            lightImpact.prepare()
        case .select:
            selection.selectionChanged()
            selection.prepare()
        case .commit:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        case .success:
            notification.notificationOccurred(.success)
            notification.prepare()
        case .warning:
            notification.notificationOccurred(.warning)
            notification.prepare()
        case .failure:
            notification.notificationOccurred(.error)
            notification.prepare()
        }
    }

    /// A soft, low-intensity bump for continuous gestures — paging a photo,
    /// crossing a snap point — where a full impact would be too loud.
    static func brush(intensity: CGFloat = 0.6) {
        softImpact.impactOccurred(intensity: intensity)
        softImpact.prepare()
    }

    /// Warm the Taptic Engine ahead of a surface where feedback is imminent.
    /// Cheap; call it in `onAppear` of the camera, the reaction picker, etc.
    static func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selection.prepare()
    }

    static func tap() { fire(.tap) }
    static func select() { fire(.select) }
    static func commit() { fire(.commit) }
    static func success() { fire(.success) }
    static func warning() { fire(.warning) }
    static func failure() { fire(.failure) }
}
