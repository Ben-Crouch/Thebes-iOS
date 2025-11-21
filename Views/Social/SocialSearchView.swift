//
import SwiftUI
//  SocialSearchView.swift
//  Thebes
//
//  Created by Ben on 02/09/2025.
//

import SwiftUI

struct SelectedUser: Identifiable {
    let id: String
}

struct SocialSearchView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SocialSearchViewModel()
    let searchQuery: String
    let onSocialStatsChanged: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selectedUserId: String? = nil
    @State private var showToast = false
    @State private var toastMessage = ""
    
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
                        
                        Text("Search Users")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Invisible spacer to center
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)
                
                // Search Input
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.secondary)
                            .font(.title3)
                        
                        TextField("", text: $searchText)
                            .modifier(PlaceholderModifier(
                                showPlaceholder: searchText.isEmpty,
                                placeholder: "Search by name...",
                                color: .gray
                            ))
                            .foregroundColor(.white)
                            .onSubmit {
                                performSearch()
                            }
                            .onChange(of: searchText) { newValue in
                                if newValue.isEmpty {
                                    viewModel.clearResults()
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                viewModel.clearResults()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Search Results
            if viewModel.isSearching {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                        .scaleEffect(1.2)
                    
                    Text("Searching users...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.searchResults.isEmpty && !searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No Users Found")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Try searching with a different name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("Search for Users")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Enter a name to find other users on Thebes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchResults, id: \.id) { user in
                            UserSearchCard(
                                user: user,
                                currentUserId: authViewModel.user?.uid ?? "",
                                onFollowToggle: { userId in
                                    // Check if user exists in search results (for toast message)
                                    let userExists = viewModel.searchResults.contains(where: { $0.uid == userId })
                                    
                                    // Note: We can't reliably determine if we're following or unfollowing synchronously
                                    // The UserSearchCard handles the state toggle, but for the toast we'll show after action
                                    viewModel.toggleFollow(userId: userId, currentUserId: authViewModel.user?.uid ?? "")
                                    
                                    // Show toast after a short delay if user exists in results
                                    if userExists {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            // Show a generic update message since we can't reliably determine the action here
                                            toastMessage = "Updated"
                                            showToast = true
                                        }
                                    }
                                },
                                onViewProfile: { userId in
                                    print("🔍 SocialSearchView: onViewProfile called with userId: \(userId)")
                                    guard !userId.isEmpty else {
                                        print("❌ SocialSearchView: userId is empty, not showing profile")
                                        return
                                    }
                                    
                                    // Ensure search is complete before showing profile
                                    guard !viewModel.isSearching else {
                                        print("❌ SocialSearchView: Search still in progress, not showing profile")
                                        return
                                    }
                                    
                                    // Set the userId to trigger sheet presentation
                                    selectedUserId = userId
                                    print("✅ SocialSearchView: Setting selectedUserId to '\(userId)' and showing profile")
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            }
            
            // Toast overlay
            ToastView(message: toastMessage, isShowing: $showToast)
                .zIndex(1)
        }
        .onAppear {
            if !searchQuery.isEmpty {
                searchText = searchQuery
                performSearch()
            }
            
            // Set up callback to refresh social stats in parent view
            viewModel.onSocialStatsChanged = onSocialStatsChanged
        }
        .sheet(item: Binding<SelectedUser?>(
            get: { 
                guard let userId = selectedUserId, !userId.isEmpty else { return nil }
                return SelectedUser(id: userId)
            },
            set: { _ in selectedUserId = nil }
        )) { selectedUser in
            NavigationStack {
                UserProfileView(
                    userId: selectedUser.id,
                    onSocialStatsChanged: {
                        // Refresh social stats when user follows/unfollows from profile
                        if authViewModel.user?.uid != nil {
                            // Refresh the search results to update follow status
                            performSearch()
                        }
                    }
                )
                .environmentObject(authViewModel)
            }
        }
    }
    
    private func performSearch() {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        viewModel.searchUsers(query: trimmedQuery)
    }
}

struct UserSearchCard: View {
    let user: UserProfile
    @Environment(\.colorScheme) var colorScheme
    let currentUserId: String
    let onFollowToggle: (String) -> Void
    let onViewProfile: (String) -> Void
    
    @State private var isFollowing: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // User Avatar (tappable)
            Button(action: {
                print("🔍 UserSearchCard: Attempting to view profile for \(user.displayName)")
                print("🔍 UserSearchCard: user.uid = '\(user.uid)'")
                print("🔍 UserSearchCard: user.uid.isEmpty = \(user.uid.isEmpty)")
                print("🔍 UserSearchCard: user.id = '\(user.id ?? "nil")'")
                print("🔍 UserSearchCard: Full user object: \(user)")
                
                // Check if user data is valid
                guard !user.uid.isEmpty else {
                    print("❌ UserSearchCard: user.uid is empty for user \(user.displayName)")
                    return
                }
                
                // Additional validation - check if this looks like a valid document ID
                guard user.uid.count > 5 else {
                    print("❌ UserSearchCard: user.uid seems too short: '\(user.uid)'")
                    return
                }
                
                print("✅ UserSearchCard: Calling onViewProfile with uid: \(user.uid)")
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
                    print("❌ UserSearchCard: user.uid is empty for user \(user.displayName)")
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
            
            // Follow Button
            if user.uid != currentUserId {
                Button(action: {
                    isLoading = true
                    // Toggle the state immediately for better UX
                    isFollowing.toggle()
                    onFollowToggle(user.uid)
                    
                    // Reset loading state after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isLoading = false
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: isFollowing ? .white : .black))
                            .scaleEffect(0.8)
                    } else {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isFollowing ? .white : .black)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isFollowing ? Color.white.opacity(0.08) : AppColors.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.secondary, lineWidth: isFollowing ? 1 : 0)
                        )
                )
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
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
        .onAppear {
            checkFollowingStatus()
        }
    }
    
    private func checkFollowingStatus() {
        // Check if current user is following this user
        UserService.shared.fetchUserProfile(userId: currentUserId) { userProfile in
            DispatchQueue.main.async {
                if let profile = userProfile {
                    isFollowing = profile.following.contains(user.uid)
                }
            }
        }
    }
}
