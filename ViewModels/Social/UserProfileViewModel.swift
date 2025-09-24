//
//  UserProfileViewModel.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var recentWorkouts: [Workout] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingWorkouts: Bool = false
    @Published var errorMessage: String?
    @Published var isFollowingUser: Bool = false
    @Published var isFollowingStatusLoaded: Bool = false
    
    var onSocialStatsChanged: (() -> Void)?
    private var currentUserId: String?
    
    func setCurrentUserId(_ userId: String?) {
        self.currentUserId = userId
    }
    
    private func getCurrentUserId() -> String? {
        return currentUserId
    }
    
    func fetchUserProfile(userId: String) {
        print("🔍 UserProfileViewModel: fetchUserProfile called with userId: \(userId)")
        isLoading = true
        errorMessage = nil
        
        // Try to fetch the profile with a retry mechanism
        fetchUserProfileWithRetry(userId: userId, attempt: 1, maxAttempts: 3)
    }
    
    func checkFollowingStatus(targetUserId: String, currentUserId: String, targetProfile: UserProfile? = nil) {
        print("🔍 UserProfileViewModel: checkFollowingStatus called for target: \(targetUserId)")
        print("🔍 UserProfileViewModel: currentUserId: \(currentUserId)")
        
        // Reset the loading state
        isFollowingStatusLoaded = false
        
        // Use the passed profile or fall back to the instance variable
        let profileToCheck = targetProfile ?? userProfile
        
        if let profile = profileToCheck {
            let isFollowing = profile.followers.contains(currentUserId)
            print("🔍 UserProfileViewModel: Checking target user's followers list: \(profile.followers)")
            print("🔍 UserProfileViewModel: Current user in followers: \(isFollowing)")
            
            DispatchQueue.main.async {
                self.isFollowingUser = isFollowing
                self.isFollowingStatusLoaded = true
                print("🔍 UserProfileViewModel: Following status set to: \(self.isFollowingUser)")
            }
        } else {
            print("🔍 UserProfileViewModel: Target profile not available, defaulting to false")
            DispatchQueue.main.async {
                self.isFollowingUser = false
                self.isFollowingStatusLoaded = true
            }
        }
    }
    
    private func fetchUserProfileWithRetry(userId: String, attempt: Int, maxAttempts: Int) {
        print("🔍 UserProfileViewModel: Attempt \(attempt) of \(maxAttempts)")
        
        UserService.shared.fetchUserProfile(userId: userId) { profile in
            DispatchQueue.main.async {
                if let profile = profile {
                    print("✅ UserProfileViewModel: Successfully fetched profile for \(profile.displayName)")
                    print("🔍 UserProfileViewModel: Profile uid = '\(profile.uid)'")
                    self.userProfile = profile
                    self.isLoading = false
                    
                    // Check following status after profile is loaded
                    if let currentUserId = self.getCurrentUserId() {
                        print("🔍 UserProfileViewModel: Profile loaded, checking following status")
                        print("🔍 UserProfileViewModel: currentUserId: '\(currentUserId)'")
                        print("🔍 UserProfileViewModel: targetUserId: '\(userId)'")
                        print("🔍 UserProfileViewModel: Are they different? \(currentUserId != userId)")
                        
                        if currentUserId != userId {
                            print("🔍 UserProfileViewModel: Calling checkFollowingStatus")
                            self.checkFollowingStatus(targetUserId: userId, currentUserId: currentUserId, targetProfile: profile)
                        } else {
                            print("🔍 UserProfileViewModel: Same user, skipping following status check")
                        }
                    } else {
                        print("🔍 UserProfileViewModel: No current user ID available")
                    }
                } else {
                    print("❌ UserProfileViewModel: Profile not found for userId: \(userId) (attempt \(attempt))")
                    
                    if attempt < maxAttempts {
                        // Retry after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.fetchUserProfileWithRetry(userId: userId, attempt: attempt + 1, maxAttempts: maxAttempts)
                        }
                    } else {
                        // Max attempts reached
                        self.isLoading = false
                        self.errorMessage = "User profile not found"
                    }
                }
            }
        }
    }
    
    func fetchRecentWorkouts(for userId: String, limit: Int = 5) {
        isLoadingWorkouts = true
        
        WorkoutService.shared.fetchWorkouts(for: userId) { result in
            DispatchQueue.main.async {
                self.isLoadingWorkouts = false
                switch result {
                case .success(let workouts):
                    self.recentWorkouts = workouts
                case .failure(let error):
                    print("❌ Error fetching workouts: \(error.localizedDescription)")
                    self.recentWorkouts = []
                }
            }
        }
    }
    
    func followUser(userId: String, currentUserId: String, completion: @escaping (Bool) -> Void) {
        UserService.shared.fetchUserProfile(userId: currentUserId) { userProfile in
            guard let profile = userProfile else {
                completion(false)
                return
            }
            
            var updatedFollowing = profile.following
            if !updatedFollowing.contains(userId) {
                updatedFollowing.append(userId)
            }
            
            // Update current user's following list
            UserService.shared.updateUserProfile(userId: currentUserId, updates: ["following": updatedFollowing]) { success in
                if success {
                    // Try to add current user to target user's followers list
                    UserService.shared.fetchUserProfile(userId: userId) { targetProfile in
                        if let targetProfile = targetProfile {
                            // Real user - update followers array
                            var updatedFollowers = targetProfile.followers
                            if !updatedFollowers.contains(currentUserId) {
                                updatedFollowers.append(currentUserId)
                            }
                            
                            UserService.shared.updateUserProfile(userId: userId, updates: ["followers": updatedFollowers]) { _ in
                                DispatchQueue.main.async {
                                    // Update local profile
                                    if var localProfile = self.userProfile {
                                        localProfile.followers.append(currentUserId)
                                        self.userProfile = localProfile
                                    }
                                    // Update following status
                                    self.isFollowingUser = true
                                    // Trigger callback to refresh social stats
                                    self.onSocialStatsChanged?()
                                    completion(true)
                                }
                            }
                        } else {
                            // Mock user - try to update followers array
                            UserService.shared.updateMockUserProfile(userId: userId, updates: ["followers": [currentUserId]]) { _ in
                                DispatchQueue.main.async {
                                    // Update local profile
                                    if var localProfile = self.userProfile {
                                        localProfile.followers.append(currentUserId)
                                        self.userProfile = localProfile
                                    }
                                    // Update following status
                                    self.isFollowingUser = true
                                    // Trigger callback to refresh social stats
                                    self.onSocialStatsChanged?()
                                    completion(true)
                                }
                            }
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func unfollowUser(userId: String, currentUserId: String, completion: @escaping (Bool) -> Void) {
        UserService.shared.fetchUserProfile(userId: currentUserId) { userProfile in
            guard let profile = userProfile else {
                completion(false)
                return
            }
            
            let updatedFollowing = profile.following.filter { $0 != userId }
            
            // Update current user's following list
            UserService.shared.updateUserProfile(userId: currentUserId, updates: ["following": updatedFollowing]) { success in
                if success {
                    // Try to remove current user from target user's followers list
                    UserService.shared.fetchUserProfile(userId: userId) { targetProfile in
                        if let targetProfile = targetProfile {
                            // Real user - update followers array
                            let updatedFollowers = targetProfile.followers.filter { $0 != currentUserId }
                            
                            UserService.shared.updateUserProfile(userId: userId, updates: ["followers": updatedFollowers]) { _ in
                                DispatchQueue.main.async {
                                    // Update local profile
                                    if var localProfile = self.userProfile {
                                        localProfile.followers.removeAll { $0 == currentUserId }
                                        self.userProfile = localProfile
                                    }
                                    // Update following status
                                    self.isFollowingUser = false
                                    // Trigger callback to refresh social stats
                                    self.onSocialStatsChanged?()
                                    completion(true)
                                }
                            }
                        } else {
                            // Mock user - try to update followers array
                            UserService.shared.updateMockUserProfile(userId: userId, updates: ["followers": []]) { _ in
                                DispatchQueue.main.async {
                                    // Update local profile
                                    if var localProfile = self.userProfile {
                                        localProfile.followers.removeAll { $0 == currentUserId }
                                        self.userProfile = localProfile
                                    }
                                    // Update following status
                                    self.isFollowingUser = false
                                    // Trigger callback to refresh social stats
                                    self.onSocialStatsChanged?()
                                    completion(true)
                                }
                            }
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func isFollowing(currentUserId: String) -> Bool {
        // We need to check if the current user is following the target user
        // This should be done by checking the current user's following list, not the target user's followers
        // For now, we'll check if the current user is in the target user's followers list
        // This is a simplified approach - ideally we'd check the current user's following list
        guard let profile = userProfile else { return false }
        return profile.followers.contains(currentUserId)
    }
    
    func isFriend(currentUserId: String) -> Bool {
        guard let profile = userProfile else { return false }
        return profile.followers.contains(currentUserId) && profile.following.contains(currentUserId)
    }
}
