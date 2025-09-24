//
//  SocialService.swift
//  Thebes
//
//  Created by Ben on 21/05/2025.
//

import FirebaseFirestore
import Foundation

class SocialService {
    static let shared = SocialService()
    private let db = Firestore.firestore()
    
    func fetchCurrentUserSocialStats(userId: String, completion: @escaping (Int, Int, Int) -> Void) {
        UserService.shared.fetchUserProfile(userId: userId) { userProfile in
            guard let profile = userProfile else { return }
            let followersCount = profile.followers.count
            let followingCount = profile.following.count
            let friendsCount = profile.following.filter { profile.followers.contains($0) }.count
            completion(friendsCount, followersCount, followingCount)
        }
    }
    
    func fetchSearchedUsers(userDisplayName: String, completion: @escaping ([UserProfile]) -> Void) {
        print("🔎 Searching users with display name containing: \(userDisplayName)")
        
        db.collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: userDisplayName)
            .whereField("displayName", isLessThan: userDisplayName + "\u{f8ff}") // ✅ allows partial search
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching users: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No users found")
                    completion([])
                    return
                }
                
                // Convert both real users and mock users to UserProfile format
                let users: [UserProfile] = documents.compactMap { doc in
                    // Try to parse as UserProfile first (real users)
                    if let userProfile = try? doc.data(as: UserProfile.self) {
                        return userProfile
                    }
                    
                    // Try to parse as MockUserProfile and convert to UserProfile
                    if let mockUser = try? doc.data(as: MockUserProfile.self) {
                        print("🔍 SocialService: Converting mock user \(mockUser.displayName)")
                        print("🔍 SocialService: Document ID = '\(doc.documentID)'")
                        print("🔍 SocialService: Document ID isEmpty = \(doc.documentID.isEmpty)")
                        
                        // Convert MockUserProfile to UserProfile format
                        let convertedUser = UserProfile(
                            id: mockUser.id,
                            uid: doc.documentID, // Use document ID as uid for mock users
                            displayName: mockUser.displayName,
                            email: mockUser.email,
                            profilePic: nil, // Mock users don't have profile pics
                            createdAt: Date(), // Default date for mock users
                            preferredWeightUnit: mockUser.preferredWeightUnit,
                            trackedExercise: nil,
                            followers: [], // Empty arrays for mock users initially
                            following: [] // Empty arrays for mock users initially
                        )
                        
                        print("🔍 SocialService: Converted user uid = '\(convertedUser.uid)'")
                        print("🔍 SocialService: Converted user uid isEmpty = \(convertedUser.uid.isEmpty)")
                        print("🔍 SocialService: Converted user object: \(convertedUser)")
                        
                        return convertedUser
                    }
                    
                    return nil
                }
                
                print("✅ Found \(users.count) matching users (real + mock)")
                completion(users)
            }
    }
    
    func fetchFollowingUsers(userId: String, completion: @escaping ([UserProfile]) -> Void) {
        print("📡 Fetching following users for userId: \(userId)")
        
        // First get the user's following list
        UserService.shared.fetchUserProfile(userId: userId) { userProfile in
            guard let profile = userProfile else {
                print("⚠️ User profile not found")
                completion([])
                return
            }
            
            let followingIds = profile.following
            guard !followingIds.isEmpty else {
                print("⚠️ No following IDs found")
                completion([])
                return
            }
            
            print("✅ Found following IDs: \(followingIds)")
            
            // Fetch user profiles for all following IDs
            self.db.collection("users")
                .whereField(FieldPath.documentID(), in: followingIds)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Error fetching following users: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("⚠️ No following users found")
                        completion([])
                        return
                    }
                    
                    print("✅ Retrieved snapshot with \(documents.count) following users")
                    
                    // Parse both real users and mock users
                    let users: [UserProfile] = documents.compactMap { doc in
                        // Try to parse as UserProfile first (real users)
                        if let userProfile = try? doc.data(as: UserProfile.self) {
                            return userProfile
                        }
                        
                        // Try to parse as MockUserProfile and convert to UserProfile
                        if let mockUser = try? doc.data(as: MockUserProfile.self) {
                            return UserProfile(
                                id: mockUser.id,
                                uid: doc.documentID,
                                displayName: mockUser.displayName,
                                email: mockUser.email,
                                profilePic: nil,
                                createdAt: Date(),
                                preferredWeightUnit: mockUser.preferredWeightUnit,
                                trackedExercise: nil,
                                followers: [],
                                following: []
                            )
                        }
                        
                        return nil
                    }
                    
                    print("✅ Found \(users.count) following users (real + mock)")
                    completion(users)
                }
        }
    }
    
    
    private func getExerciseCount(for workoutId: String, completion: @escaping (String) -> Void) {
        db.collection("exercises")
            .whereField("workoutId", isEqualTo: workoutId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching exercise count: \(error.localizedDescription)")
                    completion("0")
                    return
                }
                
                let count = snapshot?.documents.count ?? 0
                completion("\(count)")
            }
    }
    
    func fetchFriends(userId: String, completion: @escaping ([UserProfile]) -> Void) {
        print("📡 Fetching friends (mutual follows) for userId: \(userId)")
        
        // First get the user's following list
        UserService.shared.fetchUserProfile(userId: userId) { userProfile in
            guard let profile = userProfile else {
                print("⚠️ User profile not found")
                completion([])
                return
            }
            
            let followingIds = profile.following
            guard !followingIds.isEmpty else {
                print("⚠️ No following IDs found")
                completion([])
                return
            }
            
            // Get followers list to find mutual connections
            let followersIds = profile.followers
            let friendsIds = followingIds.filter { followersIds.contains($0) }
            
            guard !friendsIds.isEmpty else {
                print("⚠️ No mutual follows found")
                completion([])
                return
            }
            
            print("✅ Found \(friendsIds.count) mutual follows: \(friendsIds)")
            
            // Fetch user profiles for all friends IDs
            self.db.collection("users")
                .whereField(FieldPath.documentID(), in: friendsIds)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Error fetching friends: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("⚠️ No friends found")
                        completion([])
                        return
                    }
                    
                    print("✅ Retrieved snapshot with \(documents.count) friends")
                    
                    // Parse both real users and mock users
                    let users: [UserProfile] = documents.compactMap { doc in
                        // Try to parse as UserProfile first (real users)
                        if let userProfile = try? doc.data(as: UserProfile.self) {
                            return userProfile
                        }
                        
                        // Try to parse as MockUserProfile and convert to UserProfile
                        if let mockUser = try? doc.data(as: MockUserProfile.self) {
                            return UserProfile(
                                id: mockUser.id,
                                uid: doc.documentID,
                                displayName: mockUser.displayName,
                                email: mockUser.email,
                                profilePic: nil,
                                createdAt: Date(),
                                preferredWeightUnit: mockUser.preferredWeightUnit,
                                trackedExercise: nil,
                                followers: [],
                                following: []
                            )
                        }
                        
                        return nil
                    }
                    
                    print("✅ Found \(users.count) friends (real + mock)")
                    completion(users)
                }
        }
    }
    
    func fetchRecentActivity(userId: String, limit: Int = 10, completion: @escaping ([RecentWorkoutActivity]) -> Void) {
        print("📡 Fetching recent activity for userId: \(userId)")
        
        // First get the user's following list
        UserService.shared.fetchUserProfile(userId: userId) { userProfile in
            guard let profile = userProfile else {
                print("⚠️ User profile not found")
                completion([])
                return
            }
            
            let followingIds = profile.following
            guard !followingIds.isEmpty else {
                print("⚠️ No following IDs found")
                completion([])
                return
            }
            
            print("✅ Found \(followingIds.count) following IDs: \(followingIds)")
            
            // TODO: REVERT FOR LAUNCH - Currently fetching 1 year for development
            // Change back to remove date filter for production
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            
            // Fetch recent workouts from all followed users
            self.db.collection("workouts")
                .whereField("userId", in: followingIds)
                .whereField("date", isGreaterThan: oneYearAgo)
                .order(by: "date", descending: true)
                .limit(to: min(limit * 3, 50)) // Fetch more to account for filtering
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Error fetching recent activity: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("⚠️ No recent workouts found")
                        completion([])
                        return
                    }
                    
                    print("✅ Retrieved snapshot with \(documents.count) workouts")
                    
                    var activities: [RecentWorkoutActivity] = []
                    let group = DispatchGroup()
                    
                    for document in documents {
                        group.enter()
                        
                        do {
                            let workout = try document.data(as: Workout.self)
                            
                            // Get user profile for this workout
                            UserService.shared.fetchUserProfile(userId: workout.userId) { userProfile in
                                defer { group.leave() }
                                
                                guard let profile = userProfile else { return }
                                
                                let activity = RecentWorkoutActivity(
                                    id: workout.id ?? UUID().uuidString,
                                    workoutTitle: workout.title,
                                    workoutDate: workout.date,
                                    userDisplayName: profile.displayName,
                                    userProfilePic: profile.profilePic,
                                    exerciseCount: "N/A" // Simplified for development
                                )
                                activities.append(activity)
                            }
                        } catch {
                            print("❌ Error parsing workout: \(error.localizedDescription)")
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        // Sort by date and limit to requested amount
                        activities.sort { $0.workoutDate > $1.workoutDate }
                        completion(Array(activities.prefix(limit)))
                    }
                }
        }
    }
}
