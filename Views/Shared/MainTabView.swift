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
        UITabBar.appearance().backgroundColor = UIColor.clear // Changed to clear to allow gradient through
        UITabBar.appearance().isTranslucent = true
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
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }

                    NavigationStack {
                        WorkoutsView()
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("Workouts")
                    }

                    NavigationStack {
                        ChallengeView()
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "flag")
                        Text("Challenges")
                    }

                    NavigationStack {
                        TrackerView(viewModel: TrackerViewModel(userId: authViewModel.user?.uid ?? ""))
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Tracker")
                    }

                    NavigationStack {
                        SocialView()
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Social")
                    }
                }
                .accentColor(AppColors.secondary)
        }
    }
}
