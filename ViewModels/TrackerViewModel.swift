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
    @Published var profileImageUrl: String? = nil
    @Published var selectedAvatar: DefaultAvatar = .teal
    @Published var useGradientAvatar: Bool = false
    @Published var preferredWeightUnit: WeightUnit = .kilograms
    @Published var selectedTimeRange: String = "3M"
    @Published var trackedExercises: [Exercise] = []
    @Published var allTrackedExercises: [Exercise] = [] // Store all exercises for filtering

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
                    AppSettings.shared.updatePreferredUnit(self.preferredWeightUnit)
                    if let exercise = profileInfo.favoritedExercise, !exercise.isEmpty {
                        self.fetchExercises(for: userId, exerciseName: exercise)
                    }
                case .failure(let error):
                    print("❌ Failed to load user profile info: \(error.localizedDescription)")
                }
            }
        }
        
        // Also fetch full user profile for profile image
        UserService.shared.fetchUserProfile(userId: userId) { userProfile in
            DispatchQueue.main.async {
                if let profile = userProfile {
                    self.profileImageUrl = profile.profilePic
                    self.selectedAvatar = DefaultAvatar.from(rawValue: profile.selectedAvatar)
                    self.useGradientAvatar = profile.useGradientAvatar ?? false
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
        filterExercisesByTimeRange()
    }

    private func fetchExercises(for userId: String, exerciseName: String) {
        TrackerService.shared.fetchExercises(for: userId, exerciseName: exerciseName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let exercises):
                    self.allTrackedExercises = exercises.sorted(by: { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) })
                    self.filterExercisesByTimeRange()
                    print("✅ Loaded \(self.allTrackedExercises.count) exercises for graphing")
                case .failure(let error):
                    print("❌ Failed to load exercises: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func filterExercisesByTimeRange() {
        let now = Date()
        let calendar = Calendar.current
        
        let startDate: Date
        switch selectedTimeRange {
        case "1W":
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case "1M":
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case "3M":
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case "6M":
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "1Y":
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case "All":
            startDate = .distantPast
        default:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        trackedExercises = allTrackedExercises.filter { exercise in
            guard let exerciseDate = exercise.date else { return false }
            return exerciseDate >= startDate
        }
        
        print("✅ Filtered to \(trackedExercises.count) exercises for time range: \(selectedTimeRange)")
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
    
    // MARK: - Volume-Based Analytics
    
    // Total volume (weight × reps) for all sets
    var totalVolume: Double {
        trackedExercises.flatMap { $0.sets }
            .compactMap { set in
                guard let weight = set.weight else { return nil }
                return weight * Double(set.reps)
            }
            .reduce(0, +)
    }
    
    // Number of workout sessions for this exercise
    var workoutFrequency: Int {
        trackedExercises.count
    }
    
    // Average volume per session
    var averageVolumePerSession: Double {
        guard workoutFrequency > 0 else { return 0 }
        return totalVolume / Double(workoutFrequency)
    }
    
    // Volume progression (average change per session over time)
    var volumeProgression: Double {
        let sessionVolumes = trackedExercises.compactMap { exercise in
            let sessionVolume = exercise.sets.compactMap { set in
                guard let weight = set.weight else { return nil }
                return weight * Double(set.reps)
            }.reduce(0.0) { $0 + $1 }
            return sessionVolume > 0 ? sessionVolume : nil
        }
        
        guard sessionVolumes.count >= 3 else { return 0 }
        
        // Calculate linear regression slope to get average change per session
        let n = Double(sessionVolumes.count)
        let xValues = Array(0..<sessionVolumes.count).map { Double($0) }
        let yValues = sessionVolumes
        
        let sumX = xValues.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map(*).reduce(0, +)
        let sumXX = xValues.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        
        // Return the total progression over the period (slope * number of sessions)
        return slope * n
    }
    
    // Volume progression percentage (how much volume has changed overall)
    var volumeProgressionPercentage: Double {
        let sessionVolumes = trackedExercises.compactMap { exercise in
            let sessionVolume = exercise.sets.compactMap { set in
                guard let weight = set.weight else { return nil }
                return weight * Double(set.reps)
            }.reduce(0.0) { $0 + $1 }
            return sessionVolume > 0 ? sessionVolume : nil
        }
        
        guard sessionVolumes.count >= 2,
              let firstVolume = sessionVolumes.first,
              let lastVolume = sessionVolumes.last,
              firstVolume > 0 else { return 0 }
        
        return ((lastVolume - firstVolume) / firstVolume) * 100
    }
    
    // Average reps per set
    var averageRepsPerSet: Double {
        let allReps = trackedExercises.flatMap { $0.sets }.map { Double($0.reps) }
        guard !allReps.isEmpty else { return 0 }
        return allReps.reduce(0.0) { $0 + $1 } / Double(allReps.count)
    }
    
    // Volume consistency (standard deviation of session volumes)
    var volumeConsistency: Double {
        let sessionVolumes = trackedExercises.compactMap { exercise in
            let sessionVolume = exercise.sets.compactMap { set in
                guard let weight = set.weight else { return nil }
                return weight * Double(set.reps)
            }.reduce(0.0) { $0 + $1 }
            return sessionVolume > 0 ? sessionVolume : nil
        }
        
        guard sessionVolumes.count >= 2 else { return 0 }
        
        let mean = sessionVolumes.reduce(0.0) { $0 + $1 } / Double(sessionVolumes.count)
        let variance = sessionVolumes.map { pow($0 - mean, 2) }.reduce(0.0) { $0 + $1 } / Double(sessionVolumes.count)
        return sqrt(variance)
    }
    
    // Best single session volume
    var bestSessionVolume: Double {
        trackedExercises.compactMap { exercise in
            let sessionVolume = exercise.sets.compactMap { set in
                guard let weight = set.weight else { return nil }
                return weight * Double(set.reps)
            }.reduce(0.0) { $0 + $1 }
            return sessionVolume > 0 ? sessionVolume : nil
        }.max() ?? 0
    }
}
