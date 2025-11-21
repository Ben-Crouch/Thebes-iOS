//
//  WorkoutLogViewModel.swift
//  Thebes
//
//  Created by Ben on 20/02/2025.
//

import SwiftUI

class WorkoutLogViewModel: ObservableObject, ExerciseHandlingProtocol {
    @Published var templates: [Template] = []
    @Published var showToast: Bool = false
    @Published var workoutTitle: String = ""
    @Published var workoutDate: Date? = Date()
    @Published var exercises: [Exercise] = []
    @Published var notes: String? = ""
    @Published var showSaveConfirmation = false
    @Published var showRestTime: Bool = false // ✅ Tracks Rest Time visibility
    
    // Callback for when save completes (used to delay dismiss until after toast is visible)
    var onSaveComplete: (() -> Void)?
    
    private let userId: String
    
    init(userId: String, workout: Workout? = nil) {
        print("🔥 WorkoutLogViewModel initialized")
        self.userId = userId
        if let workout = workout {
            self.workoutTitle = workout.title
            self.notes = workout.notes ?? ""
            self.workoutDate = workout.date
        } else {
            // Start with one empty exercise
            self.exercises = [Exercise(
                workoutId: nil,
                templateId: nil,
                userId: self.userId,
                name: "",
                sets: [SetData(reps: 0, weight: 0.0, restTime: nil)]
            )]
        }
    }

    // MARK: - Add Exercise
    func addExercise() {
        let newExercise = Exercise(
            workoutId: nil,
            templateId: nil,
            userId: self.userId,
            name: "",
            sets: [SetData(reps: 0, weight: 0.0, restTime: nil)]
        )
        exercises.append(newExercise)
    }

    func removeExercise(at index: Int) {
        guard index < exercises.count else { return }
        exercises.remove(at: index)
    }

    // MARK: - Add Set to an Exercise
    func addSet(to exerciseIndex: Int) {
        guard exerciseIndex < exercises.count else { return }

        let lastSet = exercises[exerciseIndex].sets.last
        let newRestTime = lastSet?.restTime
        let newReps = lastSet?.reps ?? 0
        let newWeightValue = lastSet?.weight

        exercises[exerciseIndex].sets.append(
            SetData(reps: newReps, weight: newWeightValue, restTime: newRestTime)
        )
    }

    func removeSet(from exerciseIndex: Int, at setIndex: Int) {
        guard exerciseIndex < exercises.count, setIndex < exercises[exerciseIndex].sets.count else { return }
        exercises[exerciseIndex].sets.remove(at: setIndex)
    }

    func showRestTime(for exerciseIndex: Int, isEnabled: Bool) {
        guard exerciseIndex < exercises.count else { return }
        for index in exercises[exerciseIndex].sets.indices {
            exercises[exerciseIndex].sets[index].restTime = isEnabled ? 120 : nil
        }
    }

    func toggleBodyweight(for exerciseIndex: Int) {
        guard exerciseIndex < exercises.count else { return }
        let isBodyweight = exercises[exerciseIndex].sets.allSatisfy { $0.weight == nil }
        for index in exercises[exerciseIndex].sets.indices {
            exercises[exerciseIndex].sets[index].weight = isBodyweight ? 0.0 : nil
        }
    }
    
    func loadTemplates() {
        TemplateService.shared.fetchTemplates(for: userId) { [weak self] result in
            switch result {
            case .success(let fetchedTemplates):
                DispatchQueue.main.async {
                    self?.templates = fetchedTemplates
                }
            case .failure(let error):
                print("Error fetching templates: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Save Workout
    func save() {
        guard !workoutTitle.isEmpty, !exercises.isEmpty else {
            print("❌ Workout title or exercises cannot be empty")
            return
        }

        let newWorkout = Workout(
            title: workoutTitle,
            date: workoutDate ?? Date(),
            notes: notes?.isEmpty == true ? nil : notes,
            userId: self.userId
        )

        WorkoutService.shared.saveWorkout(workout: newWorkout) { result in
            switch result {
            case .success(let workoutId):
                print("✅ Workout saved with ID: \(workoutId)")
                self.saveExercises(for: workoutId, date: newWorkout.date) {
                    self.resetFields()
                    DispatchQueue.main.async {
                        self.showToast = true
                        // Toast will auto-hide after 2.5 seconds (handled by ToastView)
                        // Use this completion to signal view can dismiss after toast is visible
                        self.onSaveComplete?()
                    }
                }
            case .failure(let error):
                print("❌ Error saving workout: \(error.localizedDescription)")
            }
        }
    }

    private func saveExercises(for workoutId: String, date: Date, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        for exercise in exercises {
            dispatchGroup.enter()
            let exerciseToSave = Exercise(
                workoutId: workoutId,
                templateId: nil,
                userId: self.userId,
                name: exercise.name,
                sets: exercise.sets,
                date: date
            )

            ExerciseService.shared.saveExercise(exercise: exerciseToSave) { result in
                if case .failure(let error) = result {
                    print("❌ Error saving exercise: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("✅ All exercises saved.")
            completion()
        }
    }

    private func resetFields() {
        workoutTitle = ""
        workoutDate = Date()
        exercises.removeAll()
        notes = ""
        showSaveConfirmation = true
    }
    
    func applyTemplate(_ template: Template) {
        guard let templateId = template.id else {
            print("❌ Template ID is nil")
            return
        }
        ExerciseService.shared.fetchExercisesForTemplate(userId: self.userId, templateId: templateId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let templateExercises):
                DispatchQueue.main.async {
                    self.exercises = templateExercises.map { exercise in
                        Exercise(
                            workoutId: nil,
                            templateId: nil,
                            userId: self.userId,
                            name: exercise.name,
                            sets: exercise.sets
                        )
                    }
                }
            case .failure(let error):
                print("❌ Error loading exercises from template: \(error.localizedDescription)")
            }
        }
    }
}
