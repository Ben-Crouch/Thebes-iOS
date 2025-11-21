//
//  HomeViewModel.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var username: String = "test"
    @Published var profileImageUrl: String? = nil
    @Published var selectedAvatar: DefaultAvatar = .teal
    @Published var useGradientAvatar: Bool = false
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var workoutCountLast30Days: Int = 0
    @Published var mostRecentWorkout: Workout? = nil
    @Published var trackedExercise: String? = nil
    @Published var tagline: UserTagline = .fitnessEnthusiast
    
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
                self.followerCount = profile.followers.count
                self.followingCount = profile.following.count
                self.trackedExercise = profile.trackedExercise
                AppSettings.shared.updatePreferredUnit(WeightUnit(fromPreferredUnit: profile.preferredWeightUnit))
                self.tagline = UserTagline.from(rawValue: profile.tagline)
            }
        }
    }
    
    func loadMostRecentWorkout(for userId: String) {
        guard !userId.isEmpty else {
            print("⚠️ loadMostRecentWorkout called with empty userId. Skipping fetch.")
            return
        }
        WorkoutService.shared.fetchWorkouts(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let workouts):
                    let sorted = workouts.sorted { $0.date > $1.date }
                    self.mostRecentWorkout = sorted.first
                    // Calculate workouts in last 30 days
                    let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                    let recentCount = workouts.filter { $0.date >= cutoff }.count
                    self.workoutCountLast30Days = recentCount
                case .failure(let error):
                    print("❌ Failed to fetch most recent workout: \(error.localizedDescription)")
                }
            }
        }
    }
}
