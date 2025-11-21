//
//  DefaultAvatar.swift
//  Thebes
//
//  Default avatar options for users without profile pictures
//

import SwiftUI

enum DefaultAvatar: String, CaseIterable, Identifiable {
    case teal = "teal"
    case blue = "blue"
    case purple = "purple"
    case orange = "orange"
    case green = "green"
    case pink = "pink"
    case red = "red"
    case yellow = "yellow"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .teal: return "Teal"
        case .blue: return "Blue"
        case .purple: return "Purple"
        case .orange: return "Orange"
        case .green: return "Green"
        case .pink: return "Pink"
        case .red: return "Red"
        case .yellow: return "Yellow"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .teal:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 20/255, green: 184/255, blue: 166/255), // Teal
                    Color(red: 56/255, green: 189/255, blue: 248/255)  // Cyan
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blue:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 59/255, green: 130/255, blue: 246/255), // Blue
                    Color(red: 147/255, green: 51/255, blue: 234/255) // Purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .purple:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 147/255, green: 51/255, blue: 234/255), // Purple
                    Color(red: 236/255, green: 72/255, blue: 153/255)  // Pink
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .orange:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 251/255, green: 146/255, blue: 60/255),  // Orange
                    Color(red: 239/255, green: 68/255, blue: 68/255)  // Red
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 34/255, green: 197/255, blue: 94/255),  // Green
                    Color(red: 20/255, green: 184/255, blue: 166/255) // Teal
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pink:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 236/255, green: 72/255, blue: 153/255), // Pink
                    Color(red: 251/255, green: 146/255, blue: 60/255) // Orange
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .red:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 239/255, green: 68/255, blue: 68/255),  // Red
                    Color(red: 236/255, green: 72/255, blue: 153/255)  // Pink
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .yellow:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 234/255, green: 179/255, blue: 8/255),   // Yellow
                    Color(red: 251/255, green: 146/255, blue: 60/255) // Orange
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// Creates a DefaultAvatar from a raw string value
    static func from(rawValue: String?) -> DefaultAvatar {
        guard let rawValue = rawValue,
              let avatar = DefaultAvatar(rawValue: rawValue) else {
            return .teal // Default to teal (matches app accent)
        }
        return avatar
    }
}

/// SwiftUI view for displaying a default avatar
struct DefaultAvatarView: View {
    let avatar: DefaultAvatar
    let size: CGFloat
    
    init(avatar: DefaultAvatar, size: CGFloat = 80) {
        self.avatar = avatar
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            Circle()
                .fill(avatar.gradient)
                .frame(width: size, height: size)
            
            // Silhouette overlay
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.3))
                .frame(width: size * 0.5, height: size * 0.5)
        }
        .overlay(
            Circle()
                .stroke(AppColors.secondary.opacity(0.4), lineWidth: size > 50 ? 2 : 1)
        )
    }
}

