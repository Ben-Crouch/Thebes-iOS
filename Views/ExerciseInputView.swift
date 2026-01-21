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
    @FocusState private var focusedField: FieldKey?
    @State private var fieldTexts: [FieldKey: String] = [:]
    @State private var previousReps: [FieldKey: Int] = [:]
    @State private var previousWeights: [FieldKey: Double] = [:]
    @State private var previousRests: [FieldKey: Int] = [:]
    @State private var lastFocusedField: FieldKey?

    private enum FieldKind {
        case reps
        case weight
        case rest
    }

    private struct FieldKey: Hashable {
        let exerciseIndex: Int
        let setIndex: Int
        let kind: FieldKind
    }

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
        .onChange(of: focusedField) { newValue in
            handleFocusChange(to: newValue)
        }
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
                let repsKey = fieldKey(kind: .reps, setIndex: index)
                let weightKey = fieldKey(kind: .weight, setIndex: index)
                let restKey = fieldKey(kind: .rest, setIndex: index)
                HStack {
                    TextField("", text: repsBinding(for: index))
                    .keyboardType(.numberPad)
                    .padding(6)
                    .background(AppColors.complementary.opacity(0.2))
                    .cornerRadius(6)
                    .frame(width: 60)
                    .foregroundColor(.white)
                    .focused($focusedField, equals: repsKey)
                    .overlay(alignment: .leading) {
                        placeholderView(for: repsKey)
                    }
                    .onChange(of: exercise.sets[index].reps) { _ in
                        syncFieldText(for: repsKey)
                    }

                    if exercise.sets[index].weight != nil {
                        TextField("", text: weightBinding(for: index))
                        .keyboardType(.decimalPad)
                        .padding(6)
                        .background(AppColors.complementary.opacity(0.2))
                        .cornerRadius(6)
                        .frame(width: 80)
                        .foregroundColor(.white)
                        .focused($focusedField, equals: weightKey)
                        .overlay(alignment: .leading) {
                            placeholderView(for: weightKey)
                        }
                        .onChange(of: exercise.sets[index].weight) { _ in
                            syncFieldText(for: weightKey)
                        }
                    }

                    if let _ = exercise.sets[index].restTime {
                        TextField("", text: restBinding(for: index))
                        .keyboardType(.numberPad)
                        .padding(6)
                        .background(AppColors.complementary.opacity(0.2))
                        .cornerRadius(6)
                        .frame(width: 60)
                        .foregroundColor(.white)
                        .focused($focusedField, equals: restKey)
                        .overlay(alignment: .leading) {
                            placeholderView(for: restKey)
                        }
                        .onChange(of: exercise.sets[index].restTime) { _ in
                            syncFieldText(for: restKey)
                        }
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

    private func fieldKey(kind: FieldKind, setIndex: Int) -> FieldKey {
        FieldKey(exerciseIndex: exerciseIndex, setIndex: setIndex, kind: kind)
    }

    private func handleFocusChange(to newField: FieldKey?) {
        if lastFocusedField != newField {
            if let lastField = lastFocusedField {
                handleBlur(for: lastField)
            }
            if let newField {
                handleFocus(for: newField)
            }
            lastFocusedField = newField
        }
    }

    private func handleFocus(for key: FieldKey) {
        switch key.kind {
        case .reps:
            previousReps[key] = exercise.sets[key.setIndex].reps
        case .weight:
            if let weight = exercise.sets[key.setIndex].weight {
                previousWeights[key] = weight
            }
        case .rest:
            if let restTime = exercise.sets[key.setIndex].restTime {
                previousRests[key] = restTime
            }
        }
        fieldTexts[key] = ""
    }

    private func handleBlur(for key: FieldKey) {
        let text = (fieldTexts[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        switch key.kind {
        case .reps:
            if text.isEmpty || Int(text) == nil {
                restoreReps(for: key)
            } else if let value = Int(text) {
                exercise.sets[key.setIndex].reps = value
            }
            previousReps.removeValue(forKey: key)
        case .weight:
            if text.isEmpty || Double(text) == nil {
                restoreWeight(for: key)
            } else if let value = Double(text) {
                exercise.sets[key.setIndex].weight = appSettings.preferredWeightUnit.convertToKilograms(value)
            }
            previousWeights.removeValue(forKey: key)
        case .rest:
            if text.isEmpty || Int(text) == nil {
                restoreRest(for: key)
            } else if let value = Int(text) {
                exercise.sets[key.setIndex].restTime = value
            }
            previousRests.removeValue(forKey: key)
        }
        syncFieldText(for: key)
    }

    private func restoreReps(for key: FieldKey) {
        if let previous = previousReps[key] {
            exercise.sets[key.setIndex].reps = previous
        }
    }

    private func restoreWeight(for key: FieldKey) {
        if let previous = previousWeights[key] {
            exercise.sets[key.setIndex].weight = previous
        }
    }

    private func restoreRest(for key: FieldKey) {
        if let previous = previousRests[key] {
            exercise.sets[key.setIndex].restTime = previous
        }
    }

    private func repsBinding(for setIndex: Int) -> Binding<String> {
        let key = fieldKey(kind: .reps, setIndex: setIndex)
        return Binding(
            get: {
                fieldTexts[key] ?? displayText(for: key)
            },
            set: { newValue in
                fieldTexts[key] = newValue
                if let value = Int(newValue) {
                    exercise.sets[setIndex].reps = value
                }
            }
        )
    }

    private func weightBinding(for setIndex: Int) -> Binding<String> {
        let key = fieldKey(kind: .weight, setIndex: setIndex)
        return Binding(
            get: {
                fieldTexts[key] ?? displayText(for: key)
            },
            set: { newValue in
                fieldTexts[key] = newValue
                if let value = Double(newValue) {
                    exercise.sets[setIndex].weight = appSettings.preferredWeightUnit.convertToKilograms(value)
                }
            }
        )
    }

    private func restBinding(for setIndex: Int) -> Binding<String> {
        let key = fieldKey(kind: .rest, setIndex: setIndex)
        return Binding(
            get: {
                fieldTexts[key] ?? displayText(for: key)
            },
            set: { newValue in
                fieldTexts[key] = newValue
                if let value = Int(newValue) {
                    exercise.sets[setIndex].restTime = value
                }
            }
        )
    }

    private func displayText(for key: FieldKey) -> String {
        switch key.kind {
        case .reps:
            return String(exercise.sets[key.setIndex].reps)
        case .weight:
            guard let weightKG = exercise.sets[key.setIndex].weight else { return "" }
            let displayValue = appSettings.preferredWeightUnit.convertFromKilograms(weightKG)
            return String(format: "%.1f", displayValue)
        case .rest:
            return exercise.sets[key.setIndex].restTime.map(String.init) ?? ""
        }
    }

    private func syncFieldText(for key: FieldKey) {
        if focusedField != key {
            fieldTexts[key] = displayText(for: key)
        }
    }

    private func placeholderView(for key: FieldKey) -> some View {
        let text = fieldTexts[key] ?? displayText(for: key)
        return Group {
            if text.isEmpty {
                Text(placeholderText(for: key))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.leading, 6)
            }
        }
    }

    private func placeholderText(for key: FieldKey) -> String {
        switch key.kind {
        case .weight:
            return appSettings.preferredWeightUnit.symbol
        case .reps, .rest:
            return "-"
        }
    }
}
