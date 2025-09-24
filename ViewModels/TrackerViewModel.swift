//
//  TrackerViewModel.swift
//  Thebes
//
//  Created by Ben on 23/04/2025.
//

import Foundation

class TrackerViewModel: ObservableObject {
    private let userId: String

    @Published var selectedExercise: String? = nil
    @Published var allExerciseNames: [String] = []
    @Published var favoritedExercise: String? = nil
    @Published var displayName: String = "User"
    @Published var preferredWeightUnit: String = "kg"
    @Published var selectedTimeRange: String = "3M"
    @Published var trackedExercises: [Exercise] = []

    let timeRanges = ["1W", "1M", "3M", "6M", "1Y", "All"]

    init(userId: String) {
        guard !userId.isEmpty else {
            print("⚠️ TrackerViewModel initialized with empty userId. Skipping fetch.")
            self.userId = ""
            return
        }
        self.userId = userId

        TrackerService.shared.fetchUserProfileInfo(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileInfo):
                    self.displayName = profileInfo.displayName
                    self.favoritedExercise = profileInfo.favoritedExercise
                    self.selectedExercise = profileInfo.favoritedExercise
                    self.preferredWeightUnit = profileInfo.preferredWeightUnit
                    if let exercise = profileInfo.favoritedExercise, !exercise.isEmpty {
                        self.fetchExercises(for: userId, exerciseName: exercise)
                    }
                case .failure(let error):
                    print("❌ Failed to load user profile info: \(error.localizedDescription)")
                }
            }
        }

        TrackerService.shared.fetchDistinctExerciseNames(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let names):
                    self.allExerciseNames = names
                case .failure(let error):
                    print("❌ Failed to load exercise names: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateSelectedExercise(_ exercise: String) {
        self.selectedExercise = exercise
        fetchExercises(for: userId, exerciseName: exercise)
    }

    func updateSelectedTimeRange(_ range: String) {
        self.selectedTimeRange = range
        if let exercise = selectedExercise {
            fetchExercises(for: userId, exerciseName: exercise)
        }
    }

    private func fetchExercises(for userId: String, exerciseName: String) {
        TrackerService.shared.fetchExercises(for: userId, exerciseName: exerciseName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let exercises):
                    self.trackedExercises = exercises.sorted(by: { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) })
                    print("✅ Loaded \(self.trackedExercises.count) exercises for graphing")
                case .failure(let error):
                    print("❌ Failed to load exercises: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Check if all sets are bodyweight (weight == nil)
    var isBodyweightExercise: Bool {
        trackedExercises.allSatisfy { $0.sets.allSatisfy { $0.weight == nil } }
    }

    // Total sets in the time range
    var totalSets: Int {
        trackedExercises.reduce(0) { $0 + $1.sets.count }
    }

    // Best estimated one-rep max across all sets
    var bestEORM: Double {
        trackedExercises.flatMap { $0.sets }
            .compactMap { set in
                guard let weight = set.weight else { return nil }
                return weight * (1 + 0.0333 * Double(set.reps))
            }
            .max() ?? 0
    }

    // EORM change from first to best
    var eormChange: Double {
        let eorms: [Double] = trackedExercises.flatMap { $0.sets }.compactMap { set in
            guard let weight = set.weight else { return nil }
            return weight * (1 + 0.0333 * Double(set.reps))
        }

        guard let first = eorms.first else { return 0 }
        return (eorms.max() ?? 0) - first
    }

    // Best reps across all bodyweight sets
    var bestReps: Int {
        trackedExercises.flatMap { $0.sets }
            .compactMap { $0.weight == nil ? $0.reps : nil }
            .max() ?? 0
    }

    // Rep change from first to best
    var repsChange: Int {
        let reps = trackedExercises.flatMap { $0.sets }
            .compactMap { $0.weight == nil ? $0.reps : nil }
        guard let first = reps.first else { return 0 }
        return (reps.max() ?? 0) - first
    }
}
