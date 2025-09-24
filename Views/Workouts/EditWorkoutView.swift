//
//  EditWorkoutView.swift
//  Thebes
//
//  Created by Ben on 10/03/2025.
//

import SwiftUI

struct EditWorkoutView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject  var viewModel: EditWorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if viewModel.isLoading {
                ProgressView("Loading Exercises...")
                    .foregroundColor(.white)
                    .scaleEffect(1.5)
            } else {
                VStack {
                    // Progress dots
                    HStack {
                        Circle().fill(selectedTab == 0 ? AppColors.secondary : .gray).frame(width: 10, height: 10)
                        Circle().fill(selectedTab == 1 ? AppColors.secondary : .gray).frame(width: 10, height: 10)
                    }
                    .padding(.top, 10)

                    // Conditionally show views
                    if selectedTab == 0 {
                        titleDateNotesView
                    } else {
                        exercisesView
                    }

                    // Manual tab control buttons
                    HStack {
                        if selectedTab == 1 {
                            Button("← Back") {
                                withAnimation {
                                    selectedTab = 0
                                }
                            }
                            .padding()
                            .foregroundColor(AppColors.secondary)
                        }

                        if selectedTab == 0 {
                            Spacer()
                            Button("Next →") {
                                withAnimation {
                                    selectedTab = 1
                                }
                            }
                            .padding()
                            .foregroundColor(AppColors.secondary)
                        }
                    }
                }
            }

            // Toast overlay
            ToastView(message: "Workout Updated Successfully!", isShowing: $viewModel.showToast)
                .zIndex(1)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.deleteWorkout {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                            onDelete?()
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.saveEdits {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.secondary)
                }
            }
        }
    }

    // MARK: - Workout Details View
    private var titleDateNotesView: some View {
        VStack {
            Text("Workout Details")
                .font(.largeTitle)
                .bold()
                .foregroundColor(AppColors.secondary)

            TextField("", text: $viewModel.workout.title)
                .modifier(PlaceholderModifier(
                    showPlaceholder: viewModel.workout.title.isEmpty,
                    placeholder: "Workout Title",
                    color: .white.opacity(0.8)
                ))
                .padding()
                .background(AppColors.complementary.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)

            HStack {
                Text("Date")
                    .padding()
                    .foregroundColor(.white.opacity(0.8))

                DatePicker("", selection: $viewModel.workout.date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .colorInvert()
            }
            .padding(5)
            .background(AppColors.complementary.opacity(0.2))
            .cornerRadius(10)

            Text("Notes (Optional)")
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .padding(.top)

            TextEditor(text: $viewModel.notes)
                .frame(height: 100)
                .padding()
                .background(AppColors.complementary.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)

            Text("Press 'Next →' to edit exercises")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 5)

            Spacer()
        }
        .padding()
    }

    // MARK: - Exercises View
    private var exercisesView: some View {
        VStack {
            Text("Exercises")
                .font(.largeTitle)
                .bold()
                .foregroundColor(AppColors.secondary)

            Divider().background(Color.white)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.exercises.indices, id: \.self) { index in
                            ExerciseInputView(
                                viewModel: viewModel,
                                exercise: $viewModel.exercises[index],
                                exerciseIndex: index,
                                addSet: {
                                    withAnimation {
                                        viewModel.addSet(to: index)
                                    }
                                }
                            )
                            .id(index)
                        }
                    }
                    .padding(.horizontal)
                }

            Divider().background(Color.white)

            Button(action: {
                withAnimation {
                    viewModel.addExercise()
                }
            }) {
                Text("+ Add Exercise")
                    .font(.headline)
                    .foregroundColor(AppColors.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(AppColors.primary))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.secondary, lineWidth: 2))
            }
            .padding(0.5)
        }
        .padding()
    }
}
