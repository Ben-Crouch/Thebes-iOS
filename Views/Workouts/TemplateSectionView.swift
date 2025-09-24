//
//  TemplateSectionView.swift
//  Thebes
//
//  Created by Ben on 08/04/2025.
//

import SwiftUI

struct TemplateSelectionView: View {
    @ObservedObject var viewModel: WorkoutLogViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showToast = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose a Template")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                List(viewModel.templates, id: \.id) { template in
                    Button(action: {
                        viewModel.applyTemplate(template) // Handle template selection
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showToast = false
                            dismiss()
                        }
                    }) {
                        Text(template.title)
                            .foregroundColor(.primary)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                                    .shadow(radius: 1)
                            )
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(.plain)
                .navigationTitle("Select a Template")
                .onAppear {
                    viewModel.loadTemplates()
                }
            }

            ToastView(message: "Template applied", isShowing: $showToast)
        }
    }
}
