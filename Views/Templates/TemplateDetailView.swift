//
//  TemplateDetailView.swift
//  Thebes
//
//  Created by Ben on 12/03/2025.
//

import SwiftUI

struct TemplateDetailView: View {
    @StateObject private var viewModel: TemplateDetailViewModel // ✅ Uses ViewModel for Templates
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    init(template: Template, currentUserId: String) {
        _viewModel = StateObject(wrappedValue: TemplateDetailViewModel(currentUserId: currentUserId, template: template))
    }

    // ✅ Computed property to safely retrieve the template title
    private var templateTitle: String {
        viewModel.templateTitle ?? ""
    }

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                        .background(AppColors.secondary.opacity(0.3))
                        .frame(height: 1)
                        .padding(.top, -5)

                    // ✅ Display Template Title
                    Text(templateTitle)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    Text("Exercises")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)

                    // ✅ Use `viewModel.exercises` instead of `viewModel.template.exercises`
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.exercises.indices, id: \.self) { index in
                            exerciseSummaryView(for: viewModel.exercises[index])

                            if index < viewModel.exercises.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(AppColors.primary.edgesIgnoringSafeArea(.all))
            .toolbarBackground(AppColors.primary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.secondary)
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Template Details")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let template = viewModel.template {
                        NavigationLink(
                            destination: TemplateEditView(
                                template: template,
                                userId: authViewModel.user?.uid ?? "",
                                onDelete: {
                                    dismiss() // Dismiss TemplateDetailView if template is deleted
                                }
                            )
                            .environmentObject(authViewModel)
                            .onDisappear {
                                viewModel.refreshTemplateDetails()
                            }
                        ) {
                            Image(systemName: "pencil")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)
                        }
                    }
                }
            }
        }

    // ✅ Exercise Summary View
    private func exerciseSummaryView(for exercise: Exercise) -> some View {
        let hasWeightedSets = exercise.sets.contains { $0.weight != nil }
        let weightUnit = AppSettings.shared.preferredUnit
        let isExpanded = viewModel.expandedExercises.contains(exercise.id ?? "")

        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("\(exercise.name)")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(exercise.sets.count) Sets")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                Button(action: {
                    viewModel.toggleExerciseExpansion(exercise.id ?? "")
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.secondary)
                        .padding(8)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }

            if isExpanded {
                expandedExerciseDetail(for: exercise, hasWeightedSets: hasWeightedSets, weightUnit: weightUnit)
            }
        }
        .padding()
        .background(AppColors.primary.opacity(0.8))
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.2), value: viewModel.expandedExercises)
    }
    
    private func expandedExerciseDetail(for exercise: Exercise, hasWeightedSets: Bool, weightUnit: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Reps")
                    .font(.footnote)
                    .foregroundColor(AppColors.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if hasWeightedSets {
                    Text("Weight(\(weightUnit))")
                        .font(.footnote)
                        .foregroundColor(AppColors.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Text("Rest(s)")
                    .font(.footnote)
                    .foregroundColor(AppColors.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 5)
            .padding(.horizontal, 8)

            LazyVStack(spacing: 5) {
                ForEach(exercise.sets.indices, id: \.self) { index in
                    let set = exercise.sets[index]
                    setDetailRow(for: set, index: index)
                }
            }
            .padding(8)
            .background(AppColors.primary.opacity(0.5))
            .cornerRadius(8)
            .transition(.opacity)
        }
    }

    // ✅ Set Detail View
    private func setDetailRow(for set: SetData, index: Int) -> some View {
        HStack {
            Text("\(set.reps)")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(set.weight.map { String(format: "%.2f", $0) } ?? "Bodyweight")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(set.restTime.map { "\($0)" } ?? "--")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(6)
        .background(index % 2 == 0 ? Color.white.opacity(0.05) : Color.white.opacity(0.0025))
        .cornerRadius(5)
    }
}
