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

            Button(action: { viewModel.toggleBodyweight(for: exerciseIndex) }) {
                Image(systemName: exercise.sets.allSatisfy { $0.weight == nil } ? "person.fill" : "dumbbell.fill")
                    .foregroundColor(AppColors.secondary)
            }

            Button(action: { viewModel.removeExercise(at: exerciseIndex) }) {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.secondary)
            }
        }
    }

    private var columnHeaders: some View {
        HStack {
            Text("Reps")
                .frame(width: 60)
                .foregroundColor(AppColors.secondary)

            if exercise.sets.contains(where: { $0.weight != nil }) {
                Text("Weight (\(AppSettings.shared.preferredUnit))")
                    .frame(width: 90)
                    .foregroundColor(AppColors.secondary)
            }

            if exercise.sets.contains(where: { $0.restTime != nil }) {
                Text("Rest (s)")
                    .frame(width: 70)
                    .foregroundColor(AppColors.secondary)
            }

            Button(action: {
                let hasRest = exercise.sets.contains { $0.restTime != nil }
                viewModel.showRestTime(for: exerciseIndex, isEnabled: !hasRest)
            }) {
                Text(exercise.sets.contains { $0.restTime != nil } ? "− Rest" : "+ Rest")
                    .font(.caption)
                    .padding(6)
                    .background(AppColors.primary)
                    .cornerRadius(5)
                    .foregroundColor(AppColors.secondary)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(AppColors.secondary, lineWidth: 1))
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
                                let w = exercise.sets[index].weight ?? 0.0
                                return AppSettings.shared.preferredUnit == "lbs" ? String(format: "%.1f", w * 2.20462) : String(format: "%.1f", w)
                            },
                            set: { newValue in
                                if let val = Double(newValue) {
                                    exercise.sets[index].weight = AppSettings.shared.preferredUnit == "lbs" ? val / 2.20462 : val
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
            Text("+ Add Set")
                .foregroundColor(AppColors.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.secondary, lineWidth: 1.5))
        }
        .background(AppColors.primary)
        .cornerRadius(8)
        .padding(.top, 5)
    }
}
