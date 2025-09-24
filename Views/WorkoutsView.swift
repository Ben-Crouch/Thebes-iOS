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
    
    var body: some View {
        ZStack(alignment: .top){
            VStack{
                TopNavBarView(showSideMenu: $showSideMenu)
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                WorkoutHeaderView(viewModel: viewModel)
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                MostRecentWorkoutView(viewModel: viewModel)
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .padding()
                
                WorkoutsActionsSection()
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .padding()
                
                TemplatesActionsSection()
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                guard let userId = authViewModel.user?.uid else {
                    print("⚠️ No valid user ID found. Skipping HomeView data load.")
                    return
                }
                viewModel.loadUserProfile(for: userId)
                viewModel.loadMostRecentWorkout(for: userId)
            }
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

struct WorkoutHeaderView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: WorkoutsViewModel
    
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
                    Text(" Workouts in the last 30 Days: ")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("\(viewModel.workoutCountLast30Days)")
                        .bold()
                        .foregroundColor(AppColors.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct MostRecentWorkoutView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: WorkoutsViewModel
    
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

struct WorkoutsActionsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workouts")
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .padding(.horizontal)

            NavigationLink(destination: WorkoutsListView().environmentObject(authViewModel)) {
                Text("See All Workouts")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.secondary.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            NavigationLink(destination: WorkoutLogView(userId: authViewModel.user?.uid ?? "").environmentObject(authViewModel)) {
                Text("+ Add Workout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.secondary)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
    }
}

struct TemplatesActionsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Templates")
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .padding(.horizontal)

            NavigationLink(destination: TemplatesListView().environmentObject(authViewModel)) {
                Text("See All Templates")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.secondary.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            NavigationLink(destination: TemplateLogView(userId: authViewModel.user?.uid ?? "").environmentObject(authViewModel)) {
                Text("+ Add Template")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.secondary)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
    }
}

