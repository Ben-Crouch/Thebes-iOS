//
//  SocialSearchViewModel.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

class SocialSearchViewModel: ObservableObject {
    @Published var searchResults: [UserProfile] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    
    var onSocialStatsChanged: (() -> Void)?
    
    func searchUsers(query: String) {
        guard !query.isEmpty else {
            clearResults()
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        SocialService.shared.fetchSearchedUsers(userDisplayName: query) { users in
            DispatchQueue.main.async {
                self.searchResults = users
                self.isSearching = false
            }
        }
    }
    
    func clearResults() {
        searchResults = []
        isSearching = false
        errorMessage = nil
    }
    
    func toggleFollow(userId: String, currentUserId: String) {
        // Check if user is already following
        UserService.shared.fetchUserProfile(userId: currentUserId) { userProfile in
            guard let profile = userProfile else { return }
            
            let isCurrentlyFollowing = profile.following.contains(userId)
            
            if isCurrentlyFollowing {
                // Unfollow
                self.unfollowUser(userId: userId, currentUserId: currentUserId)
            } else {
                // Follow
                self.followUser(userId: userId, currentUserId: currentUserId)
            }
        }
    }
    
    private func followUser(userId: String, currentUserId: String) {
        // Add to current user's following list
        UserService.shared.fetchUserProfile(userId: currentUserId) { userProfile in
            guard let profile = userProfile else { return }
            
            var updatedFollowing = profile.following
            updatedFollowing.append(userId)
            
            // Update current user's following list
            UserService.shared.updateUserProfile(userId: currentUserId, updates: ["following": updatedFollowing]) { success in
                if success {
                    // Try to add current user to target user's followers list
                    UserService.shared.fetchUserProfile(userId: userId) { targetProfile in
                        if let targetProfile = targetProfile {
                            // Real user - update followers array
                            var updatedFollowers = targetProfile.followers
                            updatedFollowers.append(currentUserId)
                            
                            UserService.shared.updateUserProfile(userId: userId, updates: ["followers": updatedFollowers]) { success in
                                print(success ? "✅ Successfully followed real user" : "❌ Failed to follow real user")
                                if success {
                                    DispatchQueue.main.async {
                                        self.onSocialStatsChanged?()
                                    }
                                }
                            }
                        } else {
                            // Mock user - create followers array
                            UserService.shared.updateMockUserProfile(userId: userId, updates: ["followers": [currentUserId]]) { success in
                                print(success ? "✅ Successfully followed mock user" : "❌ Failed to follow mock user")
                                if success {
                                    DispatchQueue.main.async {
                                        self.onSocialStatsChanged?()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func unfollowUser(userId: String, currentUserId: String) {
        // Remove from current user's following list
        UserService.shared.fetchUserProfile(userId: currentUserId) { userProfile in
            guard let profile = userProfile else { return }
            
            let updatedFollowing = profile.following.filter { $0 != userId }
            
            // Update current user's following list
            UserService.shared.updateUserProfile(userId: currentUserId, updates: ["following": updatedFollowing]) { success in
                if success {
                    // Try to remove current user from target user's followers list
                    UserService.shared.fetchUserProfile(userId: userId) { targetProfile in
                        if let targetProfile = targetProfile {
                            // Real user - update followers array
                            let updatedFollowers = targetProfile.followers.filter { $0 != currentUserId }
                            
                            UserService.shared.updateUserProfile(userId: userId, updates: ["followers": updatedFollowers]) { success in
                                print(success ? "✅ Successfully unfollowed real user" : "❌ Failed to unfollow real user")
                                if success {
                                    DispatchQueue.main.async {
                                        self.onSocialStatsChanged?()
                                    }
                                }
                            }
                        } else {
                            // Mock user - try to update followers array (might not exist)
                            UserService.shared.updateMockUserProfile(userId: userId, updates: ["followers": []]) { success in
                                print(success ? "✅ Successfully unfollowed mock user" : "❌ Failed to unfollow mock user")
                                if success {
                                    DispatchQueue.main.async {
                                        self.onSocialStatsChanged?()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
