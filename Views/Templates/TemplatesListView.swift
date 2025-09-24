//
//  TemplatesListView.swift
//  Thebes
//
//  Created by Ben on 23/07/2025.
//

import SwiftUI

struct TemplatesListView: View {
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
                
                TemplatesListHeaderView(viewModel: viewModel)
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

struct TemplatesListHeaderView: View {
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
