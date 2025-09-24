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
                    ZStack {
                        Color.black.ignoresSafeArea()
                        HomeView()
                    }
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

                NavigationStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        WorkoutsView()
                    }
                }
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Workouts")
                }

                NavigationStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        //ChallengesView()
                    }
                }
                .tabItem {
                    Image(systemName: "flag")
                    Text("Challenges")
                }

                NavigationStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        TrackerView(viewModel: TrackerViewModel(userId: authViewModel.user?.uid ?? ""))
                    }
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
