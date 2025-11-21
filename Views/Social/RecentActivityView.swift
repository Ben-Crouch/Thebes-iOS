//
import SwiftUI
//  RecentActivityView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct RecentActivityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = RecentActivityViewModel()
    @State private var isLoading = true
    @State private var selectedWorkoutId: String? = nil
    @State private var showWorkoutDetail = false
    @Environment(\.dismiss) private var dismiss
    
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
                        
                        Text("Recent Activity")
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
                        Text("Latest workouts from your network")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            // Content
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                        .scaleEffect(1.2)
                    
                    Text("Loading recent activity...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.recentWorkouts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No Recent Activity")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Start following people to see their workout activity here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.recentWorkouts, id: \.id) { workoutActivity in
                            Button(action: {
                                print("🔵 [RecentActivityView] Card tapped: \(workoutActivity.workoutTitle)")
                                if let workoutId = workoutActivity.workoutId {
                                    print("🔵 [RecentActivityView] Setting selectedWorkoutId: \(workoutId)")
                                    selectedWorkoutId = workoutId
                                    showWorkoutDetail = true
                                    print("🔵 [RecentActivityView] showWorkoutDetail set to: true")
                                } else {
                                    print("⚠️ [RecentActivityView] workoutId is nil!")
                                }
                            }) {
                                RecentWorkoutCardContent(workout: workoutActivity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                }
            }
        }
        .navigationDestination(isPresented: $showWorkoutDetail) {
            if let workoutId = selectedWorkoutId,
               let currentUserId = authViewModel.user?.uid {
                WorkoutDetailViewWrapper(
                    workoutId: workoutId,
                    currentUserId: currentUserId
                )
                .environmentObject(authViewModel)
                .onDisappear {
                    selectedWorkoutId = nil
                    showWorkoutDetail = false
                }
            }
        }
        .onAppear {
            if let userId = authViewModel.user?.uid {
                viewModel.fetchRecentActivity(for: userId) {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
            }
        }
    }
}

struct RecentWorkoutCardContent: View {
    let workout: RecentWorkoutActivity
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info and timestamp
            HStack {
                // User avatar
                ProfileAvatarView(
                    profilePic: workout.userProfilePic,
                    selectedAvatar: .teal, // Default since we don't have selectedAvatar in RecentWorkoutActivity
                    size: 32
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.userDisplayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(workout.workoutDate, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Workout details
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.workoutTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !workout.exerciseCount.isEmpty {
                    Text("\(workout.exerciseCount) exercises")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondary)
                }
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

struct WorkoutDetailViewWrapper: View {
    let workoutId: String
    let currentUserId: String
    @State private var workout: Workout? = nil
    @State private var isLoading = true
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                        .scaleEffect(1.5)
                    
                    Text("Loading workout...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            } else if let workout = workout {
                WorkoutDetailView(
                    viewModel: WorkoutDetailViewModel(
                        currentUserId: currentUserId,
                        workout: workout
                    )
                )
                .environmentObject(authViewModel)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.system(size: 48))
                    
                    Text("Workout not found")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
        .onAppear {
            print("📡 WorkoutDetailViewWrapper: Loading workout with ID: \(workoutId)")
            WorkoutService.shared.fetchWorkout(workoutId: workoutId) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let fetchedWorkout):
                        print("✅ WorkoutDetailViewWrapper: Successfully loaded workout: \(fetchedWorkout.title)")
                        workout = fetchedWorkout
                    case .failure(let error):
                        print("❌ WorkoutDetailViewWrapper: Error loading workout: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    RecentActivityView()
        .environmentObject(AuthViewModel())
}
