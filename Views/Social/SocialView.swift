//
//  SocialView.swift
//  Thebes
//
//  Created by Ben on 21/05/2025.
//

import SwiftUI

// MARK: - Social Stat Card Component
struct SocialStatCard: View {
    let title: String
    let count: Int
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundColor(AppColors.secondary)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SocialView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SocialViewModel()
    @FocusState private var isSearchFocused: Bool
    
    @State private var showSearchSheet: Bool = false
    @State private var showSideMenu: Bool = false
    @State private var showFriendsView: Bool = false
    @State private var showFollowersView: Bool = false
    @State private var showFollowingView: Bool = false
    @State private var showRecentActivity: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Top Navigation
                TopNavBarView(showSideMenu: $showSideMenu)
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hey, \(viewModel.username)!")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Connect with friends and track your fitness journey together")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // User avatar
                                if let imageUrl = viewModel.profileImageUrl,
                                   let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Search Section
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppColors.secondary)
                                    .font(.title3)
                                
                                TextField("", text: $viewModel.searchText)
                                    .modifier(PlaceholderModifier(
                                        showPlaceholder: viewModel.searchText.isEmpty,
                                        placeholder: "Search users...",
                                        color: .white
                                    ))
                                    .foregroundColor(.white)
                                    .submitLabel(.search)
                                    .onSubmit {
                                        let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !query.isEmpty else { return }
                                        showSearchSheet = true
                                        isSearchFocused = false
                                    }
                                    .focused($isSearchFocused)
                                    .accentColor(AppColors.secondary)
                                
                                if !viewModel.searchText.isEmpty {
                                    Button {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            viewModel.searchText = ""
                                        }
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
                                    .fill(AppColors.primary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isSearchFocused ? AppColors.secondary : AppColors.secondary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Social Stats Grid
                        VStack(spacing: 16) {
                            Text("Your Network")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                SocialStatCard(
                                    title: "Friends",
                                    count: viewModel.friends,
                                    systemImage: "person.2.fill"
                                ) {
                                    showFriendsView = true
                                }
                                
                                SocialStatCard(
                                    title: "Followers",
                                    count: viewModel.followers,
                                    systemImage: "person.3.fill"
                                ) {
                                    showFollowersView = true
                                }
                                
                                SocialStatCard(
                                    title: "Following",
                                    count: viewModel.following,
                                    systemImage: "person.crop.circle.badge.plus"
                                ) {
                                    showFollowingView = true
                                }
                                
                                // Recent Activity Card
                                SocialStatCard(
                                    title: "Recent Activity",
                                    count: 0, // We'll show this as a special case
                                    systemImage: "clock.arrow.circlepath"
                                ) {
                                    showRecentActivity = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            
            // Side Menu Overlay
            if showSideMenu {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showSideMenu = false
                        }
                    }
                
                VStack(alignment: .leading, spacing: 20) {
                    Button("User Settings") {
                        // Navigate to user settings
                    }
                    .foregroundColor(.white)
                    
                    Button("Log Out") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .frame(width: 250)
                .background(AppColors.secondary)
                .transition(.move(edge: .trailing))
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .onAppear {
            if let userId = authViewModel.user?.uid {
                viewModel.fetchSocialStats(for: userId)
            }
        }
        .sheet(isPresented: $showSearchSheet) {
            NavigationView {
                SocialSearchView(
                    searchQuery: viewModel.searchText,
                    onSocialStatsChanged: {
                        // Refresh social stats when user follows/unfollows
                        if let userId = authViewModel.user?.uid {
                            viewModel.fetchSocialStats(for: userId)
                        }
                    }
                )
                .environmentObject(authViewModel)
            }
        }
        .sheet(isPresented: $showFriendsView) {
            FriendsView(
                onSocialStatsChanged: {
                    // Refresh social stats when user unfriends someone
                    if let userId = authViewModel.user?.uid {
                        viewModel.fetchSocialStats(for: userId)
                    }
                }
            )
            .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showFollowersView) {
            FollowersView(
                onSocialStatsChanged: {
                    // Refresh social stats when user follows back someone
                    if let userId = authViewModel.user?.uid {
                        viewModel.fetchSocialStats(for: userId)
                    }
                }
            )
            .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showFollowingView) {
            FollowingView(
                onSocialStatsChanged: {
                    // Refresh social stats when user unfollows someone
                    if let userId = authViewModel.user?.uid {
                        viewModel.fetchSocialStats(for: userId)
                    }
                }
            )
            .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showRecentActivity) {
            NavigationView {
                RecentActivityView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
