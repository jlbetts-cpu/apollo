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
    case name           // every person's name in a row or header
    case nameSmall      // orb labels
    case nameSmallYou   // the one italic in the app
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
        let serifName: String       // serif only — PostScript name
        let tracking: CGFloat
        let lineHeightMultiple: CGFloat
        let uppercase: Bool
        let relativeTo: Font.TextStyle
    }

    fileprivate var spec: Spec {
        switch self {
        case .display:      return Spec(family: .serif, size: 48, weight: .regular, serifName: ApolloFontName.serifRegular,        tracking: -0.96, lineHeightMultiple: 1.00, uppercase: false, relativeTo: .largeTitle)
        case .title:        return Spec(family: .serif, size: 24, weight: .regular, serifName: ApolloFontName.serifSemiBold,       tracking: -0.48, lineHeightMultiple: 1.10, uppercase: false, relativeTo: .title2)
        case .heading:      return Spec(family: .serif, size: 20, weight: .regular, serifName: ApolloFontName.serifSemiBold,       tracking: -0.30, lineHeightMultiple: 1.15, uppercase: false, relativeTo: .title3)
        case .name:         return Spec(family: .serif, size: 16, weight: .regular, serifName: ApolloFontName.serifSemiBold,       tracking: -0.32, lineHeightMultiple: 1.20, uppercase: false, relativeTo: .body)
        case .nameSmall:    return Spec(family: .serif, size: 12, weight: .regular, serifName: ApolloFontName.serifSemiBold,       tracking:  0.00, lineHeightMultiple: 1.20, uppercase: false, relativeTo: .caption)
        case .nameSmallYou: return Spec(family: .serif, size: 12, weight: .regular, serifName: ApolloFontName.serifSemiBoldItalic, tracking:  0.00, lineHeightMultiple: 1.20, uppercase: false, relativeTo: .caption)
        case .body:         return Spec(family: .sans,  size: 16, weight: .regular, serifName: "",                                 tracking: -0.32, lineHeightMultiple: 1.30, uppercase: false, relativeTo: .body)
        case .bodyMedium:   return Spec(family: .sans,  size: 16, weight: .medium,  serifName: "",                                 tracking: -0.32, lineHeightMultiple: 1.30, uppercase: false, relativeTo: .body)
        case .caption:      return Spec(family: .sans,  size: 12, weight: .regular, serifName: "",                                 tracking: -0.24, lineHeightMultiple: 1.30, uppercase: false, relativeTo: .caption)
        case .label:        return Spec(family: .sans,  size: 10, weight: .regular, serifName: "",                                 tracking:  0.50, lineHeightMultiple: 1.00, uppercase: true,  relativeTo: .caption2)
        case .numeral:      return Spec(family: .sans,  size: 20, weight: .medium,  serifName: "",                                 tracking:  0.00, lineHeightMultiple: 1.00, uppercase: false, relativeTo: .title3)
        case .countdown:    return Spec(family: .serif, size: 40, weight: .regular, serifName: ApolloFontName.serifRegular,        tracking:  0.00, lineHeightMultiple: 1.00, uppercase: false, relativeTo: .largeTitle)
        }
    }
}

enum ApolloFontName {
    static let serifRegular        = "CormorantGaramond-Regular"
    static let serifSemiBold       = "CormorantGaramond-SemiBold"
    static let serifSemiBoldItalic = "CormorantGaramond-SemiBoldItalic"
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
                return .custom(s.serifName, size: s.size, relativeTo: s.relativeTo)
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
        let base = UIFont(name: ApolloFontName.serifRegular, size: scaledSize)
            ?? UIFont.systemFont(ofSize: scaledSize, weight: .regular)
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
    static func goudyItalic(_ size: CGFloat) -> Font {
        .custom(ApolloFontName.serifSemiBoldItalic, fixedSize: size)
    }
    static func goudyRegular(_ size: CGFloat) -> Font {
        // Display sizes take Regular; everything smaller takes SemiBold so the
        // serifs survive on the ground — the same rule as the role table.
        .custom(size >= 36 ? ApolloFontName.serifRegular : ApolloFontName.serifSemiBold, fixedSize: size)
    }
    static func sfPro(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}
