//
//  TrackerView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI
import Charts

struct TrackerView: View {
    @ObservedObject var viewModel: TrackerViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Custom Back Button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.secondary)
                    Text("Back")
                        .foregroundColor(AppColors.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Text("\(viewModel.displayName)")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal)

            Text("Preferred Unit: \(viewModel.preferredWeightUnit)")
                .foregroundColor(.gray)
                .padding(.horizontal)

            HStack {
                Text("Exercise:")
                    .foregroundColor(.white)

                Picker(selection: $viewModel.selectedExercise, label: Text(viewModel.selectedExercise ?? "Select Exercise")
                    .foregroundColor(AppColors.secondary)) {
                    ForEach(viewModel.allExerciseNames, id: \.self) { exercise in
                        Text(exercise)
                            .foregroundColor(AppColors.secondary)
                            .tag(Optional(exercise))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(AppColors.secondary)
                .frame(maxWidth: .infinity)

                Text("Range:")
                    .foregroundColor(.white)

                Picker(selection: $viewModel.selectedTimeRange, label: Text(viewModel.selectedTimeRange)
                    .foregroundColor(AppColors.secondary)) {
                    ForEach(viewModel.timeRanges, id: \.self) { range in
                        Text(range)
                            .foregroundColor(AppColors.secondary)
                            .tag(range)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(AppColors.secondary)
                .frame(maxWidth: .infinity)
                .onChange(of: viewModel.selectedTimeRange) { newRange in
                    viewModel.updateSelectedTimeRange(newRange)
                }
            }
            .padding(.horizontal)

            Chart(viewModel.trackedExercises) { exercise in
                if let date = exercise.date,
                   let maxWeight = exercise.sets.map({ $0.weight ?? 0 }).max() {
                    LineMark(
                        x: .value("Date", date),
                        y: .value("Weight", maxWeight)
                    )
                    .foregroundStyle(AppColors.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let doubleValue = value.as(Double.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel("\(Int(doubleValue)) \(viewModel.preferredWeightUnit)")
                    }
                }
            }
            .frame(height: 240)
            .padding(.horizontal)

            // Stat Summary Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Stats Summary")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.isBodyweightExercise ? "Best Reps" : "Best EORM")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(viewModel.isBodyweightExercise
                             ? "\(viewModel.bestReps)"
                             : String(format: "%.1f", viewModel.bestEORM))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Change")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(viewModel.isBodyweightExercise
                             ? "\(viewModel.repsChange)"
                             : String(format: "%.1f", viewModel.eormChange))
                        .foregroundColor(
                            viewModel.isBodyweightExercise
                            ? (viewModel.repsChange >= 0 ? .green : .red)
                            : (viewModel.eormChange >= 0 ? .green : .red)
                        )
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Total Sets")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(viewModel.totalSets)")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppColors.primary)
        .onChange(of: viewModel.selectedExercise) { newValue in
            if let newExercise = newValue {
                viewModel.updateSelectedExercise(newExercise)
            }
        }
    }
}
