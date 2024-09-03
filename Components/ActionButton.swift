//
//  ActionButton.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation

import SwiftUI

struct ActionButton: ButtonStyle {
    private let cornerRadius: Double = 10
    private let pressedScale: Double = 1.2
    private let unpressedScale: Double = 1
    private let animationLength: Double = 0.17
    
    var backgroundColor: Color?
    var textColor: Color
    var borderColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(textColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: 1)
                        )
            .scaleEffect(configuration.isPressed ? pressedScale : unpressedScale)
            .animation(.easeIn(duration: animationLength), value: configuration.isPressed)
    }
}
