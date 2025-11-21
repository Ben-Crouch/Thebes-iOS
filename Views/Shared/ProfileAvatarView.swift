//
//  ProfileAvatarView.swift
//  Thebes
//
//  Reusable component for displaying user profile avatars
//

import SwiftUI

struct ProfileAvatarView: View {
    let profilePic: String?
    let selectedAvatar: DefaultAvatar
    let useGradientAvatar: Bool
    let size: CGFloat
    
    init(profilePic: String?, selectedAvatar: DefaultAvatar = .teal, useGradientAvatar: Bool = false, size: CGFloat = 80) {
        self.profilePic = profilePic
        self.selectedAvatar = selectedAvatar
        self.useGradientAvatar = useGradientAvatar
        self.size = size
    }
    
    var body: some View {
        // If user prefers gradient avatar, or no profile pic exists, show gradient avatar
        if useGradientAvatar || profilePic == nil || profilePic?.isEmpty == true {
            // Default gradient avatar
            DefaultAvatarView(avatar: selectedAvatar, size: size)
        } else if let imageUrl = profilePic,
                  let url = URL(string: imageUrl) {
            // Custom profile picture (Google/Apple)
            AsyncImage(url: url) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppColors.secondary.opacity(0.4), lineWidth: size > 50 ? 2 : 1)
            )
        } else {
            // Fallback to gradient avatar
            DefaultAvatarView(avatar: selectedAvatar, size: size)
        }
    }
}

