//
//  CheckmarkButton.swift
//  Apollo
//
//  56pt circle button with a checkmark glyph. Confirms the developed polaroid
//  and advances to the next step in the post flow.
//  Press animation: scale 0.92 → 1.0, spring, 280ms.
//

import SwiftUI

struct CheckmarkButton: View {
    let onConfirm: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            withAnimation(ApolloMotion.pop) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                pressed = false
                onConfirm()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.apolloUsername) // #E6E6E6
                    .frame(width: 56, height: 56)

                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.apolloBackground) // #080808
            }
        }
        .buttonStyle(.apolloPrimary)
        .scaleEffect(pressed ? 0.92 : 1.0)
        .accessibilityLabel("Confirm photo")
    }
}
