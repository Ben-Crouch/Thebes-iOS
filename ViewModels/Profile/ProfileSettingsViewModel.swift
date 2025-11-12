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
    @Published var preferredWeightUnit: WeightUnit = .kilograms
    @Published var tagline: UserTagline = .fitnessEnthusiast
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isGoogleConnected: Bool = false
    @Published var isAppleConnected: Bool = false
    
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
                self.preferredWeightUnit = .kilograms
                AppSettings.shared.updatePreferredUnit(self.preferredWeightUnit)
                self.tagline = .fitnessEnthusiast
                self.hasLoadedProfile = true
            }
            self.isLoading = false
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
                }
                AppSettings.shared.updatePreferredUnit(self.preferredWeightUnit)
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
}
