//
//  EditTemplateViewModel.swift
//  Thebes
//
//  Created by Ben on 20/03/2025.
//

import Foundation
import SwiftUI

class EditTemplateViewModel: ObservableObject, ExerciseHandlingProtocol {
    @Published var showToast: Bool = false
    @Published var template: Template
    @Published var originalExercises: [Exercise] = []
    @Published var exercises: [Exercise] = []
    @Published var isLoading: Bool = false

    private let userId: String

    init(template: Template, userId: String) {
        self.template = template
        self.userId = userId
        
        if let templateId = template.id {
            fetchExercises(for: templateId)
        }
    }

    // MARK: - Fetch exercises for this template
    private func fetchExercises(for templateId: String) {
        isLoading = true
        ExerciseService.shared.fetchExercisesForTemplate(userId: userId, templateId: templateId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedExercises):
                    self.exercises = fetchedExercises
                    self.originalExercises = fetchedExercises // Store original state for diff
                case .failure(let error):
                    print("❌ Error fetching template exercises: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }

    // MARK: - Add / Remove exercise
    func addExercise() {
        exercises.append(Exercise(
            templateId: template.id,
            userId: self.userId,
            name: "",
            sets: [SetData(reps: 0, weight: 0.0)]
        ))
    }

    func removeExercise(at index: Int) {
        exercises.remove(at: index)
    }

    // MARK: - Add / Remove sets
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

    // MARK: - Save template updates (handle added/edited/deleted exercises)
    func saveEdits(completion: @escaping () -> Void) {
        guard !template.title.isEmpty, !exercises.isEmpty else {
            print("❌ Template title or exercises cannot be empty")
            return
        }

        TemplateService.shared.updateTemplate(template: template) { templateResult in
            switch templateResult {
            case .success():
                let dispatchGroup = DispatchGroup()

                // Save or update exercises
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
                print("❌ Failed to update template: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Delete template
    func deleteTemplate(completion: @escaping () -> Void) {
        guard let templateId = template.id else { return }
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ExerciseService.shared.deleteExercisesForTemplate(templateId: templateId) { _ in
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        TemplateService.shared.deleteTemplate(templateId: templateId) { _ in
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}
