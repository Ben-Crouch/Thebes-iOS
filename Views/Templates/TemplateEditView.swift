//  TemplateEditView.swift
//  Thebes
//
//  Created by Ben on 12/03/2025.
//

import SwiftUI

struct TemplateEditView: View {
    @StateObject private var viewModel: EditTemplateViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    var onDelete: (() -> Void)?  // Added onDelete closure

    init(template: Template, userId: String, onDelete: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditTemplateViewModel(template: template, userId: userId))
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack {
            AppColors.primary.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 15) {
                // ✅ Template Title Input
                Text("Title")
                    .font(.headline)
                    .foregroundColor(AppColors.secondary)
                TextField("", text: $viewModel.template.title)
                    .modifier(PlaceholderModifier(
                        showPlaceholder: viewModel.template.title.isEmpty,
                        placeholder: "Template Name",
                        color: .white.opacity(0.8)
                    ))
                    .padding()
                    .background(AppColors.complementary.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                // ✅ Exercises Section
                Text("Exercises")
                    .font(.headline)
                    .foregroundColor(AppColors.secondary)

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
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                viewModel.removeExercise(at: index)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Divider().background(Color.white)

                // ✅ Add Exercise Button
                Button(action: viewModel.addExercise) {
                    Text("+ Add Exercise")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.primary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.secondary, lineWidth: 2)
                        )
                }
                .padding(0.5)

                // ✅ Save Button
                Button(action: {
                    viewModel.saveEdits {
                        dismiss() // ✅ Dismiss after saving
                    }
                }) {
                    Text("Save Template")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.primary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.secondary, lineWidth: 2)
                        )
                }
                .padding(0.5)
            }
            .padding()
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

            ToolbarItem(placement: .principal) {
                Text("Edit Template")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.deleteTemplate {
                        dismiss()
                        onDelete?()  // Call onDelete closure after dismissing
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.saveEdits {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        .navigationBarBackButtonHidden(true)
    }
}
