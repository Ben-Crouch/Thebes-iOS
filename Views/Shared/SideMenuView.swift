//
//  SideMenuView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI

// MARK: - Menu Item Button Component
struct MenuItemButton: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : AppColors.secondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isDestructive ? .red : .white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Side Menu View
struct SideMenuView: View {
    @Binding var isPresented: Bool
    let username: String
    let profileImageUrl: String?
    let selectedAvatar: DefaultAvatar
    let useGradientAvatar: Bool
    let userEmail: String?
    let onViewProfile: () -> Void
    let onSettings: () -> Void
    let onAbout: () -> Void
    let onLogOut: () -> Void
    
    init(isPresented: Binding<Bool>, username: String, profileImageUrl: String?, selectedAvatar: DefaultAvatar = .teal, useGradientAvatar: Bool = false, userEmail: String?, onViewProfile: @escaping () -> Void, onSettings: @escaping () -> Void = {}, onAbout: @escaping () -> Void = {}, onLogOut: @escaping () -> Void = {}) {
        self._isPresented = isPresented
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.selectedAvatar = selectedAvatar
        self.useGradientAvatar = useGradientAvatar
        self.userEmail = userEmail
        self.onViewProfile = onViewProfile
        self.onSettings = onSettings
        self.onAbout = onAbout
        self.onLogOut = onLogOut
    }
    
    var body: some View {
        Group {
            if isPresented {
                // Overlay background
                Color(uiColor: .black).opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                
                // Menu content
                VStack(alignment: .leading, spacing: 0) {
                    // User Profile Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // User avatar
                            ProfileAvatarView(
                                profilePic: profileImageUrl,
                                selectedAvatar: selectedAvatar,
                                useGradientAvatar: useGradientAvatar,
                                size: 60
                            )
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(username)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let email = userEmail {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                    )
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Menu Items
                    VStack(alignment: .leading, spacing: 0) {
                        MenuItemButton(
                            icon: "person.circle",
                            title: "View Profile",
                            action: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isPresented = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onViewProfile()
                                }
                            }
                        )
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        MenuItemButton(
                            icon: "gearshape",
                            title: "Settings",
                            action: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isPresented = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSettings()
                                }
                            }
                        )
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        MenuItemButton(
                            icon: "info.circle",
                            title: "About",
                            action: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isPresented = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onAbout()
                                }
                            }
                        )
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        MenuItemButton(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Log Out",
                            isDestructive: true,
                            action: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isPresented = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onLogOut()
                                }
                            }
                        )
                    }
                    
                    Spacer()
                }
                .frame(width: 280)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black,
                            Color(uiColor: .black).opacity(0.95),
                            Color.black
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Rectangle()
                        .fill(AppColors.secondary.opacity(0.3))
                        .frame(width: 1),
                    alignment: .leading
                )
                .transition(.move(edge: .trailing))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .zIndex(2)
            }
        }
    }
}

#Preview {
    SideMenuView(
        isPresented: .constant(true),
        username: "John Doe",
        profileImageUrl: nil,
        selectedAvatar: .teal,
        useGradientAvatar: false,
        userEmail: "john@example.com",
        onViewProfile: {},
        onSettings: {},
        onAbout: {},
        onLogOut: {}
    )
}
