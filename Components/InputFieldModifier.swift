//
//  InputFieldModifier.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import SwiftUI

struct InputField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .border(Color.gray)
            .foregroundColor(.black)
            .cornerRadius(10)
    }
}
