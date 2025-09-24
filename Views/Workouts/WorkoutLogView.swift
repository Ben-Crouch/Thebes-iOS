//
//  WorkoutLogView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

struct WorkoutLogView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: WorkoutLogViewModel
    @State private var selectedTab = 0
    @State private var isTemplateSheetPresented = false
    @Environment(\.presentationMode) var presentationMode
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: WorkoutLogViewModel(userId: userId))
    }
    
    var body: some View {
        ZStack {
            AppColors.primary.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Progress dots
                HStack {
                    Circle().fill(selectedTab == 0 ? AppColors.secondary : .gray).frame(width: 10, height: 10)
                    Circle().fill(selectedTab == 1 ? AppColors.secondary : .gray).frame(width: 10, height: 10)
                }
                .padding(.top, 10)

                // Conditionally show the appropriate view
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

            // Toast overlay
            ToastView(message: "Workout Saved Successfully!", isShowing: $viewModel.showToast)
                .zIndex(1)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.save()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.secondary)
                }
            }
        }
    }

    // MARK: - Title / Date / Notes View
    private var titleDateNotesView: some View {
        VStack {
            Text("Workout Details")
                .font(.largeTitle)
                .bold()
                .foregroundColor(AppColors.secondary)

            TextField("", text: $viewModel.workoutTitle)
                .modifier(PlaceholderModifier(
                    showPlaceholder: viewModel.workoutTitle.isEmpty,
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

                DatePicker("", selection: Binding(
                    get: { viewModel.workoutDate ?? Date() },
                    set: { viewModel.workoutDate = $0 }
                ), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .tint(.white)
            }
            .padding(5)
            .background(AppColors.complementary.opacity(0.2))
            .cornerRadius(10)

            Text("Notes (Optional)")
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .padding(.top)

            TextEditor(text: Binding(
                get: { viewModel.notes ?? "" },
                set: { viewModel.notes = $0 }
            ))
                .frame(height: 100)
                .padding()
                .background(AppColors.complementary.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)

            Button(action: {
                isTemplateSheetPresented.toggle()
            }) {
                Text("Use Template")
                    .font(.headline)
                    .foregroundColor(AppColors.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(AppColors.primary))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.secondary, lineWidth: 2))
            }
            .sheet(isPresented: $isTemplateSheetPresented) {
                TemplateSelectionView(viewModel: viewModel)
            }

            Text("Press 'Next →' to add exercises")
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

            ScrollViewReader { proxy in
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
                    .onChange(of: viewModel.exercises.count) { _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.exercises.indices.last, anchor: .bottom)
                        }
                    }
                }
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
