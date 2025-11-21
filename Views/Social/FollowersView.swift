//
import SwiftUI
//  FollowersView.swift
//  Thebes
//
//  Created by Ben on 28/05/2025.
//

import SwiftUI

struct FollowersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = FollowersViewModel()
    let onSocialStatsChanged: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showUserProfile: Bool = false
    @State private var selectedUserId: String = ""
    @State private var currentUserFollowing: [String] = []
    
    var body: some View {
        ZStack {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Text("Followers")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Invisible spacer to center
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("People who follow you")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            // Content
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                        .scaleEffect(1.2)
                    
                    Text("Loading followers...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.followers.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text("No Followers Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("When people follow you, they'll appear here. Share your workouts and connect with others to build your following")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Share Your Workouts")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppColors.secondary)
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.followers, id: \.uid) { user in
                            FollowerUserCard(
                                user: user,
                                currentUserId: authViewModel.user?.uid ?? "",
                                isAlreadyFollowing: currentUserFollowing.contains(user.uid),
                                onFollowBack: { userId in
                                    viewModel.followBackUser(userId: userId, currentUserId: authViewModel.user?.uid ?? "") { success in
                                        if success {
                                            print("✅ Successfully followed back user")
                                            // Refresh following list
                                            loadCurrentUserFollowing()
                                        }
                                    }
                                },
                                onViewProfile: { userId in
                                    selectedUserId = userId
                                    showUserProfile = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            }
        }
        .onAppear {
            if let userId = authViewModel.user?.uid {
                viewModel.fetchFollowers(for: userId)
                loadCurrentUserFollowing()
            }
            
            // Set up callback to refresh social stats in parent view
            viewModel.onSocialStatsChanged = onSocialStatsChanged
        }
        .sheet(isPresented: $showUserProfile) {
            NavigationStack {
                UserProfileView(
                    userId: selectedUserId,
                    onSocialStatsChanged: {
                        // Refresh followers list and following status when user follows/unfollows from profile
                        if let userId = authViewModel.user?.uid {
                            viewModel.fetchFollowers(for: userId)
                            loadCurrentUserFollowing()
                        }
                    }
                )
                .environmentObject(authViewModel)
            }
        }
    }
    
    private func loadCurrentUserFollowing() {
        guard let userId = authViewModel.user?.uid else { return }
        UserService.shared.fetchUserProfile(userId: userId) { profile in
            DispatchQueue.main.async {
                self.currentUserFollowing = profile?.following ?? []
            }
        }
    }
}

struct FollowerUserCard: View {
    let user: UserProfile
    @Environment(\.colorScheme) var colorScheme
    let currentUserId: String
    let isAlreadyFollowing: Bool
    let onFollowBack: (String) -> Void
    let onViewProfile: (String) -> Void
    
    @State private var isFollowingBack: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // User Avatar (tappable)
            Button(action: {
                guard !user.uid.isEmpty else {
                    print("❌ FollowerUserCard: user.uid is empty for user \(user.displayName)")
                    return
                }
                onViewProfile(user.uid)
            }) {
                ProfileAvatarView(
                    profilePic: user.profilePic,
                    selectedAvatar: DefaultAvatar.from(rawValue: user.selectedAvatar),
                    useGradientAvatar: user.useGradientAvatar ?? false,
                    size: 50
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // User Info (tappable)
            Button(action: {
                guard !user.uid.isEmpty else {
                    print("❌ FollowerUserCard: user.uid is empty for user \(user.displayName)")
                    return
                }
                onViewProfile(user.uid)
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Follow Back Button - only show if not already following
            if !isAlreadyFollowing {
                Button(action: {
                    isFollowingBack = true
                    onFollowBack(user.uid)
                    
                    // Reset loading state after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isFollowingBack = false
                    }
                }) {
                    if isFollowingBack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Follow Back")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.secondary)
                )
                .buttonStyle(PlainButtonStyle())
                .disabled(isFollowingBack)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    FollowersView(onSocialStatsChanged: nil)
        .environmentObject(AuthViewModel())
}
