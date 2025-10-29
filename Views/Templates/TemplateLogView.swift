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

            ScrollView {
                VStack(spacing: 24) {
                    titleInput
                    exercisesView
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
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
        VStack(spacing: 16) {
            // Header card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                    
                    Text("Template Details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Text("Create a reusable workout template")
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
                Text("Template Name")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("", text: $viewModel.templateTitle)
                    .modifier(PlaceholderModifier(
                        showPlaceholder: viewModel.templateTitle.isEmpty,
                        placeholder: "Enter template name...",
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
        }
    }

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
                
                Text("Add exercises to your template")
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
                        addSet: { viewModel.addSet(to: index) }
                    )
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

