//
//  WorkoutsViewModel.swift
//  Thebes
//
//  Created by Ben on 17/07/2025.
//

import Foundation

class WorkoutsViewModel: ObservableObject {
    @Published var username: String = "test"
    @Published var profileImageUrl: String? = nil
    @Published var selectedAvatar: DefaultAvatar = .teal
    @Published var useGradientAvatar: Bool = false
    @Published var workoutCountLast30Days: Int = 0
    @Published var mostRecentWorkout: Workout? = nil
    @Published var tagline: UserTagline = .fitnessEnthusiast
    @Published var avgWorkoutsPerWeek: Double = 0
    @Published var totalSetsLast30Days: Int = 0
    
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
                    self.updateAvgWorkoutsPerWeek(from: workouts)
                    self.loadTotalSetsLast30Days(for: userId)
                case .failure(let error):
                    print("❌ Failed to fetch most recent workout: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateAvgWorkoutsPerWeek(from workouts: [Workout]) {
        let cutoff = Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date()) ?? Date()
        let countLast8Weeks = workouts.filter { $0.date >= cutoff }.count
        avgWorkoutsPerWeek = Double(countLast8Weeks) / 8.0
    }

    private func loadTotalSetsLast30Days(for userId: String) {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        ExerciseService.shared.fetchExercisesForUserSince(userId: userId, startDate: cutoff) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let exercises):
                    self.totalSetsLast30Days = exercises.reduce(0) { $0 + $1.sets.count }
                case .failure(let error):
                    print("❌ Failed to fetch recent exercises: \(error.localizedDescription)")
                    self.totalSetsLast30Days = 0
                }
            }
        }
    }
}
