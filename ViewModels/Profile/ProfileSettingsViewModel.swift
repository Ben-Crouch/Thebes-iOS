//
//  ProfileSettingsViewModel.swift
//  Thebes
//
//  Created by Ben on 12/11/2025.
//

import Foundation
import FirebaseAuth

final class ProfileSettingsViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var profileImageUrl: String?
    @Published var selectedAvatar: DefaultAvatar = .teal
    @Published var useGradientAvatar: Bool = false
    @Published var preferredWeightUnit: WeightUnit = .kilograms
    @Published var tagline: UserTagline = .fitnessEnthusiast
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isGoogleConnected: Bool = false
    @Published var isAppleConnected: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    private let userService: UserService
    private var hasLoadedProfile = false
    
    init(userService: UserService = .shared) {
        self.userService = userService
    }
    
    func loadProfile(for userId: String?, fallbackDisplayName: String?, fallbackEmail: String?) {
        guard !isLoading else { return }
        guard let userId = userId, !userId.isEmpty else {
            applyFallback(displayName: fallbackDisplayName, email: fallbackEmail)
            return
        }
        
        // Prevent reloading if we already have data
        if hasLoadedProfile {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        userService.fetchUserProfile(userId: userId) { [weak self] profile in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                self.hasLoadedProfile = true
                
                guard let profile = profile else {
                    self.applyFallback(displayName: fallbackDisplayName, email: fallbackEmail)
                    self.updateConnectedProviders()
                    return
                }
                
                self.displayName = profile.displayName
                self.email = profile.email
                if let pic = profile.profilePic, !pic.isEmpty {
                    self.profileImageUrl = pic
                } else {
                    self.profileImageUrl = nil
                }
                self.selectedAvatar = DefaultAvatar.from(rawValue: profile.selectedAvatar)
                self.useGradientAvatar = profile.useGradientAvatar ?? false
                self.preferredWeightUnit = WeightUnit(fromPreferredUnit: profile.preferredWeightUnit)
                AppSettings.shared.updatePreferredUnit(self.preferredWeightUnit)
                self.tagline = UserTagline.from(rawValue: profile.tagline)
                self.updateConnectedProviders()
            }
        }
    }
    
    private func applyFallback(displayName: String?, email: String?) {
        DispatchQueue.main.async {
            if !self.hasLoadedProfile {
                self.displayName = displayName ?? "Athlete"
                self.email = email ?? ""
                self.profileImageUrl = nil
                self.selectedAvatar = .teal
                self.preferredWeightUnit = .kilograms
                AppSettings.shared.updatePreferredUnit(self.preferredWeightUnit)
                self.tagline = .fitnessEnthusiast
                self.hasLoadedProfile = true
            }
            self.isLoading = false
        }
    }
    
    func saveSelectedAvatar(for userId: String?, newAvatar: DefaultAvatar) {
        let previousAvatar = selectedAvatar
        selectedAvatar = newAvatar
        errorMessage = nil
        guard let userId = userId, !userId.isEmpty else { return }
        userService.updateUserProfile(userId: userId, updates: ["selectedAvatar": newAvatar.rawValue]) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !success {
                    self.selectedAvatar = previousAvatar
                    self.errorMessage = "Failed to update avatar. Please try again."
                } else {
                    print("✅ Avatar updated to: \(newAvatar.rawValue)")
                    self.showSuccessToast("Avatar updated successfully")
                }
            }
        }
    }
    
    func saveUseGradientAvatar(for userId: String?, useGradient: Bool) {
        let previousValue = useGradientAvatar
        useGradientAvatar = useGradient
        errorMessage = nil
        guard let userId = userId, !userId.isEmpty else { return }
        userService.updateUserProfile(userId: userId, updates: ["useGradientAvatar": useGradient]) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !success {
                    self.useGradientAvatar = previousValue
                    self.errorMessage = "Failed to update avatar preference. Please try again."
                } else {
                    print("✅ Use gradient avatar preference updated to: \(useGradient)")
                    self.showSuccessToast("Avatar preference updated")
                }
            }
        }
    }

    func saveTagline(for userId: String?, newTagline: UserTagline) {
        let previousTagline = tagline
        tagline = newTagline
        errorMessage = nil
        guard let userId = userId, !userId.isEmpty else { return }
        userService.updateUserProfile(userId: userId, updates: ["tagline": newTagline.rawValue]) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !success {
                    self.tagline = previousTagline
                    self.errorMessage = "Failed to update tagline. Please try again."
                } else {
                    self.showSuccessToast("Tagline updated")
                }
            }
        }
    }

    func savePreferredWeightUnit(for userId: String?, newUnit: WeightUnit) {
        let previousUnit = preferredWeightUnit
        preferredWeightUnit = newUnit
        errorMessage = nil
        guard let userId = userId, !userId.isEmpty else { return }
        userService.updateUserProfile(userId: userId, updates: ["preferredWeightUnit": newUnit.preferredUnitString]) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !success {
                    self.preferredWeightUnit = previousUnit
                    self.errorMessage = "Failed to update weight unit. Please try again."
                } else {
                    AppSettings.shared.updatePreferredUnit(self.preferredWeightUnit)
                    self.showSuccessToast("Weight unit updated to \(newUnit.symbol)")
                }
            }
        }
    }
    
    func saveDisplayName(for userId: String?, newDisplayName: String) {
        let trimmedName = newDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Display name cannot be empty"
            return
        }
        
        let previousName = displayName
        displayName = trimmedName
        errorMessage = nil
        guard let userId = userId, !userId.isEmpty else { return }
        userService.updateUserProfile(userId: userId, updates: ["displayName": trimmedName]) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !success {
                    self.displayName = previousName
                    self.errorMessage = "Failed to update display name. Please try again."
                } else {
                    print("✅ Display name updated to: \(trimmedName)")
                    self.showSuccessToast("Display name updated")
                }
            }
        }
    }

    private func updateConnectedProviders() {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            self.isGoogleConnected = false
            self.isAppleConnected = false
            return
        }
        self.isGoogleConnected = providerData.contains(where: { $0.providerID == "google.com" })
        self.isAppleConnected = providerData.contains(where: { $0.providerID == "apple.com" })
    }
    
    private func showSuccessToast(_ message: String) {
        toastMessage = message
        showToast = true
        // Toast will auto-hide after 2.5 seconds (handled by ToastView)
    }
}
