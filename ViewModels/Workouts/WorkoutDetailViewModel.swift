//  WorkoutDetailViewModel.swift
//  Thebes
//
//  Created by Ben on 06/03/2025.
//

import Foundation

class WorkoutDetailViewModel: ObservableObject {
    @Published var expandedExercises: Set<String> = []
    @Published var workout: Workout
    @Published var exercises: [Exercise] = []
    @Published var showSaveConfirmation: Bool = false

    private let currentUserId: String

    var isCurrentUserOwner: Bool {
        return currentUserId == workout.userId
    }

    init(currentUserId: String, workout: Workout) {
        self.currentUserId = currentUserId
        self.workout = workout
        self.exercises = []
        fetchExercises(for: workout.id)
    }

    private func fetchExercises(for workoutId: String?) {
        guard let workoutId = workoutId else { return }
        ExerciseService.shared.fetchExercisesForWorkout(userId: workout.userId, workoutId: workoutId) { result in
            switch result {
            case .success(let fetchedExercises):
                DispatchQueue.main.async {
                    self.exercises = fetchedExercises
                }
            case .failure(let error):
                print("❌ Error fetching exercises: \(error.localizedDescription)")
            }
        }
    }

    // ✅ Format Date (only for workouts)
    func formattedDate() -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: workout.date)
    }

    // ✅ Expand/collapse exercise
    func toggleExerciseExpansion(_ exerciseID: String?) {
        guard let exerciseID = exerciseID else { return }
        if expandedExercises.contains(exerciseID) {
            expandedExercises.remove(exerciseID)
        } else {
            expandedExercises.insert(exerciseID)
        }
    }

    // ✅ Generate set description
    func setDescription(for set: SetData) -> String {
        let weightText = set.weight.map { String(format: "%.1f", $0) + " kg" } ?? "Bodyweight"
        let restText = set.restTime.map { " • Rest: \($0)s" } ?? ""
        return "\(set.reps) reps at \(weightText)\(restText)"
    }
    
    func refreshWorkoutDetails() {
        guard let workoutId = workout.id else {
            print("❌ Workout ID missing — cannot refresh.")
            return
        }

        // Refresh workout metadata
        WorkoutService.shared.fetchWorkouts(for: currentUserId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let workouts):
                    if let updatedWorkout = workouts.first(where: { $0.id == workoutId }) {
                        self.workout = updatedWorkout
                    } else {
                        print("⚠️ Workout with ID \(workoutId) not found in fetch.")
                    }
                case .failure(let error):
                    print("❌ Failed to refresh workout metadata: \(error.localizedDescription)")
                }
            }
        }

        // Refresh exercises
        ExerciseService.shared.fetchExercisesForWorkout(userId: currentUserId, workoutId: workoutId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedExercises):
                    self.exercises = fetchedExercises
                    print("✅ Refreshed exercises successfully")
                case .failure(let error):
                    print("❌ Failed to refresh exercises: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveAsTemplate(title: String) {
        guard !title.isEmpty else {
            print("❌ Template title cannot be empty")
            return
        }
        let newTemplate = Template(title: title, userId: currentUserId)

        TemplateService.shared.saveTemplate(template: newTemplate) { result in
            switch result {
            case .success(let templateId):
                print("✅ Template created with ID: \(templateId)")
                self.saveExercises(for: templateId) {
                    print("✅ All exercises saved for template")
                }
            case .failure(let error):
                print("❌ Failed to save template: \(error.localizedDescription)")
            }
        }
    }

    private func saveExercises(for templateId: String, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        for (index, exercise) in exercises.enumerated() {
            dispatchGroup.enter()

            let exerciseToSave = Exercise(
                templateId: templateId,
                userId: currentUserId,
                name: exercise.name,
                sets: exercise.sets,
                order: index
            )

            ExerciseService.shared.saveExercise(exercise: exerciseToSave) { result in
                switch result {
                case .success(let id):
                    print("✅ Template exercise saved with ID: \(id)")
                case .failure(let error):
                    print("❌ Failed to save template exercise: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.showSaveConfirmation = true
            completion()
        }
    }
}
