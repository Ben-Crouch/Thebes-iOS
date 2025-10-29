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
    @State private var showDeleteConfirmation = false
    @State private var showSaveConfirmation = false
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Modern gradient background
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

            if viewModel.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                        .scaleEffect(1.5)
                    
                    Text("Loading Exercises...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            } else {
                VStack(spacing: 0) {
                    // Modern progress indicator
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            ForEach(0..<2, id: \.self) { index in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedTab = index
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(selectedTab == index ? AppColors.secondary : Color.gray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                            .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                                        
                                        Text(index == 0 ? "Details" : "Exercises")
                                            .font(.subheadline)
                                            .fontWeight(selectedTab == index ? .semibold : .regular)
                                            .foregroundColor(selectedTab == index ? AppColors.secondary : .gray)
                                    }
                                }
                            }
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(AppColors.secondary)
                                    .frame(width: geometry.size.width * (selectedTab == 0 ? 0.5 : 1.0), height: 4)
                                    .cornerRadius(2)
                                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Main content area
                    ScrollView {
                        VStack(spacing: 20) {
                            if selectedTab == 0 {
                                titleDateNotesView
                            } else {
                                exercisesView
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Space for navigation buttons
                    }
                }

                // Modern navigation buttons
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        if selectedTab == 1 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedTab = 0
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.subheadline)
                                    Text("Back")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        if selectedTab == 0 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedTab = 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Next")
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(AppColors.secondary)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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
                HStack(spacing: 16) {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppColors.secondary)
                            .font(.title3)
                    }

                    Button(action: {
                        showSaveConfirmation = true
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.secondary)
                    }
                }
            }
        }
        .alert("Delete Workout", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteWorkout {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                        onDelete?()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
        .alert("Save Changes", isPresented: $showSaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                viewModel.saveEdits {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to save these changes to your workout?")
        }
    }

    // MARK: - Workout Details View
    private var titleDateNotesView: some View {
        VStack(spacing: 24) {
            // Header card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                    
                    Text("Edit Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Text("Update your workout details and exercises")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
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

            // Title input card
            VStack(alignment: .leading, spacing: 12) {
                Text("Workout Title")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("", text: $viewModel.workout.title)
                    .modifier(PlaceholderModifier(
                        showPlaceholder: viewModel.workout.title.isEmpty,
                        placeholder: "Enter workout title...",
                        color: .gray
                    ))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
            }

            // Date picker card
            VStack(alignment: .leading, spacing: 12) {
                Text("Date")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(AppColors.secondary)
                        .font(.title3)
                    
                    DatePicker("", selection: $viewModel.workout.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .foregroundColor(.white)
                        .tint(AppColors.secondary)
                    
                    Spacer()
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
            }

            // Notes card
            VStack(alignment: .leading, spacing: 12) {
                Text("Notes (Optional)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextEditor(text: $viewModel.notes)
                    .frame(height: 100)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
            }

            // Next step hint
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text("Press 'Next' to edit exercises")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Exercises View
    private var exercisesView: some View {
        VStack(spacing: 24) {
            // Header card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                    
                    Text("Exercises")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Text("Edit exercises and track your sets, reps, and weights")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
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

            // Exercises list
            VStack(spacing: 16) {
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

            // Add exercise button
            Button(action: {
                withAnimation {
                    viewModel.addExercise()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title3)
                    
                    Text("Add Exercise")
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
}
