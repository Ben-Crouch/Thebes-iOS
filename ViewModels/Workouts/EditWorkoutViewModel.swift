//
//  EditWorkoutViewModel.swift
//  Thebes
//
//  Created by Ben on 10/03/2025.
//

import Foundation
import SwiftUI

class EditWorkoutViewModel: ObservableObject, ExerciseHandlingProtocol {
    @Published var showToast: Bool = false
    @Published var workout: Workout
    @Published var originalExercises: [Exercise] = []
    @Published var exercises: [Exercise] = []
    @Published var notes: String
    @Published var isLoading: Bool = false

    let userId: String

    init(workout: Workout, userId: String) {
        self.userId = userId
        self.workout = workout
        self.notes = workout.notes ?? ""
        
        guard !userId.isEmpty else {
            print("❌ Empty userId passed to EditWorkoutViewModel")
            return
        }

        guard let workoutId = workout.id, !workoutId.isEmpty else {
            print("❌ Invalid workout ID during EditWorkoutViewModel init")
            return
        }

        print("✅ Initializing EditWorkoutViewModel with ID: \(workoutId) and userID: \(userId)")
        fetchExercises(for: workoutId)
    }
    
    // MARK: - Fetch exercises from Firestore
    private func fetchExercises(for workoutId: String) {
        isLoading = true
        ExerciseService.shared.fetchExercisesForWorkout(userId: userId, workoutId: workoutId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedExercises):
                    self.exercises = fetchedExercises
                    self.originalExercises = fetchedExercises // Store original state for diff later
                case .failure(let error):
                    print("❌ Error fetching exercises: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }

    // MARK: - Exercise handling
    func addExercise() {
        exercises.append(Exercise(
            workoutId: workout.id,
            userId: self.userId,
            name: "",
            sets: [SetData(reps: 0, weight: 0.0)]
        ))
    }

    func removeExercise(at index: Int) {
        exercises.remove(at: index)
    }

    func addSet(to exerciseIndex: Int) {
        let lastSet = exercises[exerciseIndex].sets.last
        exercises[exerciseIndex].sets.append(
            SetData(
                reps: lastSet?.reps ?? 0,
                weight: lastSet?.weight,
                restTime: lastSet?.restTime
            )
        )
    }

    func removeSet(from exerciseIndex: Int, at setIndex: Int) {
        exercises[exerciseIndex].sets.remove(at: setIndex)
    }

    func showRestTime(for exerciseIndex: Int, isEnabled: Bool) {
        for index in exercises[exerciseIndex].sets.indices {
            exercises[exerciseIndex].sets[index].restTime = isEnabled ? 120 : nil
        }
    }

    func toggleBodyweight(for exerciseIndex: Int) {
        let isCurrentlyBodyweight = exercises[exerciseIndex].sets.allSatisfy { $0.weight == nil }
        for index in exercises[exerciseIndex].sets.indices {
            exercises[exerciseIndex].sets[index].weight = isCurrentlyBodyweight ? 0.0 : nil
        }
    }

    // MARK: - Save workout updates (with exercise deletion handling)
    func saveEdits(completion: @escaping () -> Void) {
        guard !workout.title.isEmpty, !exercises.isEmpty else {
            print("❌ Workout title or exercises cannot be empty")
            return
        }

        workout.notes = notes.isEmpty ? nil : notes

        WorkoutService.shared.updateWorkout(workout: workout) { workoutResult in
            switch workoutResult {
            case .success():
                let dispatchGroup = DispatchGroup()

                // Handle save/update for current exercises
                for exercise in self.exercises {
                    dispatchGroup.enter()
                    
                    if exercise.id == nil {
                        ExerciseService.shared.saveExercise(exercise: exercise) { _ in
                            dispatchGroup.leave()
                        }
                    } else {
                        ExerciseService.shared.updateExercise(exercise: exercise) { _ in
                            dispatchGroup.leave()
                        }
                    }
                }

                // Identify and delete removed exercises
                let deletedExercises = self.originalExercises.filter { original in
                    !self.exercises.contains(where: { $0.id == original.id })
                }

                for deletedExercise in deletedExercises {
                    if let id = deletedExercise.id {
                        dispatchGroup.enter()
                        ExerciseService.shared.deleteExercise(exerciseId: id) { _ in
                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.showToast = true
                    // Toast will auto-hide after 2.5 seconds (handled by ToastView)
                    // Call completion immediately - view will handle timing for dismiss
                    completion()
                }

            case .failure(let error):
                print("❌ Failed to update workout: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delete workout
    func deleteWorkout(completion: @escaping () -> Void) {
        guard let workoutId = workout.id else { return }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ExerciseService.shared.deleteExercisesForWorkout(workoutId: workoutId) { _ in
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        WorkoutService.shared.deleteWorkout(workoutId: workoutId) { _ in
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}
