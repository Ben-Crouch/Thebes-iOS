//  TemplateLogViewModel.swift
//  Thebes
//
//  Created by Ben on 20/03/2025.
//

import SwiftUI

class TemplateLogViewModel: ObservableObject, ExerciseHandlingProtocol {
    @Published var showToast: Bool = false
    @Published var templateTitle: String = ""
    @Published var exercises: [Exercise] = []
    @Published var showSaveConfirmation = false
    private let userId: String

    init(userId: String) {
        self.userId = userId
        // Start with one default empty exercise
        self.exercises = [Exercise(
            workoutId: nil,
            templateId: nil,
            userId: self.userId,
            name: "",
            sets: [SetData(reps: 0, weight: 0.0, restTime: nil)]
        )]
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

    // MARK: - Add Set
    func addSet(to exerciseIndex: Int) {
        guard exerciseIndex < exercises.count else { return }

        let lastSet = exercises[exerciseIndex].sets.last
        let newReps = lastSet?.reps ?? 0
        let newWeightValue = lastSet?.weight
        let newRestTime = lastSet?.restTime

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

        let isCurrentlyBodyweight = exercises[exerciseIndex].sets.allSatisfy { $0.weight == nil }

        for index in exercises[exerciseIndex].sets.indices {
            exercises[exerciseIndex].sets[index].weight = isCurrentlyBodyweight ? 0.0 : nil
        }
    }

    // MARK: - Save Template
    func saveTemplate() {
        guard !templateTitle.isEmpty, !exercises.isEmpty else {
            print("❌ Template title or exercises cannot be empty")
            return
        }

        let newTemplate = Template(title: templateTitle, userId: userId)

        TemplateService.shared.saveTemplate(template: newTemplate) { result in
            switch result {
            case .success(let templateId):
                print("✅ Template saved with ID: \(templateId)")
                self.saveExercises(for: templateId) {
                    self.resetFields()
                    DispatchQueue.main.async {
                        self.showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showToast = false
                    }
                }
            case .failure(let error):
                print("❌ Error saving template: \(error.localizedDescription)")
            }
        }
    }

    private func saveExercises(for templateId: String, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        for exercise in exercises {
            dispatchGroup.enter()

            let exerciseToSave = Exercise(
                workoutId: nil,
                templateId: templateId,
                userId: self.userId,
                name: exercise.name,
                sets: exercise.sets
            )

            ExerciseService.shared.saveExercise(exercise: exerciseToSave) { result in
                switch result {
                case .success:
                    print("✅ Exercise saved for template")
                case .failure(let error):
                    print("❌ Error saving exercise for template: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("✅ All exercises saved for template")
            completion()
        }
    }

    private func resetFields() {
        templateTitle = ""
        exercises.removeAll()
        showSaveConfirmation = true
    }
}
