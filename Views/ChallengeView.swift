//
//  ChallengeView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showSideMenu = false
    @State private var username: String = "User"
    @State private var profileImageUrl: String? = nil
    @State private var selectedAvatar: DefaultAvatar = .teal
    @State private var useGradientAvatar: Bool = false
    @State private var showSettingsView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        TopNavBarView(showSideMenu: $showSideMenu)
                        
                        VStack(spacing: 8) {
                            Text("Challenges")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Push your limits and compete")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                    }
                    
                    // Coming Soon Card
                    ComingSoonChallengeCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Side Menu
            SideMenuView(
                isPresented: $showSideMenu,
                username: username,
                profileImageUrl: profileImageUrl,
                selectedAvatar: selectedAvatar,
                useGradientAvatar: useGradientAvatar,
                userEmail: authViewModel.user?.email,
                onViewProfile: {
                    // TODO: Navigate to user's own profile
                },
                onSettings: {
                    showSettingsView = true
                },
                onAbout: {
                    // TODO: Show about screen
                },
                onLogOut: {
                    authViewModel.signOut()
                }
            )
        }
        .navigationDestination(isPresented: $showSettingsView) {
            ProfileSettingsView()
                .environmentObject(authViewModel)
        }
        .onAppear {
            // Load user profile for side menu
            if let userId = authViewModel.user?.uid {
                UserService.shared.fetchUserProfile(userId: userId) { userProfile in
                    DispatchQueue.main.async {
                        if let profile = userProfile {
                            self.username = profile.displayName
                            self.profileImageUrl = profile.profilePic
                            self.selectedAvatar = DefaultAvatar.from(rawValue: profile.selectedAvatar)
                            self.useGradientAvatar = profile.useGradientAvatar ?? false
                        }
                    }
                }
            }
        }
    }
}

struct ComingSoonChallengeCard: View {
    var body: some View {
        VStack(spacing: 24) {
            // Icon and Title
            VStack(spacing: 16) {
                Image(systemName: "flag.checkered.2.crossed")
                    .foregroundColor(AppColors.secondary)
                    .font(.system(size: 60))
                
                Text("Coming Soon")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Description Card
            VStack(alignment: .leading, spacing: 16) {
                Text("What's Coming")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "target",
                        title: "Personal Challenges",
                        description: "Set and track your fitness goals with progress indicators and achievements"
                    )
                    
                    FeatureRow(
                        icon: "person.2.fill",
                        title: "Community Competition",
                        description: "Join challenges with friends, compete on leaderboards, and celebrate victories together"
                    )
                    
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Progress Tracking",
                        description: "Monitor workout streaks, volume goals, PR milestones, and performance improvements"
                    )
                    
                    FeatureRow(
                        icon: "trophy.fill",
                        title: "Achievements & Rewards",
                        description: "Earn badges, unlock rewards, and build your fitness legacy"
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(20)
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.secondary)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}
