//
import SwiftUI
//  WorkoutsListView.swift
//  Thebes
//
//  Created by Ben on 23/07/2025.
//

import SwiftUI

struct WorkoutsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = WorkoutsListViewModel()
    @State private var showSideMenu = false
    @State private var showDetail = false
    @State private var selectedWorkout: Workout? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        WorkoutsListHeaderView(viewModel: viewModel)

                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.workouts, id: \.id) { workout in
                                Button {
                                    selectedWorkout = workout
                                    showDetail = true
                                } label: {
                                    WorkoutListItemCard(workout: workout)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)

                        if viewModel.canLoadMore {
                            LoadMoreButton {
                                viewModel.loadMoreWorkouts(for: authViewModel.user?.uid ?? "")
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .onAppear {
                guard let userId = authViewModel.user?.uid else {
                    print("⚠️ No valid user ID found. Skipping WorkoutsListView data load.")
                    return
                }
                viewModel.loadUserProfile(for: userId)
                viewModel.loadRecentWorkouts(for: userId)
            }
            .navigationDestination(isPresented: $showDetail) {
                if let workout = selectedWorkout {
                    WorkoutDetailView(
                        viewModel: WorkoutDetailViewModel(
                            currentUserId: authViewModel.user?.uid ?? "",
                            workout: workout
                        )
                    )
                }
            }
            
            // Side Menu Overlay
            if showSideMenu {
                Color(uiColor: .black).opacity(0.4)
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Workouts")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation { showSideMenu.toggle() }
                }) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct WorkoutsListHeaderView: View {
    @ObservedObject var viewModel: WorkoutsListViewModel
    @Environment(\.colorScheme) var colorScheme

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
                    
                    Text("Workout History")
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
                    value: "\(viewModel.workouts.count)",
                    label: "Total",
                    icon: "list.bullet",
                    color: .green
                )
                
                StatItem(
                    value: "\(viewModel.canLoadMore ? "More" : "All")",
                    label: "Available",
                    icon: "arrow.down.circle",
                    color: .orange
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
        .padding(.top, 16)
    }
}


struct WorkoutListItemCard: View {
    let workout: Workout
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Workout Icon
            Image(systemName: "figure.strengthtraining.traditional")
                .foregroundColor(AppColors.secondary)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppColors.secondary.opacity(0.2))
                )
            
            // Workout Info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Text(workout.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                if let notes = workout.notes, !notes.isEmpty {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct LoadMoreButton: View {
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title3)
                
                Text("Load More Workouts")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.secondary.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
