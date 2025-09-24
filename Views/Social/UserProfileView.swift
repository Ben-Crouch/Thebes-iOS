//
//  UserProfileView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct UserProfileView: View {
    let userId: String
    let onSocialStatsChanged: (() -> Void)?
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = UserProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private var isCurrentUser: Bool {
        userId == authViewModel.user?.uid
    }
    
    private var isFollowing: Bool {
        return viewModel.isFollowingUser
    }
    
    private var isFriend: Bool {
        guard let currentUserId = authViewModel.user?.uid else { return false }
        return viewModel.isFriend(currentUserId: currentUserId)
    }
    
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
                
                Text("Profile")
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
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
                .padding(.vertical, 16)
            
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                        .scaleEffect(1.2)
                    
                    Text("Loading profile...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let profile = viewModel.userProfile {
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Profile Picture
                            if let imageUrl = profile.profilePic,
                               let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                            .font(.title)
                                    )
                            }
                            
                            // User Info
                            VStack(spacing: 8) {
                                Text(profile.displayName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(profile.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                // Status Badges
                                HStack(spacing: 12) {
                                    if isFriend {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(AppColors.secondary)
                                            
                                            Text("Friends")
                                                .font(.caption)
                                                .foregroundColor(AppColors.secondary)
                                        }
                                    } else if isFollowing {
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.crop.circle.badge.plus")
                                                .font(.caption)
                                                .foregroundColor(AppColors.secondary)
                                            
                                            Text("Following")
                                                .font(.caption)
                                                .foregroundColor(AppColors.secondary)
                                        }
                                    }
                                    
                                    if !isCurrentUser {
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Text("\(profile.followers.count) followers")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        
                        // Action Buttons (if not current user)
                        if !isCurrentUser {
                            // Debug info
                            let _ = print("🔍 UI Debug: isFollowing = \(isFollowing)")
                            let _ = print("🔍 UI Debug: isFollowingStatusLoaded = \(viewModel.isFollowingStatusLoaded)")
                            let _ = print("🔍 UI Debug: isFollowingUser = \(viewModel.isFollowingUser)")
                            
                            if viewModel.isFollowingStatusLoaded {
                                Button(action: {
                                    guard let currentUserId = authViewModel.user?.uid else { return }
                                    
                                    if isFollowing {
                                        viewModel.unfollowUser(userId: userId, currentUserId: currentUserId) { success in
                                            if success {
                                                print("✅ Successfully unfollowed user")
                                            }
                                        }
                                    } else {
                                        viewModel.followUser(userId: userId, currentUserId: currentUserId) { success in
                                            if success {
                                                print("✅ Successfully followed user")
                                            }
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isFollowing ? "person.crop.circle.badge.minus" : "person.crop.circle.badge.plus")
                                            .font(.subheadline)
                                        
                                        Text(isFollowing ? "Unfollow" : "Follow")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(isFollowing ? AppColors.primary : AppColors.secondary)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(AppColors.secondary, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                // Show loading state while checking following status
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                                        .scaleEffect(0.8)
                                    
                                    Text("Loading...")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(AppColors.primary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(AppColors.secondary, lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        // Recent Workouts Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recent Workouts")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if viewModel.isLoadingWorkouts {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                                        .scaleEffect(0.8)
                                }
                            }
                            
                            if viewModel.recentWorkouts.isEmpty && !viewModel.isLoadingWorkouts {
                                VStack(spacing: 12) {
                                    Image(systemName: "dumbbell")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)
                                    
                                    Text("No recent workouts")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.recentWorkouts, id: \.id) { workout in
                                        UserWorkoutCard(workout: workout)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            } else {
                // Error State
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text("Profile Not Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(viewModel.errorMessage ?? "This user profile could not be found")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Go Back")
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
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            print("🔍 UserProfileView: onAppear called with userId: '\(userId)'")
            print("🔍 UserProfileView: userId.isEmpty = \(userId.isEmpty)")
            
            // Only process if userId is valid and not empty
            guard !userId.isEmpty && userId.count > 3 else {
                print("❌ UserProfileView: userId is empty or too short, skipping profile fetch")
                return
            }
            
            print("✅ UserProfileView: Calling fetchUserProfile with userId: \(userId)")
            
            // Set current user ID for following status check
            viewModel.setCurrentUserId(authViewModel.user?.uid)
            
            viewModel.fetchUserProfile(userId: userId)
            viewModel.fetchRecentWorkouts(for: userId)
            viewModel.onSocialStatsChanged = onSocialStatsChanged
        }
        .onChange(of: userId) { newUserId in
            // Only process if the new userId is valid
            guard !newUserId.isEmpty && newUserId.count > 3 else {
                print("❌ UserProfileView: onChange - userId is empty or too short, skipping")
                return
            }
            
            print("✅ UserProfileView: onChange - userId changed to: \(newUserId)")
            
            // Set current user ID before fetching profile
            viewModel.setCurrentUserId(authViewModel.user?.uid)
            
            viewModel.fetchUserProfile(userId: newUserId)
            viewModel.fetchRecentWorkouts(for: newUserId)
        }
    }
}

struct UserWorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Notes section (if available)
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
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
    UserProfileView(userId: "test-user-id", onSocialStatsChanged: nil)
        .environmentObject(AuthViewModel())
}
