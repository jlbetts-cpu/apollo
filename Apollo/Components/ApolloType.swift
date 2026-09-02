//
//  ApolloType.swift
//  Apollo
//
//  Typography. Read docs/DESIGN-SYSTEM.md §2.
//
//  Two families, two weights each, eleven roles. A role owns its size,
//  weight, tracking, leading and case, so a feature file never sets any of
//  those — it writes `.apolloText(.name)` and is done.
//
//  Cormorant Garamond ships as two variable fonts; iOS registers each named
//  instance under its own PostScript name (verified from the fonts' fvar
//  tables), so `CormorantGaramond-SemiBold` resolves without any weight axis
//  plumbing.
//

import CoreText
import SwiftUI
import UIKit

enum ApolloTextRole: CaseIterable {
    case display        // "Find." — one per screen
    case title          // "Add a win", the viewer's name, sheet titles
    case heading        // album titles, Full · Classic · New
    case name           // every person's name in a row or header — SF Pro Medium
    case nameSmall      // orb labels — SF Pro Medium
    case nameSmallYou   // same as nameSmall; kept so call sites compile. There is no italic in the app.
    case body           // captions, placeholders, button text
    case bodyMedium     // viewer title, primary pill labels
    case caption        // "12 Wins", timestamps, "& 12 others"
    case label          // UPPERCASE section labels
    case numeral        // wins count in a post header
    case countdown      // the sunset clock
}

extension ApolloTextRole {
    fileprivate enum Family { case sans, serif }
    fileprivate struct Spec {
        let family: Family
        let size: CGFloat
        let weight: Font.Weight     // sans only
        let serifWeight: CGFloat    // serif only — 'wght' axis value
        let tracking: CGFloat
        let lineHeightMultiple: CGFloat
        let uppercase: Bool
        let relativeTo: Font.TextStyle
    }

    fileprivate var spec: Spec {
        switch self {
        case .display:      return Spec(family: .serif, size: 48, weight: .regular, serifWeight: ApolloSerif.regular,          tracking: -0.96, lineHeightMultiple: 1.00, uppercase: false, relativeTo: .largeTitle)
        case .title:        return Spec(family: .serif, size: 24, weight: .regular, serifWeight: ApolloSerif.semibold,        tracking: -0.48, lineHeightMultiple: 1.10, uppercase: false, relativeTo: .title2)
        case .heading:      return Spec(family: .serif, size: 20, weight: .regular, serifWeight: ApolloSerif.semibold,        tracking: -0.30, lineHeightMultiple: 1.15, uppercase: false, relativeTo: .title3)
        case .name:         return Spec(family: .sans,  size: 16, weight: .medium,  serifWeight: 0,                                                     tracking: -0.32, lineHeightMultiple: 1.20, uppercase: false, relativeTo: .body)
        case .nameSmall:    return Spec(family: .sans,  size: 12, weight: .medium,  serifWeight: 0,                                                     tracking:  0.00, lineHeightMultiple: 1.20, uppercase: false, relativeTo: .caption)
        case .nameSmallYou: return Spec(family: .sans,  size: 12, weight: .medium,  serifWeight: 0,                                                     tracking:  0.00, lineHeightMultiple: 1.20, uppercase: false, relativeTo: .caption)
        case .body:         return Spec(family: .sans,  size: 16, weight: .regular, serifWeight: 0,                                                     tracking: -0.32, lineHeightMultiple: 1.30, uppercase: false, relativeTo: .body)
        case .bodyMedium:   return Spec(family: .sans,  size: 16, weight: .medium,  serifWeight: 0,                                                     tracking: -0.32, lineHeightMultiple: 1.30, uppercase: false, relativeTo: .body)
        case .caption:      return Spec(family: .sans,  size: 12, weight: .regular, serifWeight: 0,                                                     tracking: -0.24, lineHeightMultiple: 1.30, uppercase: false, relativeTo: .caption)
        case .label:        return Spec(family: .sans,  size: 10, weight: .regular, serifWeight: 0,                                                     tracking:  0.50, lineHeightMultiple: 1.00, uppercase: true,  relativeTo: .caption2)
        case .numeral:      return Spec(family: .sans,  size: 20, weight: .medium,  serifWeight: 0,                                                     tracking:  0.00, lineHeightMultiple: 1.00, uppercase: false, relativeTo: .title3)
        case .countdown:    return Spec(family: .serif, size: 40, weight: .regular, serifWeight: ApolloSerif.regular,          tracking:  0.00, lineHeightMultiple: 1.00, uppercase: false, relativeTo: .largeTitle)
        }
    }
}

/// Resolving the serif.
///
/// The bundled Cormorant is a **variable** font. iOS registers a variable
/// font's family plus its *default instance* only — here that is
/// `CormorantGaramond-Light`. Asking `Font.custom` for
/// "CormorantGaramond-SemiBold" does not fail loudly; it silently returns the
/// system font. That is what shipped through 69d70d8: every serif in the app
/// was rendering as SF Pro and nothing said so.
///
/// So we take the one face iOS did register and move its `wght` axis. This is
/// the only reliable way to reach a named weight of a variable font on iOS.
enum ApolloSerif {
    /// The single PostScript name iOS actually exposes for the bundled file.
    static let registeredName = "CormorantGaramond-Light"

    /// The OpenType 'wght' axis, as the four-byte tag CoreText wants.
    private static let weightAxis = 0x77676874

    static let regular: CGFloat = 400
    static let semibold: CGFloat = 600

    /// True when the bundled face registered. Checked at launch in DEBUG so a
    /// missing font can never again be invisible (see ApolloFontCheck).
    static var isAvailable: Bool { UIFont(name: registeredName, size: 12) != nil }

    static func uiFont(size: CGFloat, weight: CGFloat) -> UIFont {
        guard let base = UIFont(name: registeredName, size: size) else {
            return .systemFont(ofSize: size, weight: weight >= semibold ? .semibold : .regular)
        }
        let key = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let variations: [Int: CGFloat] = [weightAxis: weight]
        return UIFont(descriptor: base.fontDescriptor.addingAttributes([key: variations]), size: size)
    }
}

extension Font {
    /// The font for a role, scaled with Dynamic Type. Prefer the view
    /// modifier `.apolloText(_:)`, which also applies tracking and case.
    static func apollo(_ role: ApolloTextRole) -> Font {
        let s = role.spec
        switch role {
        case .countdown:
            return Font(ApolloTypeSupport.tabularLiningSerif(size: s.size, relativeTo: s.relativeTo))
        case .numeral:
            // Tabular figures so "9" → "10" doesn't shift the layout.
            return .system(size: ApolloTypeSupport.scaled(s.size, s.relativeTo), weight: s.weight, design: .default).monospacedDigit()
        default:
            switch s.family {
            case .sans:
                return .system(size: ApolloTypeSupport.scaled(s.size, s.relativeTo), weight: s.weight, design: .default)
            case .serif:
                return Font(ApolloSerif.uiFont(
                    size: ApolloTypeSupport.scaled(s.size, s.relativeTo),
                    weight: s.serifWeight
                ))
            }
        }
    }
}

extension View {
    /// Applies a type role in full: font, tracking, case and leading.
    /// This is the only way feature code should set type.
    func apolloText(_ role: ApolloTextRole) -> some View {
        modifier(ApolloTextModifier(role: role))
    }
}

private struct ApolloTextModifier: ViewModifier {
    let role: ApolloTextRole
    func body(content: Content) -> some View {
        let s = role.spec
        content
            .font(.apollo(role))
            .tracking(s.tracking)
            .textCase(s.uppercase ? .uppercase : nil)
            .lineSpacing(max(0, (s.lineHeightMultiple - 1.0) * s.size * 0.5))
    }
}

enum ApolloTypeSupport {
    /// Dynamic Type scaling for the system face. `Font.system(size:)` is
    /// fixed-size on its own; running the size through UIFontMetrics makes it
    /// follow the user's text-size setting.
    static func scaled(_ size: CGFloat, _ style: Font.TextStyle) -> CGFloat {
        UIFontMetrics(forTextStyle: uiStyle(style)).scaledValue(for: size)
    }

    /// Cormorant with lining (cap-height) and tabular figures switched on, so
    /// the countdown reads like a clock and its digits don't jitter as they
    /// tick. Falls back to the system serif if the font isn't registered.
    static func tabularLiningSerif(size: CGFloat, relativeTo style: Font.TextStyle) -> UIFont {
        let scaledSize = scaled(size, style)
        let base = ApolloSerif.uiFont(size: scaledSize, weight: ApolloSerif.regular)
        let features: [[UIFontDescriptor.FeatureKey: Int]] = [
            [.type: kNumberCaseType,    .selector: kUpperCaseNumbersSelector],
            [.type: kNumberSpacingType, .selector: kMonospacedNumbersSelector],
        ]
        let descriptor = base.fontDescriptor.addingAttributes([.featureSettings: features])
        return UIFont(descriptor: descriptor, size: scaledSize)
    }

    private static func uiStyle(_ style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title:      return .title1
        case .title2:     return .title2
        case .title3:     return .title3
        case .headline:   return .headline
        case .subheadline: return .subheadline
        case .callout:    return .callout
        case .footnote:   return .footnote
        case .caption:    return .caption1
        case .caption2:   return .caption2
        default:          return .body
        }
    }
}

// MARK: - Bridges for screens not yet rebuilt.
//
// These keep the existing 150+ call sites compiling and, importantly, move
// them onto Cormorant Garamond today so the whole app changes face at once
// rather than screen by screen. They are fixed-size on purpose: the screens
// that use them have fixed-height layouts that Dynamic Type would break.
// New code uses `.apolloText(_:)`. Delete these when the last caller goes.

extension Font {
    /// The rule (DESIGN-SYSTEM §2.1): the serif is for titles and headers,
    /// which means 20pt and up. Below that, everything is SF Pro.
    ///
    /// These two are a BRIDGE, not an API. They exist only so the screens
    /// that have not been rebuilt yet keep compiling, and every call site is
    /// a screen still owing a rebuild. Do not call them from new code; use
    /// `.apolloText(_:)`. When the last caller is gone, delete them.
    ///
    /// They were called `goudyItalic` / `goudyRegular` and the first one
    /// really did render italic — at every size from 11 to 28, as a general
    /// "make it nice". There is no italic in Apollo (§2.4).
    private static func bridge(_ size: CGFloat, emphasis: Bool) -> Font {
        if size >= 36 { return Font(ApolloSerif.uiFont(size: size, weight: ApolloSerif.regular)) }
        if size >= 20 { return Font(ApolloSerif.uiFont(size: size, weight: ApolloSerif.semibold)) }
        return .system(size: size, weight: emphasis ? .medium : .regular, design: .default)
    }
    static func legacyEmphasis(_ size: CGFloat) -> Font { bridge(size, emphasis: true) }
    static func legacyDisplay(_ size: CGFloat) -> Font { bridge(size, emphasis: false) }
    static func sfPro(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}
