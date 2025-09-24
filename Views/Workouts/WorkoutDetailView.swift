//
//  WorkoutDetailView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: WorkoutDetailViewModel

    @Environment(\.dismiss) private var dismiss
    var onUpdate: (() -> Void)? = nil

    @State private var showTemplateSheet = false
    @State private var templateTitle = ""
    @State private var showEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                    .background(AppColors.secondary.opacity(0.3))
                    .frame(height: 1)
                    .padding(.top, -5)

                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.workout.title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    Text("Date: \(viewModel.formattedDate() ?? "No Date")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .cornerRadius(10)

                if let notes = viewModel.workout.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(AppColors.secondary)

                        Text(notes)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                            .background(AppColors.primary.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 5)
                }

                Text("Exercises")
                    .font(.headline)
                    .foregroundColor(AppColors.secondary)

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

                Button(action: {
                    showTemplateSheet = true
                }) {
                    Text("Save as Template")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).fill(AppColors.primary))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.secondary, lineWidth: 2))
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Workout Details")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isCurrentUserOwner {
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showEdit, onDismiss: {
            viewModel.refreshWorkoutDetails()
        }) {
            NavigationView {
                EditWorkoutView(viewModel: EditWorkoutViewModel(workout: viewModel.workout, userId: authViewModel.user?.uid ?? ""))
                    .environmentObject(authViewModel)
            }
        }
        .sheet(isPresented: $showTemplateSheet) {
            VStack(spacing: 20) {
                Text("Template Title")
                    .font(.headline)
                    .foregroundColor(.white)

                TextField("Enter a title...", text: $templateTitle)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)

                Button("Save") {
                    viewModel.saveAsTemplate(title: templateTitle)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showTemplateSheet = false
                        templateTitle = ""
                    }
                }
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .padding()

                Button("Cancel") {
                    showTemplateSheet = false
                    templateTitle = ""
                }
                .foregroundColor(.red)
            }
            .padding()
            .background(AppColors.primary.edgesIgnoringSafeArea(.all))
        }
        .onChange(of: viewModel.showSaveConfirmation) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.showSaveConfirmation = false
                }
            }
        }
        .overlay(
            ToastView(message: "Template saved successfully!", isShowing: $viewModel.showSaveConfirmation)
        )
    }

    private func exerciseSummaryView(for exercise: Exercise) -> some View {
        let hasWeightedSets = exercise.sets.contains { $0.weight != nil }
        let weightUnit = AppSettings.shared.preferredUnit

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
                    Image(systemName: viewModel.expandedExercises.contains(exercise.id ?? "") ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.secondary)
                        .padding(8)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }

            if viewModel.expandedExercises.contains(exercise.id ?? "") {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Reps")
                            .font(.footnote)
                            .foregroundColor(AppColors.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if hasWeightedSets {
                            Text("Weight (\(weightUnit))")
                                .font(.footnote)
                                .foregroundColor(AppColors.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if exercise.sets.contains(where: { $0.restTime != nil }) {
                            Text("Rest(s)")
                                .font(.footnote)
                                .foregroundColor(AppColors.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        if hasWeightedSets {
                            Text("1RM (\(weightUnit))")
                                .font(.footnote)
                                .foregroundColor(AppColors.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.bottom, 5)
                    .padding(.horizontal, 8)

                    LazyVStack(spacing: 5) {
                        ForEach(exercise.sets.indices, id: \.self) { index in
                            let set = exercise.sets[index]
                            setDetailRow(for: set, index: index, in: exercise)
                        }
                    }
                    .padding(8)
                    .background(AppColors.primary.opacity(0.5))
                    .cornerRadius(8)
                    .transition(.opacity)
                }
            }
        }
        .padding()
        .background(AppColors.primary.opacity(0.8))
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.2), value: viewModel.expandedExercises)
    }

    private func setDetailRow(for set: SetData, index: Int, in exercise: Exercise) -> some View {
        let isWeighted = set.weight != nil
        let oneRepMax: Double? = isWeighted ? (set.weight! * (1 + Double(set.reps) / 30)) : nil
        return HStack {
            Text("\(set.reps)")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(set.weight.map { String(format: "%.2f", $0) } ?? "Bodyweight")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            if exercise.sets.contains(where: { $0.restTime != nil }) {
                Text(set.restTime.map { "\($0)" } ?? "")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if let oneRepMax = oneRepMax {
                Text(String(format: "%.2f", oneRepMax))
                    .foregroundColor(AppColors.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(6)
        .background(index % 2 == 0 ? Color.white.opacity(0.05) : Color.white.opacity(0.0025))
        .cornerRadius(5)
    }
}
