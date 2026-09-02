//
//  ApolloFontCheck.swift
//  Apollo
//
//  A launch-time check that the bundled faces actually registered.
//
//  Why this file exists: `Font.custom(_:size:)` and `UIFont(name:size:)` fail
//  *silently*. Ask for a name that isn't registered and you get the system
//  font with no warning, no crash, no log. Apollo shipped for three commits
//  with every serif falling back to SF Pro because the bundled Cormorant is a
//  variable font and iOS only registers its default instance —
//  `CormorantGaramond-Light` — while the code asked for
//  `CormorantGaramond-SemiBold`.
//
//  Nobody caught it by reading code. This makes it impossible to miss.
//

import SwiftUI
import UIKit

enum ApolloFontCheck {
    static func run() {
#if DEBUG
        let ok = ApolloSerif.isAvailable
        print("──────────── Apollo font check ────────────")
        print(ok
              ? "✅ serif registered: \(ApolloSerif.registeredName)"
              : "❌ SERIF MISSING — every serif role is silently rendering as SF Pro.")

        if !ok {
            print("   Bundled font families visible to the app:")
            for family in UIFont.familyNames.sorted() where family.lowercased().contains("cormorant")
                || family.lowercased().contains("goudy") {
                print("     \(family) → \(UIFont.fontNames(forFamilyName: family))")
            }
            print("   Check Info.plist UIAppFonts filenames match Resources/Fonts/ exactly,")
            print("   and that the file is in the target's Copy Bundle Resources phase.")
        } else {
            // Prove the weight axis is really moving, not just resolving.
            let regular = ApolloSerif.uiFont(size: 40, weight: ApolloSerif.regular)
            let semibold = ApolloSerif.uiFont(size: 40, weight: ApolloSerif.semibold)
            let wR = regular.fontDescriptor.object(forKey: .face) as? String ?? "—"
            let wS = semibold.fontDescriptor.object(forKey: .face) as? String ?? "—"
            print("   wght 400 → \(regular.fontName) [\(wR)]")
            print("   wght 600 → \(semibold.fontName) [\(wS)]")
            if regular.fontName == semibold.fontName && wR == wS {
                print("   ⚠️  400 and 600 resolve identically — the wght axis is not applying.")
            }
        }
        print("───────────────────────────────────────────")
#endif
    }
}
