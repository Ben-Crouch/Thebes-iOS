//
//  RecentActivityView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct RecentActivityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = RecentActivityViewModel()
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
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
                        ForEach(viewModel.recentWorkouts, id: \.id) { workout in
                            RecentWorkoutCard(workout: workout)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
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

struct RecentWorkoutCard: View {
    let workout: RecentWorkoutActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info and timestamp
            HStack {
                // User avatar
                if let imageUrl = workout.userProfilePic,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.caption)
                        )
                }
                
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

#Preview {
    RecentActivityView()
        .environmentObject(AuthViewModel())
}
