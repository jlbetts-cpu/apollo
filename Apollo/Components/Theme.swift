//
//  Theme.swift
//  Apollo
//
//  Colour. Read docs/DESIGN-SYSTEM.md §1 before adding anything here.
//
//  Structure:
//    1. The ramp — eleven grays from the Figma `Colours` page. The only hue.
//    2. Surfaces — four near-blacks with jobs, replacing the thirteen that
//       had accumulated across feature files.
//    3. Roles — what text and icons actually use.
//    4. Legacy names — every token the codebase already referenced, kept so
//       nothing breaks, each re-expressed on the ramp. New code uses roles.
//

import SwiftUI

extension Color {

    // MARK: - 1. The ramp (DESIGN-SYSTEM §1.1)

    static let apolloGray50  = Color(red: 0xf3 / 255, green: 0xf3 / 255, blue: 0xf3 / 255)
    static let apolloGray100 = Color(red: 0xe6 / 255, green: 0xe6 / 255, blue: 0xe6 / 255)
    static let apolloGray200 = Color(red: 0xce / 255, green: 0xce / 255, blue: 0xce / 255)
    static let apolloGray300 = Color(red: 0xb5 / 255, green: 0xb5 / 255, blue: 0xb5 / 255)
    static let apolloGray400 = Color(red: 0x9c / 255, green: 0x9c / 255, blue: 0x9c / 255)
    static let apolloGray500 = Color(red: 0x83 / 255, green: 0x83 / 255, blue: 0x83 / 255)
    static let apolloGray600 = Color(red: 0x6b / 255, green: 0x6b / 255, blue: 0x6b / 255)
    static let apolloGray700 = Color(red: 0x52 / 255, green: 0x52 / 255, blue: 0x52 / 255)
    static let apolloGray800 = Color(red: 0x39 / 255, green: 0x39 / 255, blue: 0x39 / 255)
    static let apolloGray900 = Color(red: 0x21 / 255, green: 0x21 / 255, blue: 0x21 / 255)
    static let apolloGray950 = Color(red: 0x08 / 255, green: 0x08 / 255, blue: 0x08 / 255)

    // MARK: - 2. Surfaces (§1.3)

    /// Every screen's background.
    static let apolloGround  = apolloGray950
    /// Text-entry wells and the unread-row wash. Sits *below* the ground.
    static let apolloSunken  = Color(red: 0x0f / 255, green: 0x0f / 255, blue: 0x0f / 255)
    /// Skeletons, empty thumbnails, quiet chips.
    static let apolloSurface = Color(red: 0x14 / 255, green: 0x14 / 255, blue: 0x14 / 255)
    /// Sheets, pills, the search field — anything that floats above the ground.
    static let apolloRaised  = apolloGray900

    /// The one hairline. Gray 200 at 20%: reads ~#303030 on the ground and as
    /// a bright edge on glass. Draw it at 0.5pt (ApolloMetric.hairline).
    static let apolloHairline = apolloGray200.opacity(0.20)

    // MARK: - 3. Roles (§1.2) — use these in feature code

    /// Headlines, primary actions, the wins numeral.
    static let apolloPrimaryText = apolloGray50
    /// Names, titles, body that must be read.
    static let apolloText        = apolloGray100
    /// Orb labels, captions on glass, secondary names.
    static let apolloTextSoft    = apolloGray200
    /// Captions, quotes, long secondary copy.
    static let apolloCaption     = apolloGray300
    /// Timestamps, "& 12 others", section labels, placeholders.
    static let apolloSecondary   = apolloGray500
    /// Handles, sub-labels, disabled glyphs.
    static let apolloTertiary    = apolloGray600
    /// Meta that should almost disappear: time · streak.
    static let apolloMeta        = apolloGray700
    /// Hints and hairline glyphs.
    static let apolloFaint       = apolloGray800

    /// Unread dots. Pure white is allowed here because it is a signal, not chrome.
    static let apolloBadge = Color.white
    /// The flash-auto glyph. The only warm value in the app — a hardware state.
    static let apolloFlashAuto = Color(red: 0xe8 / 255, green: 0xa8 / 255, blue: 0x00 / 255)

    // MARK: - 4. Legacy names — kept so existing screens keep compiling.
    //
    // Each is an alias onto the ramp or a surface. New code should not add
    // to this list; use a role above. As screens are rebuilt these go away.

    static let apolloBackground        = apolloGround
    static let apolloUsername          = apolloGray100
    static let apolloReactor           = apolloGray400
    static let apolloWinsValue         = apolloGray500
    static let apolloReactorMuted      = apolloGray500
    static let apolloSecondaryLabel    = apolloGray600
    static let apolloTabInactive       = apolloGray600
    static let apolloWinsLabel         = apolloGray600
    static let apolloWinInputBorder    = apolloGray600
    static let apolloTimeStreak        = apolloGray700
    static let apolloHint              = apolloGray800
    static let apolloSheetSurface      = apolloRaised
    static let apolloFriendsPillFill   = apolloRaised
    static let apolloFriendsAcceptText = apolloRaised
    static let apolloWinDetailsDragPill = apolloRaised
    static let apolloWinDetailsXButton = apolloRaised
    static let apolloSkeleton          = apolloSurface
    static let apolloFriendsQRButton   = apolloSurface
    static let apolloSheetBackground   = apolloSunken
    static let apolloRowUnread         = apolloSunken
    static let apolloFieldSurface      = apolloSunken
    static let apolloAvatarBorder      = apolloGround

    // Off-ramp values that were in use. Each snaps to its nearest step; the
    // largest move is 4/255, below what a 2× screen can show.
    static let apolloMuted             = apolloGray900   // was #252525
    static let apolloBorder            = apolloGray900   // was #1a1a1a
    static let apolloErrorToastBackground = apolloGray900 // was #1a1a1a
    static let apolloWinDetailsPillBorder = apolloGray900 // was #1e1e1e
    static let apolloHairlineLegacy    = apolloGray900   // was #1e1e1e (CommentRow rules)
    static let apolloViewerGradientTop = apolloSurface   // was #181818
    static let apolloStroke            = apolloGray800   // was #333333
    static let apolloQuote             = apolloGray800   // was #333333
    static let apolloWinDetailsPillText = apolloGray800  // was #333333
    static let apolloReactionCount     = apolloGray800   // was #444444
    static let apolloIconStroke        = apolloGray700   // was #555555
    static let apolloErrorToastBody    = apolloGray500   // was #888888
    static let apolloWinDetailsRepeatMuted = apolloGray500 // was #888888
    static let apolloOnLight           = apolloGray900   // was #1f1f1f
    static let apolloDanger            = apolloGray700   // was #5a2020 — §1.5: no red in prose
    static let apolloWinDetailsDeleteText = apolloGray700 // was #3d1515
}

// Spacing that predates ApolloLayout. Kept for the feed grid, which is the
// one layout allowed to leave the 20pt margin (§3.3).
enum ApolloSpacing {
    static let postHeaderHorizontal: CGFloat = 12
    static let captionHorizontal: CGFloat = 16
    static let tabHorizontalSpacing: CGFloat = 16
    static let tabRowLeading: CGFloat = 16
    static let towerGap: CGFloat = 1
}
