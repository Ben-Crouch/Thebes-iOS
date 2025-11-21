//
import SwiftUI
//  WorkoutDetailView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: WorkoutDetailViewModel

    @Environment(\.dismiss) private var dismiss
    var onUpdate: (() -> Void)? = nil

    @State private var showTemplateSheet = false
    @State private var templateTitle = ""
    @State private var showEdit = false
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        ZStack {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 24) {
                    // Workout header card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)
                            
                            Text("Workout Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(viewModel.workout.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(AppColors.secondary)
                                    .font(.subheadline)
                                
                                Text(viewModel.formattedDate() ?? "No Date")
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

                    // Notes card (if notes exist)
                    if let notes = viewModel.workout.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(notes)
                                .foregroundColor(.gray)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }

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

                    // Save as Template button (only for owners)
                    if viewModel.isCurrentUserOwner {
                        Button(action: {
                            showTemplateSheet = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundColor(AppColors.secondary)
                                    .font(.title3)
                                
                                Text("Save as Template")
                                    .font(.headline)
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
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
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
        let weightUnit = appSettings.preferredWeightUnit

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
                    Image(systemName: viewModel.expandedExercises.contains(exercise.id ?? "") ? "chevron.up" : "chevron.down")
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

            if viewModel.expandedExercises.contains(exercise.id ?? "") {
                VStack(alignment: .leading, spacing: 12) {
                    // Column headers
                    HStack {
                        Text("Reps")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if hasWeightedSets {
                            Text("Weight (\(weightUnit.symbol))")
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
                            Text("1RM (\(weightUnit.symbol))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 4)

                    // Sets list
                    LazyVStack(spacing: 8) {
                        ForEach(exercise.sets.indices, id: \.self) { index in
                            let set = exercise.sets[index]
                            setDetailRow(for: set, index: index, in: exercise)
                        }
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

    private func expandedExerciseDetail(for exercise: Exercise, hasWeightedSets: Bool, weightUnit: WeightUnit) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            // Column headers
            HStack {
                Text("Reps")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if hasWeightedSets {
                    Text("Weight (\(weightUnit.symbol))")
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
                    Text("1RM (\(weightUnit.symbol))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal, 4)

            // Sets list
            LazyVStack(spacing: 8) {
                ForEach(exercise.sets.indices, id: \.self) { index in
                    let set = exercise.sets[index]
                    setDetailRow(for: set, index: index, in: exercise)
                }
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

    private func setDetailRow(for set: SetData, index: Int, in exercise: Exercise) -> some View {
        let isWeighted = set.weight != nil
        let oneRepMaxKG: Double? = isWeighted ? (set.weight! * (1 + Double(set.reps) / 30)) : nil
        let unit = appSettings.preferredWeightUnit
        
        return HStack {
            Text("\(set.reps)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(set.weight.map { unit.formattedWeight(fromKilograms: $0) } ?? "Bodyweight")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            if exercise.sets.contains(where: { $0.restTime != nil }) {
                Text(set.restTime.map { "\($0)" } ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            if let oneRepMax = oneRepMaxKG {
                Text(String(format: "%.1f", unit.convertFromKilograms(oneRepMax)))
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
