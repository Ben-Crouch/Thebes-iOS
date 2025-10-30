//
//  MainTabView.swift
//  Thebes
//
//  Created by Ben on 07/05/2025.
//

import SwiftUI

struct MainTabView: View {
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.7)
        UITabBar.appearance().backgroundColor = UIColor.black
    }
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.user == nil {
            EmptyView()
        } else {
            TabView {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

                NavigationStack {
                    WorkoutsView()
                }
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Workouts")
                }

                NavigationStack {
                    //ChallengesView()
                }
                .tabItem {
                    Image(systemName: "flag")
                    Text("Challenges")
                }

                NavigationStack {
                    TrackerView(viewModel: TrackerViewModel(userId: authViewModel.user?.uid ?? ""))
                }
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Tracker")
                }

                NavigationStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        SocialView()
                    }
                }
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Social")
                }
            }
            .accentColor(AppColors.secondary)
        }
    }
}
