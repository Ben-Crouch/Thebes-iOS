//  TemplateEditView.swift
import SwiftUI
//  Thebes
//
//  Created by Ben on 12/03/2025.
//

import SwiftUI

struct TemplateEditView: View {
    @StateObject private var viewModel: EditTemplateViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    var onDelete: (() -> Void)?  // Added onDelete closure
    
    @State private var showDeleteConfirmation = false
    @State private var showSaveConfirmation = false

    init(template: Template, userId: String, onDelete: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditTemplateViewModel(template: template, userId: userId))
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
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
                ScrollView {
                    VStack(spacing: 24) {
                        detailsView
                        exercisesView
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }

            // Toast
            ToastView(message: "Template Updated Successfully!", isShowing: $viewModel.showToast)
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
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppColors.secondary)
                            .font(.title3)
                    }

                    Button(action: { showSaveConfirmation = true }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.secondary)
                    }
                }
            }
        }
        .alert("Delete Template", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteTemplate {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                        onDelete?()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this template? This action cannot be undone.")
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
            Text("Are you sure you want to save these changes to your template?")
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    // MARK: - Details View
    private var detailsView: some View {
        VStack(spacing: 24) {
            // Header card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)

                    Text("Edit Template")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()
                }

                Text("Update your template details and exercises")
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
                Text("Template Title")
                    .font(.headline)
                    .foregroundColor(.white)

                TextField("", text: $viewModel.template.title)
                    .modifier(PlaceholderModifier(
                        showPlaceholder: viewModel.template.title.isEmpty,
                        placeholder: "Enter template title...",
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
                            withAnimation { viewModel.addSet(to: index) }
                        }
                    )
                    .id(index)
                }
            }

            // Add exercise button
            Button(action: { withAnimation { viewModel.addExercise() } }) {
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
