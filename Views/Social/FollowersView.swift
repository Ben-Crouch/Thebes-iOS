//
//  FollowersView.swift
//  Thebes
//
//  Created by Ben on 28/05/2025.
//

import SwiftUI

struct FollowersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FollowersViewModel()
    let onSocialStatsChanged: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showUserProfile: Bool = false
    @State private var selectedUserId: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(AppColors.secondary)
                        
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(AppColors.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("Followers")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Invisible spacer to center the title
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .opacity(0)
                    
                    Text("Back")
                        .font(.headline)
                        .opacity(0)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text("People who follow you")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
                .padding(.vertical, 16)
            
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
                                onFollowBack: { userId in
                                    viewModel.followBackUser(userId: userId, currentUserId: authViewModel.user?.uid ?? "") { success in
                                        if success {
                                            print("✅ Successfully followed back user")
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
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            if let userId = authViewModel.user?.uid {
                viewModel.fetchFollowers(for: userId)
            }
            
            // Set up callback to refresh social stats in parent view
            viewModel.onSocialStatsChanged = onSocialStatsChanged
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView(
                userId: selectedUserId,
                onSocialStatsChanged: {
                    // Refresh followers list when user follows back from profile
                    if let userId = authViewModel.user?.uid {
                        viewModel.fetchFollowers(for: userId)
                    }
                }
            )
            .environmentObject(authViewModel)
        }
    }
}

struct FollowerUserCard: View {
    let user: UserProfile
    let currentUserId: String
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
                if let imageUrl = user.profilePic,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        )
                }
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
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Follow Back Button
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    FollowersView(onSocialStatsChanged: nil)
        .environmentObject(AuthViewModel())
}
