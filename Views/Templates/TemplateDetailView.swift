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
    @State private var showEdit = false

    init(template: Template, currentUserId: String) {
        _viewModel = StateObject(wrappedValue: TemplateDetailViewModel(currentUserId: currentUserId, template: template))
    }

    // ✅ Computed property to safely retrieve the template title
    private var templateTitle: String {
        viewModel.templateTitle ?? ""
    }

    var body: some View {
        ZStack {
            // Gradient background to match WorkoutDetailView
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.8),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 24) {
                    // Header card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)

                            Text("Template Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text(templateTitle.isEmpty ? "Untitled Template" : templateTitle)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Image(systemName: "square.stack.3d.up")
                                    .foregroundColor(AppColors.secondary)
                                    .font(.subheadline)

                                Text("\(viewModel.exercises.count) Exercises")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // Exercises section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)

                            Text("Exercises")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                                )
                        )

                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.exercises.indices, id: \.self) { index in
                                exerciseSummaryView(for: viewModel.exercises[index])
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .toolbarBackground(AppColors.primary, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // Match WorkoutDetailView default back behavior
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Template Details")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.template != nil {
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(AppColors.secondary)
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showEdit, onDismiss: {
            viewModel.refreshTemplateDetails()
        }) {
            NavigationView {
                if let template = viewModel.template {
                    TemplateEditView(
                        template: template,
                        userId: authViewModel.user?.uid ?? "",
                        onDelete: {
                            dismiss()
                        }
                    )
                    .environmentObject(authViewModel)
                }
            }
        }
    }

    // ✅ Exercise Summary View
    private func exerciseSummaryView(for exercise: Exercise) -> some View {
        let hasWeightedSets = exercise.sets.contains { $0.weight != nil }
        let weightUnit = AppSettings.shared.preferredUnit
        let isExpanded = viewModel.expandedExercises.contains(exercise.id ?? "")

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("\(exercise.sets.count) Sets")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: {
                    viewModel.toggleExerciseExpansion(exercise.id ?? "")
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.secondary)
                        .font(.title3)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }

            if isExpanded {
                expandedExerciseDetail(for: exercise, hasWeightedSets: hasWeightedSets, weightUnit: weightUnit)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: viewModel.expandedExercises)
    }
    
    private func expandedExerciseDetail(for exercise: Exercise, hasWeightedSets: Bool, weightUnit: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reps")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if hasWeightedSets {
                    Text("Weight (\(weightUnit))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if exercise.sets.contains(where: { $0.restTime != nil }) {
                    Text("Rest(s)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if hasWeightedSets {
                    Text("1RM (\(weightUnit))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal, 4)

            LazyVStack(spacing: 8) {
                ForEach(exercise.sets.indices, id: \.self) { index in
                    let set = exercise.sets[index]
                    setDetailRow(for: set, index: index, in: exercise)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    // ✅ Set Detail View
    private func setDetailRow(for set: SetData, index: Int, in exercise: Exercise) -> some View {
        let isWeighted = set.weight != nil
        let oneRepMax: Double? = isWeighted ? (set.weight! * (1 + Double(set.reps) / 30)) : nil

        return HStack {
            Text("\(set.reps)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(set.weight.map { String(format: "%.1f", $0) } ?? "Bodyweight")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            if exercise.sets.contains(where: { $0.restTime != nil }) {
                Text(set.restTime.map { "\($0)" } ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            if let oneRepMax = oneRepMax {
                Text(String(format: "%.1f", oneRepMax))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(index % 2 == 0 ? Color.white.opacity(0.05) : Color.white.opacity(0.02))
        )
    }
}
