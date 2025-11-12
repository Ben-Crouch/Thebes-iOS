//
//  PasswordStrengthIndicator.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct PasswordRequirement: Identifiable {
    let id = UUID()
    let text: String
    let isMet: Bool
}

struct PasswordStrengthIndicator: View {
    let password: String
    
    private var requirements: [PasswordRequirement] {
        [
            PasswordRequirement(
                text: "At least 8 characters",
                isMet: password.count >= 8
            ),
            PasswordRequirement(
                text: "Contains uppercase letter",
                isMet: password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
            ),
            PasswordRequirement(
                text: "Contains lowercase letter",
                isMet: password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
            ),
            PasswordRequirement(
                text: "Contains number",
                isMet: password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
            ),
            PasswordRequirement(
                text: "Contains special character",
                isMet: password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
            )
        ]
    }
    
    private var strengthPercentage: Double {
        let metCount = requirements.filter { $0.isMet }.count
        return Double(metCount) / Double(requirements.count)
    }
    
    private var strengthColor: Color {
        let percentage = strengthPercentage
        if percentage >= 0.8 {
            return AppColors.secondary
        } else if percentage >= 0.6 {
            return Color.yellow.opacity(0.8)
        } else if percentage >= 0.4 {
            return Color.orange.opacity(0.8)
        } else {
            return Color.red.opacity(0.8)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Strength bar
            if !password.isEmpty {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        // Progress bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(strengthColor)
                            .frame(width: geometry.size.width * strengthPercentage, height: 4)
                            .animation(.easeInOut(duration: 0.2), value: strengthPercentage)
                    }
                }
                .frame(height: 4)
            }
            
            // Requirements list
            if !password.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(requirements) { requirement in
                        HStack(spacing: 8) {
                            Image(systemName: requirement.isMet ? "checkmark.circle.fill" : "circle")
                                .font(.caption)
                                .foregroundColor(requirement.isMet ? AppColors.secondary : Color.white.opacity(0.3))
                                .animation(.easeInOut(duration: 0.2), value: requirement.isMet)
                            
                            Text(requirement.text)
                                .font(.caption)
                                .foregroundColor(requirement.isMet ? Color.white.opacity(0.8) : Color.white.opacity(0.5))
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

