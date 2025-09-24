//
//  ToastView.swift
//  Thebes
//
//  Created by Ben on 16/03/2025.
//

import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            if isShowing {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(AppColors.secondary)
                    .cornerRadius(10)
                    .padding(.top, 50) // ✅ Move it down slightly from the top
                    .transition(.move(edge: .top))
                    .animation(.easeInOut, value: isShowing)
            }
            Spacer() // ✅ Pushes content to the bottom
        }
    }
}
