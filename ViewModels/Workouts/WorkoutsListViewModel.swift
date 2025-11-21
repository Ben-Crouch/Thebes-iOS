//
//  WorkoutsListViewModel.swift
//  Thebes
//
//  Created by Ben on 23/07/2025.
//

import Foundation

class WorkoutsListViewModel: ObservableObject {
    @Published var username: String = "test"
    @Published var profileImageUrl: String? = nil
    @Published var selectedAvatar: DefaultAvatar = .teal
    @Published var useGradientAvatar: Bool = false
    @Published var workoutCountLast30Days: Int = 0
    @Published var workouts: [Workout] = []
    @Published var canLoadMore: Bool = true
    private var lastFetchedDate: Date? = nil
    private let pageSize = 5
    
    func loadUserProfile(for userId: String) {
        guard !userId.isEmpty else {
            print("⚠️ loadUserProfile called with empty userId. Skipping fetch.")
            return
        }
        UserService.shared.fetchUserProfile(userId: userId) { userProfile in
            DispatchQueue.main.async {
                guard let profile = userProfile else { return }
                self.username = profile.displayName
                self.profileImageUrl = profile.profilePic
                self.selectedAvatar = DefaultAvatar.from(rawValue: profile.selectedAvatar)
                self.useGradientAvatar = profile.useGradientAvatar ?? false
            }
        }
    }
    
    func loadRecentWorkouts(for userId: String) {
        guard !userId.isEmpty else {
            print("⚠️ loadRecentWorkouts called with empty userId. Skipping fetch.")
            return
        }
        WorkoutService.shared.fetchWorkouts(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let workouts):
                    
                    self.workouts = workouts
                    // update pagination markers
                    self.lastFetchedDate = workouts.last?.date
                    self.canLoadMore = workouts.count == self.pageSize
                    
                    let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                    let recentCount = workouts.filter { $0.date >= cutoff }.count
                    self.workoutCountLast30Days = recentCount
                case .failure(let error):
                    print("❌ Failed to fetch most recent workout: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadMoreWorkouts(for userId: String) {
        guard !userId.isEmpty else {
            print("⚠️ loadMoreWorkouts called with empty userId. Skipping fetch.")
            return
        }
        guard let lastDate = lastFetchedDate else {
            print("⚠️ No lastFetchedDate set, cannot load more.")
            return
        }

        WorkoutService.shared.fetchMoreWorkouts(for: userId, startAfter: lastDate, limit: pageSize) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let moreWorkouts):
                    if moreWorkouts.isEmpty {
                        self.canLoadMore = false
                    } else {
                        self.workouts.append(contentsOf: moreWorkouts)
                        self.lastFetchedDate = moreWorkouts.last?.date
                        self.canLoadMore = moreWorkouts.count == self.pageSize
                    }
                case .failure(let error):
                    print("❌ Failed to load more workouts: \(error.localizedDescription)")
                }
            }
        }
    }

}
