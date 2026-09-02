//
//  ApolloLayout.swift
//  Apollo
//
//  Spacing, radius and size ladders. Read docs/DESIGN-SYSTEM.md §3–5.
//  A value that is not on one of these ladders is a bug, even if it looks
//  fine.
//

import SwiftUI

/// The 4pt grid (§3.1).
enum ApolloSpace {
    static let xs: CGFloat      = 2
    static let s: CGFloat       = 4
    static let m: CGFloat       = 8
    static let l: CGFloat       = 12
    static let xl: CGFloat      = 16
    /// The one screen margin (§3.2).
    static let screen: CGFloat  = 20
    static let xxl: CGFloat     = 24
    /// Content → next section label.
    static let section: CGFloat = 32
    static let xxxl: CGFloat    = 40
    static let huge: CGFloat    = 48
    static let giant: CGFloat   = 64

    /// Section label → its content.
    static let labelToContent: CGFloat = 12
    /// Header → first content.
    static let headerToContent: CGFloat = 32
    /// Avatar → text in a row.
    static let rowAvatarToText: CGFloat = 10
    /// Between pills in a row.
    static let pillGap: CGFloat = 8
    /// Gutter in the feed's photo grid — the one thing off the grid, on purpose.
    static let photoGutter: CGFloat = 2
}

/// Radius follows what the thing *is* (§4).
enum ApolloRadius {
    /// A photo in a grid, a thumbnail, a tiny print. Figma drew these at 3,
    /// which on a 223pt tile reads as a razor edge; 12 reads as a print.
    static let photo: CGFloat      = 12
    /// Prints under ~48pt — the three thumbnails beside the shutter. `photo`
    /// at 12 would eat a 37pt print; Figma drew these at 3.
    static let thumbnail: CGFloat  = 6
    /// Anything pressable that isn't a capsule — the portfolio's control rung.
    static let control: CGFloat    = 14
    /// A physical thing: a polaroid, a single-post photo, an album card.
    static let object: CGFloat     = 20
    /// The biggest surfaces: sheets, the photo viewer.
    static let surface: CGFloat    = 28
    /// The camera's bottom corners only. It is the environment and leaves the
    /// ladder; Figma had 40, Jayden asked for a bit more.
    static let viewfinder: CGFloat = 48
}

/// Avatar ladder (§5.1).
enum ApolloAvatarSize: CGFloat, CaseIterable {
    case stack   = 16
    case comment = 24
    case post    = 32
    case row     = 44
    case orb     = 48
    case profile = 64
    case hero    = 96
}

/// Fixed metrics that aren't spacing (§3.2, §5.2, §6).
enum ApolloMetric {
    /// Minimum tap target, measured not assumed.
    static let target: CGFloat       = 44
    static let row: CGFloat          = 44
    static let headerTop: CGFloat    = 64
    static let headerHeight: CGFloat = 50
    static let icon: CGFloat         = 24
    static let iconSmall: CGFloat    = 18
    static let hairline: CGFloat     = 0.5
    static let dragPillWidth: CGFloat = 36
    static let dragPillHeight: CGFloat = 5
    static let bottomSafePadding: CGFloat = 16
}
