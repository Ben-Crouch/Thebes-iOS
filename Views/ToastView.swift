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
    var duration: Double = 2.5 // Default duration in seconds
    
    var body: some View {
        VStack {
            if isShowing {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.secondary)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
                    .onAppear {
                        // Auto-hide after duration
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
