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
                
                Text("Recent Activity")
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
            
            Text("Latest workouts from your network")
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
        .background(Color.black.edgesIgnoringSafeArea(.all))
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
    RecentActivityView()
        .environmentObject(AuthViewModel())
}
