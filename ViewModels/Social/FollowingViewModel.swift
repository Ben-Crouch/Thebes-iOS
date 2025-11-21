//
//  FollowingViewModel.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

class FollowingViewModel: ObservableObject {
    @Published var following: [UserProfile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var onSocialStatsChanged: (() -> Void)?
    
    func fetchFollowing(for userId: String) {
        isLoading = true
        errorMessage = nil
        
        SocialService.shared.fetchFollowingUsers(userId: userId) { users in
            DispatchQueue.main.async {
                self.isLoading = false
                self.following = users
                
                if users.isEmpty {
                    self.errorMessage = nil // No error, just empty list
                }
            }
        }
    }
    
    func unfollowUser(userId: String, currentUserId: String, completion: @escaping (Bool) -> Void) {
        // Remove from current user's following list
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
                            
                            UserService.shared.updateUserProfile(userId: userId, updates: ["followers": updatedFollowers]) { followersUpdateSuccess in
                                DispatchQueue.main.async {
                                    if followersUpdateSuccess {
                                        // Remove from local array
                                        self.following.removeAll { $0.uid == userId }
                                        // Trigger callback to refresh social stats
                                        self.onSocialStatsChanged?()
                                        completion(true)
                                    } else {
                                        print("❌ Failed to update target user's followers list during unfollow")
                                        // Rollback: add back to current user's following list
                                        var rollbackFollowing = profile.following
                                        if !rollbackFollowing.contains(userId) {
                                            rollbackFollowing.append(userId)
                                        }
                                        UserService.shared.updateUserProfile(userId: currentUserId, updates: ["following": rollbackFollowing]) { _ in
                                            completion(false)
                                        }
                                    }
                                }
                            }
                        } else {
                            // Mock user - try to update followers array
                            UserService.shared.updateMockUserProfile(userId: userId, updates: ["followers": []]) { _ in
                                DispatchQueue.main.async {
                                    // Remove from local array
                                    self.following.removeAll { $0.uid == userId }
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
