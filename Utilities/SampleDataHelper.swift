//
//  SampleDataHelper.swift
//  Thebes
//
//  Created for screenshot preparation
//

import Foundation
import FirebaseFirestore

/// Helper class to populate sample data for screenshots
/// ⚠️ This is a temporary utility - remove before production release
class SampleDataHelper {
    static let shared = SampleDataHelper()
    
    private let workoutService = WorkoutService.shared
    private let exerciseService = ExerciseService.shared
    
    /// Populates sample workouts and exercises for a user
    /// Call this once after creating a test account
    func populateSampleData(for userId: String, completion: @escaping (Bool) -> Void) {
        print("📊 Starting sample data population for user: \(userId)")
        
        let group = DispatchGroup()
        var allSuccess = true
        
        // Workout 1: Push Day - Chest & Shoulders (2 days ago)
        group.enter()
        let workout1Date = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        let workout1 = Workout(
            title: "Push Day - Chest & Shoulders",
            date: workout1Date,
            notes: "Great session, felt strong on bench press today!",
            userId: userId
        )
        
        workoutService.saveWorkout(workout: workout1) { result in
            switch result {
            case .success(let workoutId):
                print("✅ Saved workout 1: \(workout1.title)")
                
                // Add exercises for workout 1
                let exercises1 = [
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Bench Press",
                        sets: [
                            SetData(reps: 8, weight: 80.0),
                            SetData(reps: 8, weight: 80.0),
                            SetData(reps: 6, weight: 85.0),
                            SetData(reps: 5, weight: 90.0)
                        ],
                        date: workout1Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Overhead Press",
                        sets: [
                            SetData(reps: 10, weight: 50.0),
                            SetData(reps: 8, weight: 55.0),
                            SetData(reps: 6, weight: 60.0)
                        ],
                        date: workout1Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Incline Dumbbell Press",
                        sets: [
                            SetData(reps: 10, weight: 30.0),
                            SetData(reps: 10, weight: 30.0),
                            SetData(reps: 8, weight: 32.5)
                        ],
                        date: workout1Date
                    )
                ]
                
                self.saveExercises(exercises1, group: group) { success in
                    allSuccess = allSuccess && success
                }
                
            case .failure(let error):
                print("❌ Error saving workout 1: \(error.localizedDescription)")
                allSuccess = false
            }
            group.leave()
        }
        
        // Workout 2: Pull Day - Back & Biceps (4 days ago)
        group.enter()
        let workout2Date = Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date()
        let workout2 = Workout(
            title: "Pull Day - Back & Biceps",
            date: workout2Date,
            notes: "Deadlift PR! Feeling good.",
            userId: userId
        )
        
        workoutService.saveWorkout(workout: workout2) { result in
            switch result {
            case .success(let workoutId):
                print("✅ Saved workout 2: \(workout2.title)")
                
                let exercises2 = [
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Deadlift",
                        sets: [
                            SetData(reps: 5, weight: 140.0),
                            SetData(reps: 5, weight: 150.0),
                            SetData(reps: 3, weight: 160.0)
                        ],
                        date: workout2Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Barbell Row",
                        sets: [
                            SetData(reps: 8, weight: 80.0),
                            SetData(reps: 8, weight: 85.0),
                            SetData(reps: 6, weight: 90.0)
                        ],
                        date: workout2Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Pull-ups",
                        sets: [
                            SetData(reps: 12, weight: nil), // Bodyweight
                            SetData(reps: 10, weight: nil),
                            SetData(reps: 8, weight: nil)
                        ],
                        date: workout2Date
                    )
                ]
                
                self.saveExercises(exercises2, group: group) { success in
                    allSuccess = allSuccess && success
                }
                
            case .failure(let error):
                print("❌ Error saving workout 2: \(error.localizedDescription)")
                allSuccess = false
            }
            group.leave()
        }
        
        // Workout 3: Leg Day (6 days ago)
        group.enter()
        let workout3Date = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        let workout3 = Workout(
            title: "Leg Day",
            date: workout3Date,
            notes: "Tough session but pushed through!",
            userId: userId
        )
        
        workoutService.saveWorkout(workout: workout3) { result in
            switch result {
            case .success(let workoutId):
                print("✅ Saved workout 3: \(workout3.title)")
                
                let exercises3 = [
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Squat",
                        sets: [
                            SetData(reps: 8, weight: 100.0),
                            SetData(reps: 8, weight: 110.0),
                            SetData(reps: 6, weight: 120.0),
                            SetData(reps: 5, weight: 125.0)
                        ],
                        date: workout3Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Romanian Deadlift",
                        sets: [
                            SetData(reps: 10, weight: 100.0),
                            SetData(reps: 8, weight: 110.0),
                            SetData(reps: 8, weight: 110.0)
                        ],
                        date: workout3Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Leg Press",
                        sets: [
                            SetData(reps: 12, weight: 180.0),
                            SetData(reps: 12, weight: 200.0),
                            SetData(reps: 10, weight: 220.0)
                        ],
                        date: workout3Date
                    )
                ]
                
                self.saveExercises(exercises3, group: group) { success in
                    allSuccess = allSuccess && success
                }
                
            case .failure(let error):
                print("❌ Error saving workout 3: \(error.localizedDescription)")
                allSuccess = false
            }
            group.leave()
        }
        
        // Workout 4: Upper Body (1 week ago)
        group.enter()
        let workout4Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let workout4 = Workout(
            title: "Upper Body",
            date: workout4Date,
            notes: "Solid workout, maintaining strength.",
            userId: userId
        )
        
        workoutService.saveWorkout(workout: workout4) { result in
            switch result {
            case .success(let workoutId):
                print("✅ Saved workout 4: \(workout4.title)")
                
                let exercises4 = [
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Bench Press",
                        sets: [
                            SetData(reps: 8, weight: 75.0),
                            SetData(reps: 8, weight: 80.0),
                            SetData(reps: 6, weight: 85.0)
                        ],
                        date: workout4Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Barbell Row",
                        sets: [
                            SetData(reps: 8, weight: 75.0),
                            SetData(reps: 8, weight: 80.0),
                            SetData(reps: 6, weight: 85.0)
                        ],
                        date: workout4Date
                    ),
                    Exercise(
                        workoutId: workoutId,
                        userId: userId,
                        name: "Overhead Press",
                        sets: [
                            SetData(reps: 10, weight: 50.0),
                            SetData(reps: 8, weight: 55.0)
                        ],
                        date: workout4Date
                    )
                ]
                
                self.saveExercises(exercises4, group: group) { success in
                    allSuccess = allSuccess && success
                }
                
            case .failure(let error):
                print("❌ Error saving workout 4: \(error.localizedDescription)")
                allSuccess = false
            }
            group.leave()
        }
        
        // Wait for all workouts to complete
        group.notify(queue: .main) {
            if allSuccess {
                print("✅ All sample data populated successfully!")
            } else {
                print("⚠️ Some sample data failed to populate")
            }
            completion(allSuccess)
        }
    }
    
    private func saveExercises(_ exercises: [Exercise], group: DispatchGroup, completion: @escaping (Bool) -> Void) {
        var successCount = 0
        let totalExercises = exercises.count
        
        for exercise in exercises {
            group.enter()
            exerciseService.saveExercise(exercise: exercise) { result in
                switch result {
                case .success:
                    successCount += 1
                    print("  ✅ Saved exercise: \(exercise.name)")
                case .failure(let error):
                    print("  ❌ Error saving exercise \(exercise.name): \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(successCount == totalExercises)
        }
    }
}

