//
//  WorkoutsListView.swift
//  Thebes
//
//  Created by Ben on 23/07/2025.
//

import SwiftUI

struct WorkoutsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = WorkoutsListViewModel()
    @State private var showSideMenu = false
    
    var body: some View {
        ZStack(alignment: .top){
            Color.black.ignoresSafeArea()
            VStack{
                TopNavBarView(showSideMenu: $showSideMenu)
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                WorkoutsListHeaderView(viewModel: viewModel)
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                WorkoutsListSectionView(viewModel: viewModel)
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                guard let userId = authViewModel.user?.uid else {
                    print("⚠️ No valid user ID found. Skipping HomeView data load.")
                    return
                }
                viewModel.loadUserProfile(for: userId)
                viewModel.loadRecentWorkouts(for: userId)
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

struct WorkoutsListHeaderView: View {
    @ObservedObject var viewModel: WorkoutsListViewModel

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

struct WorkoutsListSectionView: View {
    @ObservedObject var viewModel: WorkoutsListViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showDetail = false
    @State private var selectedWorkout: Workout? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                ForEach(viewModel.workouts, id: \.id) { workout in
                    Button {
                        selectedWorkout = workout
                        showDetail = true
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(workout.title)
                                .font(.headline)
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
                
                if viewModel.canLoadMore {
                    Button(action: {
                        viewModel.loadMoreWorkouts(for: authViewModel.user?.uid ?? "")
                    }) {
                        Text("Load More")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.secondary)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
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
    }
}
