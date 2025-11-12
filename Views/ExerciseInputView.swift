//
//  ExerciseInputView.swift
//  Thebes
//
//  Created by Ben on 20/02/2025.
//
import SwiftUI

struct ExerciseInputView<T: ExerciseHandlingProtocol>: View {
    @ObservedObject var viewModel: T
    @Binding var exercise: Exercise
    var exerciseIndex: Int
    var addSet: () -> Void
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            columnHeaders
            setsList
            addSetButton
        }
        .padding()
        .background(AppColors.primary.opacity(0.6))
        .cornerRadius(10)
    }

    private var headerRow: some View {
        HStack {
            TextField("", text: $exercise.name)
                .modifier(PlaceholderModifier(
                    showPlaceholder: exercise.name.isEmpty,
                    placeholder: "Exercise Name",
                    color: .white.opacity(0.8)
                ))
                .padding(8)
                .background(AppColors.complementary.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.white)

            Spacer()

            Button(action: { viewModel.removeExercise(at: exerciseIndex) }) {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.secondary)
                    .font(.title3)
            }
        }
    }

    private var columnHeaders: some View {
        HStack {
            Text("Reps")
                .frame(width: 60)
                .foregroundColor(AppColors.secondary)

            if exercise.sets.contains(where: { $0.weight != nil }) {
                Text("Weight (\(appSettings.preferredWeightUnit.symbol))")
                    .frame(width: 90)
                    .foregroundColor(AppColors.secondary)
            }

            if exercise.sets.contains(where: { $0.restTime != nil }) {
                Text("Rest (s)")
                    .frame(width: 70)
                    .foregroundColor(AppColors.secondary)
            }

            Spacer()

            // Bodyweight/Weight toggle button
            Button(action: { viewModel.toggleBodyweight(for: exerciseIndex) }) {
                Image(systemName: exercise.sets.allSatisfy { $0.weight == nil } ? "dumbbell.fill" : "person.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title3)
            }

            // Rest toggle button
            Button(action: {
                let hasRest = exercise.sets.contains { $0.restTime != nil }
                viewModel.showRestTime(for: exerciseIndex, isEnabled: !hasRest)
            }) {
                Image(systemName: exercise.sets.contains { $0.restTime != nil } ? "clock.fill" : "clock")
                    .foregroundColor(AppColors.secondary)
                    .font(.title3)
            }
        }
    }

    private var setsList: some View {
        VStack(spacing: 6) {
            ForEach(exercise.sets.indices, id: \.self) { index in
                HStack {
                    TextField("", text: Binding(
                        get: { String(exercise.sets[index].reps) },
                        set: { exercise.sets[index].reps = Int($0) ?? 0 }
                    ))
                    .keyboardType(.numberPad)
                    .padding(6)
                    .background(AppColors.complementary.opacity(0.2))
                    .cornerRadius(6)
                    .frame(width: 60)
                    .foregroundColor(.white)

                    if exercise.sets[index].weight != nil {
                        TextField("", text: Binding(
                            get: {
                                let weightKG = exercise.sets[index].weight ?? 0.0
                                let displayValue = appSettings.preferredWeightUnit.convertFromKilograms(weightKG)
                                return String(format: "%.1f", displayValue)
                            },
                            set: { newValue in
                                if let val = Double(newValue) {
                                    exercise.sets[index].weight = appSettings.preferredWeightUnit.convertToKilograms(val)
                                } else {
                                    exercise.sets[index].weight = nil
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        .padding(6)
                        .background(AppColors.complementary.opacity(0.2))
                        .cornerRadius(6)
                        .frame(width: 80)
                        .foregroundColor(.white)
                    }

                    if let _ = exercise.sets[index].restTime {
                        TextField("", text: Binding(
                            get: { exercise.sets[index].restTime.map(String.init) ?? "" },
                            set: { exercise.sets[index].restTime = Int($0) }
                        ))
                        .keyboardType(.numberPad)
                        .padding(6)
                        .background(AppColors.complementary.opacity(0.2))
                        .cornerRadius(6)
                        .frame(width: 60)
                        .foregroundColor(.white)
                    }

                    Button(action: { viewModel.removeSet(from: exerciseIndex, at: index) }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(AppColors.secondary)
                    }
                }
            }
        }
    }

    private var addSetButton: some View {
        Button(action: addSet) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline)
                Text("Add Set")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(AppColors.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.secondary.opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
        .padding(.top, 8)
    }
}
