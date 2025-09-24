//
//  PlaceholderModifier.swift
//  Thebes
//
//  Created by Ben on 20/02/2025.
//

import SwiftUI

struct PlaceholderModifier: ViewModifier {
    var showPlaceholder: Bool
    var placeholder: String
    var color: Color

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceholder {
                Text(placeholder)
                    .foregroundColor(color)
                    .padding(.leading, 5)
            }
            content
                .foregroundColor(.white)
                .padding(5)
        }
    }
}

// Extension to simplify usage
extension View {
    func placeholderStyle(_ color: Color) -> some View {
        self.modifier(PlaceholderModifier(showPlaceholder: true, placeholder: "", color: color))
    }
}

