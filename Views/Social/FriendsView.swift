//
//  FriendsView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FriendsViewModel()
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
                
                Text("Friends")
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
            
            Text("People who follow you back")
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
                    
                    Text("Loading friends...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.friends.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text("No Friends Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Friends are people who follow you back. Start following people to build meaningful connections")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Find People to Follow")
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
                        ForEach(viewModel.friends, id: \.uid) { user in
                            FriendUserCard(
                                user: user,
                                currentUserId: authViewModel.user?.uid ?? "",
                                onUnfriend: { userId in
                                    viewModel.unfriendUser(userId: userId, currentUserId: authViewModel.user?.uid ?? "") { success in
                                        if success {
                                            // Optionally show a success message
                                            print("✅ Successfully unfriended user")
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
                viewModel.fetchFriends(for: userId)
            }
            
            // Set up callback to refresh social stats in parent view
            viewModel.onSocialStatsChanged = onSocialStatsChanged
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView(
                userId: selectedUserId,
                onSocialStatsChanged: {
                    // Refresh friends list when user unfriends from profile
                    if let userId = authViewModel.user?.uid {
                        viewModel.fetchFriends(for: userId)
                    }
                }
            )
            .environmentObject(authViewModel)
        }
    }
}

struct FriendUserCard: View {
    let user: UserProfile
    let currentUserId: String
    let onUnfriend: (String) -> Void
    let onViewProfile: (String) -> Void
    
    @State private var isUnfriending: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // User Avatar (tappable)
                Button(action: {
                    guard !user.uid.isEmpty else {
                        print("❌ FriendUserCard: user.uid is empty for user \(user.displayName)")
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
                
                // User Info - Full width for text (tappable)
                Button(action: {
                    guard !user.uid.isEmpty else {
                        print("❌ FriendUserCard: user.uid is empty for user \(user.displayName)")
                        return
                    }
                    onViewProfile(user.uid)
                }) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.displayName)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Friend badge
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.secondary)
                    
                    Text("Friends")
                        .font(.caption)
                        .foregroundColor(AppColors.secondary)
                }
            }
            
            // Unfriend Button - Full width below
            HStack {
                Spacer()
                
                Button(action: {
                    isUnfriending = true
                    onUnfriend(user.uid)
                    
                    // Reset loading state after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isUnfriending = false
                    }
                }) {
                    if isUnfriending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Unfriend")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.secondary, lineWidth: 1)
                        )
                )
                .buttonStyle(PlainButtonStyle())
                .disabled(isUnfriending)
                
                Spacer()
            }
            .padding(.top, 12)
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
    FriendsView(onSocialStatsChanged: nil)
        .environmentObject(AuthViewModel())
}
