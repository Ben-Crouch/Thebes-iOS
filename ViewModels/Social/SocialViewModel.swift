//
//  SocialViewModel.swift
//  Thebes
//
//  Created by Ben on 21/05/2025.
//

import Foundation

class SocialViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var users: [UserProfile] = []
    @Published var friends: Int = 0
    @Published var following: Int = 0
    @Published var followers: Int = 0
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?
    @Published var username: String = "User"
    @Published var profileImageUrl: String?
    
    func fetchSocialStats(for userId: String) {
        SocialService.shared.fetchCurrentUserSocialStats(userId: userId) { friendsCount, followersCount, followingCount in
            DispatchQueue.main.async {
                self.friends = friendsCount
                self.followers = followersCount
                self.following = followingCount
            }
        }
        
        // Also fetch user profile for header
        UserService.shared.fetchUserProfile(userId: userId) { userProfile in
            DispatchQueue.main.async {
                if let profile = userProfile {
                    self.username = profile.displayName
                    self.profileImageUrl = profile.profilePic
                }
            }
        }
    }
}
