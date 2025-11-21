//
import SwiftUI
//  TemplatesListView.swift
//  Thebes
//
//  Created by Ben on 23/07/2025.
//

import SwiftUI

struct TemplatesListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TemplatesListViewModel(userId: "")
    @State private var showSideMenu = false
    @State private var showDetail = false
    @State private var selectedTemplate: Template?
    
    var body: some View {
        ZStack {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header card
                        TemplatesListHeaderView(viewModel: viewModel)
                        
                        // Templates list
                        if viewModel.isLoading {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                                    .scaleEffect(1.5)
                                
                                Text("Loading Templates...")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding(.vertical, 40)
                        } else if viewModel.templates.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 48))
                                
                                Text("No Templates Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Create your first workout template to get started")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.templates.indices, id: \.self) { index in
                                    TemplateListItemCard(
                                        template: viewModel.templates[index],
                                        onTap: {
                                            selectedTemplate = viewModel.templates[index]
                                            showDetail = true
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation { showSideMenu.toggle() }
                    }) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            
            // Side Menu
            SideMenuView(
                isPresented: $showSideMenu,
                username: viewModel.username,
                profileImageUrl: viewModel.profileImageUrl,
                selectedAvatar: viewModel.selectedAvatar,
                useGradientAvatar: viewModel.useGradientAvatar,
                userEmail: authViewModel.user?.email,
                onViewProfile: {
                    // TODO: Navigate to user's own profile
                },
                onSettings: {
                    // TODO: Navigate to settings
                },
                onAbout: {
                    // TODO: Show about screen
                },
                onLogOut: {
                    authViewModel.signOut()
                }
            )
        }
        .onAppear {
            guard let userId = authViewModel.user?.uid else {
                print("⚠️ No valid user ID found. Skipping TemplatesListView data load.")
                return
            }
            // Update the viewModel's userId and load data
            viewModel.updateUserId(userId)
            viewModel.loadUserProfile()
            viewModel.loadTemplates()
        }
        .navigationDestination(isPresented: $showDetail) {
            if let template = selectedTemplate {
                TemplateDetailView(
                    template: template,
                    currentUserId: authViewModel.user?.uid ?? ""
                )
                .environmentObject(authViewModel)
            }
        }
    }
}

struct TemplatesListHeaderView: View {
    @ObservedObject var viewModel: TemplatesListViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            // Profile Section
            HStack(spacing: 16) {
                ProfileAvatarView(
                    profilePic: viewModel.profileImageUrl,
                    selectedAvatar: viewModel.selectedAvatar,
                    useGradientAvatar: viewModel.useGradientAvatar,
                    size: 70
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.username)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Templates")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // Stats Section
            HStack(spacing: 16) {
                StatItem(
                    value: "\(viewModel.templateCount)",
                    label: "Templates",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                StatItem(
                    value: "\(viewModel.templateCount)",
                    label: "Total",
                    icon: "list.bullet",
                    color: .green
                )
                
                StatItem(
                    value: "Ready",
                    label: "Status",
                    icon: "checkmark.circle",
                    color: .orange
                )
            }
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
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct TemplateListItemCard: View {
    let template: Template
    @Environment(\.colorScheme) var colorScheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(AppColors.secondary)
                            .font(.title3)
                        
                        Text(template.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    Text("Tap to view details")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.subheadline)
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
        .buttonStyle(PlainButtonStyle())
    }
}
