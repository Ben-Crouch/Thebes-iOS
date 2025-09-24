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
    
    
var body: some View {
    ZStack(alignment: .top) {
        VStack{
            TopNavBarView(showSideMenu: $showSideMenu)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
            ProfileHeaderView(viewModel: viewModel)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
            
            FavoritedTrackerSection(viewModel: viewModel)
            MostRecentWorkoutView(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .zIndex(0)
        .onAppear {
            guard let userId = authViewModel.user?.uid else {
                print("⚠️ No valid user ID found. Skipping HomeView data load.")
                return
            }
            viewModel.loadUserProfile(for: userId)
            viewModel.loadMostRecentWorkout(for: userId)
        }
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
}
        
        /*private var logoutButton: some View {
         Button(action: { authViewModel.signOut() }) {
         Text("Logout")
         .font(.headline)
         .foregroundColor(.white)
         .padding()
         .frame(maxWidth: .infinity)
         .background(Color.red)
         .cornerRadius(8)
         }
         .padding()
         }*/
    
    struct ProfileHeaderView: View {
        @ObservedObject var viewModel: HomeViewModel
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    if let imageUrl = viewModel.profileImageUrl,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    }

                    Text(viewModel.username)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }
                
                // Stats
                HStack {
                    HStack(spacing: 24) {
                        VStack {
                            Text("\(viewModel.followerCount)")
                                .bold()
                                .foregroundColor(.white)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        VStack {
                            Text("\(viewModel.followingCount)")
                                .bold()
                                .foregroundColor(.white)
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        VStack {
                            Text("\(viewModel.workoutCountLast30Days)")
                                .bold()
                                .foregroundColor(.white)
                            Text("Last 30 Days")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
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
                    VStack(alignment: .leading) {
                        Text("Exercise Tracker")
                            .font(.headline)
                            .foregroundColor(AppColors.secondary)
                        
                        Text(tracker)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .border(AppColors.primary, width: 3)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    struct MostRecentWorkoutView: View {
        @ObservedObject var viewModel: HomeViewModel
        @EnvironmentObject var authViewModel: AuthViewModel
        
        var body: some View {
            if let workout = viewModel.mostRecentWorkout {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Most Recent Workout")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)
                    
                    let viewModel = WorkoutDetailViewModel(currentUserId: authViewModel.user?.uid ?? "", workout: workout)
                    NavigationLink(destination: WorkoutDetailView(viewModel: viewModel)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(workout.title)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text(workout.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .border(AppColors.primary, width: 3)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
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
