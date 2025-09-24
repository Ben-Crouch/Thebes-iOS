//
//  FriendsViewModel.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

class FriendsViewModel: ObservableObject {
    @Published var friends: [UserProfile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var onSocialStatsChanged: (() -> Void)?
    
    func fetchFriends(for userId: String) {
        isLoading = true
        errorMessage = nil
        
        SocialService.shared.fetchFriends(userId: userId) { friends in
            DispatchQueue.main.async {
                self.isLoading = false
                self.friends = friends
                
                if friends.isEmpty {
                    self.errorMessage = nil // No error, just empty list
                }
            }
        }
    }
    
    func unfriendUser(userId: String, currentUserId: String, completion: @escaping (Bool) -> Void) {
        // Unfriend by unfollowing (since friends are mutual follows)
        // This will remove the mutual connection
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
                                    // Remove from local array
                                    self.friends.removeAll { $0.uid == userId }
                                    // Trigger callback to refresh social stats
                                    self.onSocialStatsChanged?()
                                    completion(true)
                                }
                            }
                        } else {
                            // Mock user - try to update followers array
                            UserService.shared.updateMockUserProfile(userId: userId, updates: ["followers": []]) { _ in
                                DispatchQueue.main.async {
                                    // Remove from local array
                                    self.friends.removeAll { $0.uid == userId }
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
