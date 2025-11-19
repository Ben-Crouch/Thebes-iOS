//
//  HomeView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel() // ✅ Ensure StateObject is used only here
    @State private var showSideMenu = false
    @State private var showSettingsView = false
    @Environment(\.colorScheme) var colorScheme
    
    
var body: some View {
    ZStack(alignment: .top) {
        // Background with gradient - adjusted for dark mode visibility
        LinearGradient(
            gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
        
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    TopNavBarView(showSideMenu: $showSideMenu)
                    
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Ready for your next workout?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                }
                
                // Profile Card
                ProfileHeaderView(viewModel: viewModel)
                
                // Quick Actions Card
                QuickActionsCard()
                
                // Exercise Tracker Card
                FavoritedTrackerSection(viewModel: viewModel)
                
                // Recent Workout Card
                MostRecentWorkoutView(viewModel: viewModel)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            guard let userId = authViewModel.user?.uid else {
                print("⚠️ No valid user ID found. Skipping HomeView data load.")
                return
            }
            viewModel.loadUserProfile(for: userId)
            viewModel.loadMostRecentWorkout(for: userId)
        }
        // Side Menu
        SideMenuView(
            isPresented: $showSideMenu,
            username: viewModel.username,
            profileImageUrl: viewModel.profileImageUrl,
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
}
    
    struct ProfileHeaderView: View {
        @ObservedObject var viewModel: HomeViewModel
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                    
                    Text("Profile")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        if let imageUrl = viewModel.profileImageUrl,
                           let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppColors.secondary.opacity(0.3), lineWidth: 2)
                            )
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(AppColors.secondary.opacity(0.6))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.username)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(viewModel.tagline.displayText)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // Stats Row
                    HStack(spacing: 20) {
                        StatItem(
                            value: "\(viewModel.followerCount)",
                            label: "Followers",
                            icon: "person.2.fill",
                            color: .blue
                        )
                        
                        StatItem(
                            value: "\(viewModel.followingCount)",
                            label: "Following",
                            icon: "person.3.fill",
                            color: .green
                        )
                        
                        StatItem(
                            value: "\(viewModel.workoutCountLast30Days)",
                            label: "This Month",
                            icon: "calendar.badge.checkmark",
                            color: .orange
                        )
                    }
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
            .padding(.horizontal, 20)
        }
    }
    
    struct QuickActionsCard: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                    
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    NavigationLink(
                        destination: WorkoutLogView(userId: authViewModel.user?.uid ?? "")
                            .environmentObject(authViewModel)
                    ) {
                        QuickActionButton(
                            title: "Log Workout",
                            icon: "plus.circle.fill",
                            color: .green
                        )
                    }
                    
                    NavigationLink(
                        destination: TemplateLogView(userId: authViewModel.user?.uid ?? "")
                            .environmentObject(authViewModel)
                    ) {
                        QuickActionButton(
                            title: "Create Template",
                            icon: "doc.text.fill",
                            color: .blue
                        )
                    }
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
            .padding(.horizontal, 20)
        }
    }
    
    struct FavoritedTrackerSection: View {
        @ObservedObject var viewModel: HomeViewModel
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            if let tracker = viewModel.trackedExercise {
                NavigationLink(destination:
                                TrackerView(viewModel: TrackerViewModel(
                                    userId: authViewModel.user?.uid ?? "")
                                ).environmentObject(authViewModel)
                ) {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)
                            
                            Text("Exercise Tracker")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Track Your Progress")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(tracker)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)
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
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    struct MostRecentWorkoutView: View {
        @ObservedObject var viewModel: HomeViewModel
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            if let workout = viewModel.mostRecentWorkout {
                NavigationLink(destination: workoutDetailView(for: workout)) {
                    RecentWorkoutCard(workout: workout)
                }
            }
        }
        
        @ViewBuilder
        private func workoutDetailView(for workout: Workout) -> some View {
            let workoutDetailViewModel = WorkoutDetailViewModel(
                currentUserId: authViewModel.user?.uid ?? "", 
                workout: workout
            )
            WorkoutDetailView(viewModel: workoutDetailViewModel)
        }
    }
    
    struct RecentWorkoutCard: View {
        let workout: Workout
        
        var body: some View {
            VStack(spacing: 16) {
                headerSection
                contentSection
            }
            .padding(20)
            .background(cardBackground)
            .padding(.horizontal, 20)
        }
        
        private var headerSection: some View {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                
                Text("Recent Workout")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        
        private var contentSection: some View {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    dateSection
                    
                    if let notes = workout.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                }
                
                Spacer()
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
            }
        }
        
        private var dateSection: some View {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Text(workout.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        
        private func notesSection(_ notes: String) -> some View {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        
        private var cardBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // Removed RecentWorkoutsTitle and RecentWorkoutsList structs since they are no longer used
    
    // MARK: - New Saved Templates Section
    
    struct SavedTemplatesTitle: View {
        var body: some View {
            Text("Saved Templates")
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .padding(.horizontal)
        }
    }
    
    /*struct SavedTemplatesList: View {
     @ObservedObject var viewModel: HomeViewModel // ✅ Use @ObservedObject in subviews
     @EnvironmentObject var authViewModel: AuthViewModel
     
     var body: some View {
     VStack(spacing: 10) {
     ForEach(viewModel.savedTemplates, id: \.id) { template in // ✅ Ensure ForEach uses a unique id
     NavigationLink(destination: TemplateDetailView(template: template, currentUserId: authViewModel.user?.uid ?? "")) {
     VStack(alignment: .leading, spacing: 5) {
     Text(template.title)
     .font(.title3)
     .bold()
     .foregroundColor(.white)
     }
     .padding()
     .frame(maxWidth: .infinity, alignment: .leading)
     .background(AppColors.primary.opacity(0.6))
     .cornerRadius(10)
     }
     }
     }
     .padding(.horizontal)
     }
     }*/
    
    // MARK: - Buttons
    
    struct LogWorkoutButton: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            NavigationLink(
                destination: WorkoutLogView(userId: authViewModel.user?.uid ?? "")
                    .environmentObject(authViewModel)
            ) {
                Text("Log Workout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.secondary)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
    
    struct AddTemplateButton: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            NavigationLink(destination: TemplateLogView(userId: authViewModel.user?.uid ?? "").environmentObject(authViewModel)) {
                Text("Add Template")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.secondary)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Supporting Components
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
