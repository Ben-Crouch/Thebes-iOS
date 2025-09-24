//
//  TemplateLogView.swift
//  Thebes
//
//  Created by Ben on 12/03/2025.
//

import SwiftUI

struct TemplateLogView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TemplateLogViewModel

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: TemplateLogViewModel(userId: userId))
    }

    var body: some View {
        ZStack {
            AppColors.primary.edgesIgnoringSafeArea(.all)
            Divider()
                .background(AppColors.secondary.opacity(0.3))
                .frame(height: 1)
                .padding(.top, -5)

            VStack {
                titleInput
                exercisesView
            }

            // Toast message
            ToastView(message: "Template Saved Successfully!", isShowing: $viewModel.showToast)
                .zIndex(1)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("New Template")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.saveTemplate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.secondary)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var titleInput: some View {
        VStack {
            Text("Title")
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("", text: $viewModel.templateTitle)
                .modifier(PlaceholderModifier(
                    showPlaceholder: viewModel.templateTitle.isEmpty,
                    placeholder: "Enter Template Name",
                    color: .white.opacity(0.8)
                ))
                .padding()
                .background(AppColors.complementary.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
        }
        .padding()
    }

    private var exercisesView: some View {
        VStack {
            Text("Exercises")
                .font(.headline)
                .foregroundColor(AppColors.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            Divider().background(Color.white)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.exercises.indices, id: \.self) { index in
                        ExerciseInputView(
                            viewModel: viewModel,
                            exercise: $viewModel.exercises[index],
                            exerciseIndex: index,
                            addSet: { viewModel.addSet(to: index) }
                        )
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

