//
//  TemplateDetailViewModel.swift
//  Thebes
//
//  Created by Ben on 20/03/2025.
//

import Foundation

class TemplateDetailViewModel: ObservableObject {
    @Published var expandedExercises: Set<String> = []
    @Published var template: Template?
    @Published var exercises: [Exercise] = []
    @Published var templateID: String? = ""
    @Published var templateTitle: String? = ""
    @Published var templateUserId: String? = ""

    private let currentUserId: String

    var isCurrentUserOwner: Bool {
        return currentUserId == template?.userId
    }

    init(currentUserId: String, template: Template) {
        self.currentUserId = currentUserId
        self.template = template
        self.templateTitle = template.title
        self.templateID = template.id
        self.templateUserId = template.userId
        self.exercises = []
        fetchExercises(for: template.id)
    }

    private func fetchExercises(for templateId: String?) {
        guard let templateId = templateId else { return }
        ExerciseService.shared.fetchExercisesForTemplate(userId: template?.userId ?? "", templateId: templateId) { result in
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

    func refreshTemplateDetails() {
        guard let templateId = template?.id else {
            print("❌ Template ID missing — cannot refresh.")
            return
        }

        // Refresh template metadata
        TemplateService.shared.fetchTemplates(for: currentUserId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let templates):
                    if let updatedTemplate = templates.first(where: { $0.id == templateId }) {
                        self.template = updatedTemplate
                        self.templateTitle = updatedTemplate.title
                    } else {
                        print("⚠️ Template with ID \(templateId) not found in fetch.")
                    }
                case .failure(let error):
                    print("❌ Failed to refresh template metadata: \(error.localizedDescription)")
                }
            }
        }

        // Refresh exercises
        ExerciseService.shared.fetchExercisesForTemplate(userId: currentUserId, templateId: templateId) { result in
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
}
