//
//  FollowersViewModel.swift
//  Thebes
//
//  Created by Ben on 28/05/2025.
//

import Foundation

class FollowersViewModel: ObservableObject {
    @Published var followers: [UserProfile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var onSocialStatsChanged: (() -> Void)?
    
    func fetchFollowers(for userId: String) {
        isLoading = true
        errorMessage = nil
        
        FollowersService.shared.fetchFollowers(userId: userId) { followers in
            DispatchQueue.main.async {
                self.isLoading = false
                self.followers = followers
                
                if followers.isEmpty {
                    self.errorMessage = nil // No error, just empty list
                }
            }
        }
    }
    
    func followBackUser(userId: String, currentUserId: String, completion: @escaping (Bool) -> Void) {
        // Add the follower to current user's following list
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
                                    // Trigger callback to refresh social stats
                                    self.onSocialStatsChanged?()
                                    completion(true)
                                }
                            }
                        } else {
                            // Mock user - try to update followers array
                            UserService.shared.updateMockUserProfile(userId: userId, updates: ["followers": [currentUserId]]) { _ in
                                DispatchQueue.main.async {
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
}
