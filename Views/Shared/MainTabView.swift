//
//  MainTabView.swift
//  Thebes
//
//  Created by Ben on 07/05/2025.
//

import SwiftUI

struct MainTabView: View {
    init() {
        // Use UITabBarAppearance for transparent background with border
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Transparent background
        appearance.backgroundColor = .clear
        
        // Remove the shadow/separator line for cleaner look
        appearance.shadowColor = .clear
        
        // Styling for normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.7)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        
        // Styling for selected state
        let tealColor = UIColor(red: 20/255, green: 184/255, blue: 166/255, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.iconColor = tealColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: tealColor
        ]
        
        // Apply to all tab bar styles
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Fallback for older iOS versions
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.7)
        UITabBar.appearance().backgroundColor = .clear
        UITabBar.appearance().isTranslucent = true
    }
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        if authViewModel.user == nil {
            EmptyView()
        } else {
            TabView(selection: $selectedTab) {
                    NavigationStack {
                        HomeView()
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                    NavigationStack {
                        WorkoutsView()
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("Workouts")
                    }
                    .tag(1)

                    NavigationStack {
                        ChallengeView()
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "flag")
                        Text("Challenges")
                    }
                    .tag(2)

                    NavigationStack {
                        TrackerView(viewModel: TrackerViewModel(userId: authViewModel.user?.uid ?? ""))
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Tracker")
                    }
                    .tag(3)

                    NavigationStack {
                        SocialView()
                    }
                    .toolbarBackground(.clear, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Social")
                    }
                    .tag(4)
                }
                .accentColor(AppColors.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

