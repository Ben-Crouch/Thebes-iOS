//
//  WorkoutsView.swift
//  Thebes
//
//  Created by Ben on 16/07/2025.
//

import SwiftUI

struct WorkoutsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = WorkoutsViewModel()
    @State private var showSideMenu = false
    @State private var showSettingsView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.8),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        TopNavBarView(showSideMenu: $showSideMenu)
                        
                        VStack(spacing: 8) {
                            Text("Workouts")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Manage your training sessions")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                    }
                    
                    WorkoutHeaderView(viewModel: viewModel)
                    MostRecentWorkoutView(viewModel: viewModel)
                    WorkoutsActionsSection()
                    TemplatesActionsSection()
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                guard let userId = authViewModel.user?.uid else {
                    print("⚠️ No valid user ID found. Skipping WorkoutsView data load.")
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
}

struct WorkoutHeaderView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: WorkoutsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Section
            HStack(spacing: 16) {
                if let imageUrl = viewModel.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppColors.secondary.opacity(0.3), lineWidth: 2)
                    )
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.gray)
                        .overlay(
                            Circle()
                                .stroke(AppColors.secondary.opacity(0.3), lineWidth: 2)
                        )
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
            
            // Stats Section
            HStack(spacing: 16) {
                StatItem(
                    value: "\(viewModel.workoutCountLast30Days)",
                    label: "30 Days",
                    icon: "calendar.badge.clock",
                    color: .blue
                )
                
                StatItem(
                    value: "7",
                    label: "Streak",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatItem(
                    value: "42",
                    label: "Total",
                    icon: "trophy.fill",
                    color: .yellow
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
        .padding(.horizontal, 20)
    }
}

struct MostRecentWorkoutView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: WorkoutsViewModel
    
    var body: some View {
        if let workout = viewModel.mostRecentWorkout {
            NavigationLink(destination: workoutDetailView(for: workout)) {
                WorkoutCard(workout: workout)
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

struct WorkoutCard: View {
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


struct WorkoutsActionsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                
                Text("Workouts")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                NavigationLink(destination: WorkoutsListView().environmentObject(authViewModel)) {
                    QuickActionButton(
                        title: "View All",
                        icon: "list.bullet",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: WorkoutLogView(userId: authViewModel.user?.uid ?? "").environmentObject(authViewModel)) {
                    QuickActionButton(
                        title: "Log Workout",
                        icon: "plus.circle.fill",
                        color: AppColors.secondary
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

struct TemplatesActionsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Templates")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                NavigationLink(destination: TemplatesListView().environmentObject(authViewModel)) {
                    QuickActionButton(
                        title: "View All",
                        icon: "list.bullet",
                        color: .green
                    )
                }
                
                NavigationLink(destination: TemplateLogView(userId: authViewModel.user?.uid ?? "").environmentObject(authViewModel)) {
                    QuickActionButton(
                        title: "Create Template",
                        icon: "plus.circle.fill",
                        color: .green
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
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}


