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
        
        // Normalize query for case-insensitive search
        let lowerQuery = userDisplayName.lowercased()
        let capitalizedQuery = userDisplayName.capitalized
        
        // Helper function to convert documents to UserProfile
        let convertDocuments: ([QueryDocumentSnapshot]) -> [UserProfile] = { documents in
            documents.compactMap { doc in
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
        }
        
        // Query with original case
        let query1 = db.collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: userDisplayName)
            .whereField("displayName", isLessThan: userDisplayName + "\u{f8ff}")
        
        // Query with lowercase
        let query2 = db.collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: lowerQuery)
            .whereField("displayName", isLessThan: lowerQuery + "\u{f8ff}")
        
        // Query with capitalized
        let query3 = db.collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: capitalizedQuery)
            .whereField("displayName", isLessThan: capitalizedQuery + "\u{f8ff}")
        
        // Use dispatch group to wait for all queries
        let group = DispatchGroup()
        var allUsers: [UserProfile] = []
        
        // Query 1: Original case
        group.enter()
        query1.getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                allUsers.append(contentsOf: convertDocuments(documents))
            }
            group.leave()
        }
        
        // Query 2: Lowercase
        group.enter()
        query2.getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                allUsers.append(contentsOf: convertDocuments(documents))
            }
            group.leave()
        }
        
        // Query 3: Capitalized
        group.enter()
        query3.getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                allUsers.append(contentsOf: convertDocuments(documents))
            }
            group.leave()
        }
        
        // Wait for all queries and filter case-insensitively
        group.notify(queue: .main) {
            // Remove duplicates based on uid
            var uniqueUsers: [UserProfile] = []
            var seenUids: Set<String> = []
            
            for user in allUsers {
                if !seenUids.contains(user.uid) {
                    // Final case-insensitive filter
                    if user.displayName.lowercased().contains(lowerQuery) {
                        uniqueUsers.append(user)
                        seenUids.insert(user.uid)
                    }
                }
            }
            
            print("✅ Found \(uniqueUsers.count) matching users (real + mock) after case-insensitive filtering")
            completion(uniqueUsers)
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
            
            print("✅ Found \(followingIds.count) following IDs: \(followingIds)")
            
            // Firestore's "in" operator is limited to 10 items, so we need to chunk the followingIds
            let followingBatches = followingIds.chunked(into: 10)
            let queryGroup = DispatchGroup()
            var allUsers: [UserProfile] = []
            
            // Fetch user profiles for each batch
            for batch in followingBatches {
                queryGroup.enter()
                
                self.db.collection("users")
                    .whereField(FieldPath.documentID(), in: batch)
                    .getDocuments { snapshot, error in
                        defer { queryGroup.leave() }
                        
                        if let error = error {
                            print("❌ Error fetching following users for batch: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            print("⚠️ No users found for this batch")
                            return
                        }
                        
                        print("✅ Retrieved \(documents.count) users from batch")
                        
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
                        
                        allUsers.append(contentsOf: users)
                    }
            }
            
            // Once all queries complete, return the combined results
            queryGroup.notify(queue: .main) {
                // Remove duplicates based on uid (in case of any overlap)
                var uniqueUsers: [UserProfile] = []
                var seenUids: Set<String> = []
                
                for user in allUsers {
                    if !seenUids.contains(user.uid) {
                        uniqueUsers.append(user)
                        seenUids.insert(user.uid)
                    }
                }
                
                print("✅ Found \(uniqueUsers.count) unique following users (real + mock)")
                completion(uniqueUsers)
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
            
            // Firestore's "in" operator is limited to 10 items, so we need to chunk the followingIds
            let followingBatches = followingIds.chunked(into: 10)
            let queryGroup = DispatchGroup()
            var allWorkouts: [Workout] = []
            
            // Fetch workouts from each batch
            for batch in followingBatches {
                queryGroup.enter()
                
                self.db.collection("workouts")
                    .whereField("userId", in: batch)
                    .whereField("date", isGreaterThan: oneYearAgo)
                    .order(by: "date", descending: true)
                    .limit(to: min(limit * 3, 50)) // Fetch more to account for filtering
                    .getDocuments { snapshot, error in
                        defer { queryGroup.leave() }
                        
                        if let error = error {
                            print("❌ Error fetching recent activity for batch: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            print("⚠️ No workouts found for this batch")
                            return
                        }
                        
                        print("✅ Retrieved \(documents.count) workouts from batch")
                        
                        for document in documents {
                            if let workout = try? document.data(as: Workout.self) {
                                allWorkouts.append(workout)
                            }
                        }
                    }
            }
            
            // Once all queries complete, process the workouts
            queryGroup.notify(queue: .main) {
                // Sort all workouts by date (descending) and take the top ones
                allWorkouts.sort { $0.date > $1.date }
                let topWorkouts = Array(allWorkouts.prefix(limit))
                
                print("✅ Processing \(topWorkouts.count) workouts for recent activity")
                
                var activities: [RecentWorkoutActivity] = []
                let profileGroup = DispatchGroup()
                
                for workout in topWorkouts {
                    profileGroup.enter()
                    
                    // Get user profile for this workout
                    UserService.shared.fetchUserProfile(userId: workout.userId) { userProfile in
                        defer { profileGroup.leave() }
                        
                        guard let profile = userProfile else { return }
                        
                        let activity = RecentWorkoutActivity(
                            id: workout.id ?? UUID().uuidString,
                            workoutId: workout.id,
                            userId: workout.userId,
                            workoutTitle: workout.title,
                            workoutDate: workout.date,
                            userDisplayName: profile.displayName,
                            userProfilePic: profile.profilePic,
                            exerciseCount: "N/A" // Simplified for development
                        )
                        activities.append(activity)
                    }
                }
                
                profileGroup.notify(queue: .main) {
                    // Final sort by date (descending)
                    activities.sort { $0.workoutDate > $1.workoutDate }
                    completion(activities)
                }
            }
        }
    }
}
