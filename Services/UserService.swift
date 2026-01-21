//
//  UserService.swift
//  Thebes
//
//  Created by Ben on 17/03/2025.
//

import FirebaseAuth
import FirebaseFirestore

class UserService {
    static let shared = UserService()
    private let usersCollection = Firestore.firestore().collection("users")

    /// Creates a new user profile in Firestore after signup
    /// - Parameters:
    ///   - user: The Firebase Auth user
    ///   - displayName: Optional display name (e.g., from Apple Sign-In fullName). If nil, uses user.displayName or "Anonymous"
    ///   - completion: Optional completion handler called with success status
    func createUserProfile(user: User, displayName: String? = nil, completion: ((Bool) -> Void)? = nil) {
        let userDoc = usersCollection.document(user.uid)
        
        print("📝 createUserProfile called for user: \(user.uid)")
        print("   Provided displayName: \(displayName ?? "nil")")
        print("   User.displayName: \(user.displayName ?? "nil")")
        
        // Check if user already exists to avoid overwriting existing data
        userDoc.getDocument { document, error in
            
            if let error = error {
                print("⚠️ Error checking existing document: \(error.localizedDescription)")
            }
            
            let documentExists = document?.exists ?? false
            let existingDisplayName = document?.data()?["displayName"] as? String
            
            print("   Document exists: \(documentExists)")
            print("   Existing displayName: \(existingDisplayName ?? "nil")")
            
            // Determine the display name to use:
            // 1. Use provided displayName (from Apple Sign-In) if available and not empty
            // 2. Otherwise, use existing displayName if it exists and isn't "Anonymous"
            // 3. Otherwise, use user.displayName
            // 4. Finally, fall back to "Anonymous"
            let finalDisplayName: String
            if let providedName = displayName, !providedName.isEmpty {
                finalDisplayName = providedName
                print("   ✅ Using provided displayName: \(finalDisplayName)")
            } else if let existing = existingDisplayName, existing != "Anonymous" {
                finalDisplayName = existing
                print("   ✅ Preserving existing displayName: \(finalDisplayName)")
            } else {
                finalDisplayName = user.displayName ?? "Anonymous"
                print("   ⚠️ Using fallback displayName: \(finalDisplayName)")
            }
            
            // Preserve existing followers and following arrays if document exists, otherwise initialize to empty arrays
            let existingFollowers = document?.data()?["followers"] as? [String] ?? []
            let existingFollowing = document?.data()?["following"] as? [String] ?? []
            
            let userData: [String: Any] = [
                "uid": user.uid,
                "displayName": finalDisplayName,
                "email": user.email ?? "",
                "profilePic": user.photoURL?.absoluteString ?? "",
                "selectedAvatar": document?.data()?["selectedAvatar"] as? String ?? "teal",
                "useGradientAvatar": document?.data()?["useGradientAvatar"] as? Bool ?? false,
                "createdAt": documentExists ? (document?.data()?["createdAt"] ?? Timestamp()) : Timestamp(),
                "preferredWeightUnit": document?.data()?["preferredWeightUnit"] as? String ?? "kg",
                "tagline": document?.data()?["tagline"] as? String ?? UserTagline.fitnessEnthusiast.rawValue,
                "followers": existingFollowers, // Preserve existing or initialize to empty array
                "following": existingFollowing  // Preserve existing or initialize to empty array
            ]
            
            print("   Saving userData with displayName: \(finalDisplayName)")
            
            userDoc.setData(userData, merge: true) { error in
                if let error = error {
                    print("❌ Error saving user profile: \(error.localizedDescription)")
                    completion?(false)
                } else {
                    print("✅ User profile created/updated successfully in Firestore")
                    print("   Final display name: \(finalDisplayName)")
                    completion?(true)
                }
            }
        }
    }
    
    /// Fetches a user profile from Firestore
    func fetchUserProfile(userId: String, completion: @escaping (UserProfile?) -> Void) {
        print("🔍 UserService: fetchUserProfile called with userId: '\(userId)'")
        print("🔍 UserService: userId.isEmpty = \(userId.isEmpty)")
        
        usersCollection.document(userId).getDocument { document, error in
            if let error = error {
                print("❌ Error fetching user profile: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("⚠️ User profile not found for userId: \(userId)")
                print("⚠️ Document exists: \(document?.exists ?? false)")
                completion(nil)
                return
            }
            
            print("✅ UserService: Document found for userId: \(userId)")
            print("🔍 UserService: Document ID: '\(document.documentID)'")
            print("🔍 UserService: Document data: \(document.data() ?? [:])")
            print("🔍 UserService: Document data keys: \(document.data()?.keys.sorted() ?? [])")
            
            // Special debugging for Alex Johnson
            if userId == "alex_johnson" {
                let data = document.data() ?? [:]
                print("🔍 Alex Johnson Debug:")
                print("  - followers: \(data["followers"] ?? "NOT FOUND")")
                print("  - following: \(data["following"] ?? "NOT FOUND")")
            }
            
            // Try to decode as UserProfile first (real users)
            let documentData = document.data() ?? [:]
            
            // Check if followers/following fields are missing (legacy profiles)
            let hasFollowers = documentData["followers"] != nil
            let hasFollowing = documentData["following"] != nil
            
            if !hasFollowers || !hasFollowing {
                print("⚠️ Profile missing followers/following fields, updating document...")
                // Update document to include missing fields with empty arrays
                var updates: [String: Any] = [:]
                if !hasFollowers {
                    updates["followers"] = [] as [String]
                }
                if !hasFollowing {
                    updates["following"] = [] as [String]
                }
                document.reference.updateData(updates) { error in
                    if let error = error {
                        print("⚠️ Error updating missing followers/following: \(error.localizedDescription)")
                    } else {
                        print("✅ Updated profile with missing followers/following fields")
                    }
                }
            }
            
            // Ensure followers and following arrays exist for decoding
            var finalData = documentData
            if documentData["followers"] == nil {
                finalData["followers"] = [] as [String]
            }
            if documentData["following"] == nil {
                finalData["following"] = [] as [String]
            }
            
            // Manually create the UserProfile to ensure all fields are present
            // First try to create as UserProfile (real user)
            let userProfile = UserProfile(
                id: document.documentID,
                uid: finalData["uid"] as? String ?? document.documentID,
                displayName: finalData["displayName"] as? String ?? "Unknown",
                email: finalData["email"] as? String ?? "",
                profilePic: finalData["profilePic"] as? String,
                selectedAvatar: finalData["selectedAvatar"] as? String,
                useGradientAvatar: finalData["useGradientAvatar"] as? Bool,
                createdAt: (finalData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                preferredWeightUnit: finalData["preferredWeightUnit"] as? String ?? "kg",
                trackedExercise: finalData["trackedExercise"] as? String,
                tagline: finalData["tagline"] as? String,
                followers: finalData["followers"] as? [String] ?? [],
                following: finalData["following"] as? [String] ?? []
            )
            
            // Check if this looks like a real user profile (has uid matching document ID or has email)
            if finalData["uid"] != nil || !(finalData["email"] as? String ?? "").isEmpty {
                print("✅ Found real user profile: \(userProfile.displayName)")
                completion(userProfile)
                return
            }
            
            // Try to decode as MockUserProfile and convert to UserProfile
            do {
                let mockUser = try document.data(as: MockUserProfile.self)
                print("✅ Found mock user profile: \(mockUser.displayName)")
                print("🔍 UserService: MockUserProfile decoded successfully")
                
                // Extract followers and following from document data since MockUserProfile doesn't have these fields
                let documentData = document.data() ?? [:]
                let followers = documentData["followers"] as? [String] ?? []
                let following = documentData["following"] as? [String] ?? []
                
                print("🔍 UserService: Extracted followers: \(followers)")
                print("🔍 UserService: Extracted following: \(following)")
                
                let userProfile = UserProfile(
                    id: mockUser.id,
                    uid: document.documentID, // Use document ID as uid for mock users
                    displayName: mockUser.displayName,
                    email: mockUser.email,
                    profilePic: nil,
                    selectedAvatar: documentData["selectedAvatar"] as? String ?? "teal",
                    useGradientAvatar: documentData["useGradientAvatar"] as? Bool ?? false,
                    createdAt: Date(),
                    preferredWeightUnit: mockUser.preferredWeightUnit,
                    trackedExercise: nil,
                    tagline: mockUser.tagline ?? UserTagline.fitnessEnthusiast.rawValue,
                    followers: followers, // Use actual followers from document
                    following: following // Use actual following from document
                )
                print("🔍 UserService: Created UserProfile with uid: '\(userProfile.uid)'")
                print("🔍 UserService: UserProfile followers: \(userProfile.followers)")
                print("🔍 UserService: UserProfile following: \(userProfile.following)")
                completion(userProfile)
                return
            } catch {
                print("📝 Not a mock user profile either...")
                print("📝 MockUserProfile decode error: \(error.localizedDescription)")
            }
            
            print("❌ Error decoding user profile for userId: \(userId)")
            completion(nil)
        }
    }
    
    /// Updates a user profile in Firestore
    func updateUserProfile(userId: String, updates: [String: Any], completion: @escaping (Bool) -> Void) {
        print("📝 updateUserProfile called for userId: \(userId)")
        print("📝 Updates: \(updates.keys.joined(separator: ", "))")
        
        usersCollection.document(userId).updateData(updates) { error in
            if let error = error {
                let nsError = error as NSError
                print("❌ Error updating user profile for \(userId): \(error.localizedDescription)")
                print("   Error domain: \(nsError.domain)")
                print("   Error code: \(nsError.code)")
                if !nsError.userInfo.isEmpty {
                    print("   Error userInfo: \(nsError.userInfo)")
                }
                completion(false)
            } else {
                print("✅ User profile updated successfully for \(userId)")
                if let followers = updates["followers"] as? [String] {
                    print("   Updated followers count: \(followers.count)")
                }
                if let following = updates["following"] as? [String] {
                    print("   Updated following count: \(following.count)")
                }
                completion(true)
            }
        }
    }
    
    /// Updates a mock user profile in Firestore (for testing)
    func updateMockUserProfile(userId: String, updates: [String: Any], completion: @escaping (Bool) -> Void) {
        usersCollection.document(userId).updateData(updates) { error in
            if let error = error {
                print("❌ Error updating mock user profile: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Mock user profile updated successfully")
                completion(true)
            }
        }
    }
    
    /// Checks if a document exists in the users collection
    func checkUserExists(userId: String, completion: @escaping (Bool) -> Void) {
        print("🔍 UserService: checkUserExists called with userId: '\(userId)'")
        usersCollection.document(userId).getDocument { document, error in
            if let error = error {
                print("❌ Error checking user existence: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            let exists = document?.exists ?? false
            print("🔍 UserService: User exists: \(exists) for userId: \(userId)")
            completion(exists)
        }
    }
    
    /// Deletes all user data from Firestore
    func deleteUserData(userId: String, completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        
        // First, fetch the user's profile to get their followers and following lists
        var userFollowers: [String] = []
        var userFollowing: [String] = []
        
        group.enter()
        usersCollection.document(userId).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                userFollowers = data["followers"] as? [String] ?? []
                userFollowing = data["following"] as? [String] ?? []
                print("📋 Found \(userFollowers.count) followers and \(userFollowing.count) following to clean up")
            }
            group.leave()
        }
        
        // Wait for profile fetch, then proceed with deletion
        group.notify(queue: .main) {
            self.performUserDataDeletion(userId: userId, followers: userFollowers, following: userFollowing, completion: completion)
        }
    }
    
    private func performUserDataDeletion(userId: String, followers: [String], following: [String], completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let group = DispatchGroup()
        var allSuccess = true
        
        // Delete user profile
        group.enter()
        usersCollection.document(userId).delete { error in
            if let error = error {
                print("❌ Error deleting user profile: \(error.localizedDescription)")
                allSuccess = false
            } else {
                print("✅ User profile deleted")
            }
            group.leave()
        }
        
        // Get user's workout IDs before deleting workouts (needed for exercise deletion)
        var workoutIds: [String] = []
        group.enter()
        db.collection("workouts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("⚠️ Error fetching workouts for deletion: \(error.localizedDescription)")
                group.leave()
                return
            }
            
            workoutIds = snapshot?.documents.map { $0.documentID } ?? []
            print("📋 Found \(workoutIds.count) workouts to delete")
            
            let batch = db.batch()
            snapshot?.documents.forEach { doc in
                batch.deleteDocument(doc.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("❌ Error deleting workouts: \(error.localizedDescription)")
                    allSuccess = false
                } else {
                    print("✅ Workouts deleted")
                }
                group.leave()
            }
        }
        
        // Get user's template IDs before deleting templates (needed for exercise deletion)
        var templateIds: [String] = []
        group.enter()
        db.collection("templates").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("⚠️ Error fetching templates for deletion: \(error.localizedDescription)")
                group.leave()
                return
            }
            
            templateIds = snapshot?.documents.map { $0.documentID } ?? []
            print("📋 Found \(templateIds.count) templates to delete")
            
            let batch = db.batch()
            snapshot?.documents.forEach { doc in
                batch.deleteDocument(doc.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("❌ Error deleting templates: \(error.localizedDescription)")
                    allSuccess = false
                } else {
                    print("✅ Templates deleted")
                }
                group.leave()
            }
        }
        
        // Delete exercises: those with userId matching, or workoutId/templateId matching user's workouts/templates
        group.enter()
        db.collection("exercises").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("⚠️ Error fetching exercises by userId: \(error.localizedDescription)")
                group.leave()
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                let exerciseBatch = db.batch()
                snapshot.documents.forEach { doc in
                    exerciseBatch.deleteDocument(doc.reference)
                }
                
                exerciseBatch.commit { error in
                    if let error = error {
                        print("❌ Error deleting exercises by userId: \(error.localizedDescription)")
                        allSuccess = false
                    } else {
                        print("✅ Deleted \(snapshot.documents.count) exercises by userId")
                    }
                    group.leave()
                }
            } else {
                print("✅ No exercises found by userId")
                group.leave()
            }
        }
        
        // Delete exercises by workoutId (after workouts are deleted, but we have the IDs)
        if !workoutIds.isEmpty {
            group.enter()
            // Firestore doesn't support "in" queries with more than 10 items, so we need to batch
            let workoutIdBatches = workoutIds.chunked(into: 10)
            var exercisesDeleted = 0
            let workoutExerciseGroup = DispatchGroup()
            
            for batch in workoutIdBatches {
                workoutExerciseGroup.enter()
                db.collection("exercises").whereField("workoutId", in: batch).getDocuments { snapshot, error in
                    if let error = error {
                        print("⚠️ Error fetching exercises by workoutId: \(error.localizedDescription)")
                    } else if let docs = snapshot?.documents, !docs.isEmpty {
                        let exerciseBatch = db.batch()
                        docs.forEach { doc in
                            exerciseBatch.deleteDocument(doc.reference)
                        }
                        exercisesDeleted += docs.count
                        exerciseBatch.commit { error in
                            if let error = error {
                                print("❌ Error deleting exercises by workoutId: \(error.localizedDescription)")
                                allSuccess = false
                            }
                            workoutExerciseGroup.leave()
                        }
                    } else {
                        workoutExerciseGroup.leave()
                    }
                }
            }
            
            workoutExerciseGroup.notify(queue: .main) {
                if exercisesDeleted > 0 {
                    print("✅ Deleted \(exercisesDeleted) exercises by workoutId")
                }
                group.leave()
            }
        }
        
        // Delete exercises by templateId (after templates are deleted, but we have the IDs)
        if !templateIds.isEmpty {
            group.enter()
            // Firestore doesn't support "in" queries with more than 10 items, so we need to batch
            let templateIdBatches = templateIds.chunked(into: 10)
            var exercisesDeleted = 0
            let templateExerciseGroup = DispatchGroup()
            
            for batch in templateIdBatches {
                templateExerciseGroup.enter()
                db.collection("exercises").whereField("templateId", in: batch).getDocuments { snapshot, error in
                    if let error = error {
                        print("⚠️ Error fetching exercises by templateId: \(error.localizedDescription)")
                    } else if let docs = snapshot?.documents, !docs.isEmpty {
                        let exerciseBatch = db.batch()
                        docs.forEach { doc in
                            exerciseBatch.deleteDocument(doc.reference)
                        }
                        exercisesDeleted += docs.count
                        exerciseBatch.commit { error in
                            if let error = error {
                                print("❌ Error deleting exercises by templateId: \(error.localizedDescription)")
                                allSuccess = false
                            }
                            templateExerciseGroup.leave()
                        }
                    } else {
                        templateExerciseGroup.leave()
                    }
                }
            }
            
            templateExerciseGroup.notify(queue: .main) {
                if exercisesDeleted > 0 {
                    print("✅ Deleted \(exercisesDeleted) exercises by templateId")
                }
                group.leave()
            }
        }
        
        // Remove user from all followers' following lists
        // (People who were following the deleted user need to remove them from their following list)
        if !followers.isEmpty {
            group.enter()
            let followersBatches = followers.chunked(into: 10) // Firestore batch limit
            var followersUpdated = 0
            let followersGroup = DispatchGroup()
            
            for batch in followersBatches {
                followersGroup.enter()
                // Fetch all users in this batch
                let batchRefs = batch.map { usersCollection.document($0) }
                var batchUpdates: [DocumentReference: [String: Any]] = [:]
                
                let fetchGroup = DispatchGroup()
                for ref in batchRefs {
                    fetchGroup.enter()
                    ref.getDocument { document, error in
                        if let document = document, document.exists,
                           let data = document.data(),
                           var following = data["following"] as? [String] {
                            following.removeAll { $0 == userId }
                            batchUpdates[ref] = ["following": following]
                        }
                        fetchGroup.leave()
                    }
                }
                
                fetchGroup.notify(queue: .main) {
                    if !batchUpdates.isEmpty {
                        let updateBatch = db.batch()
                        batchUpdates.forEach { ref, updates in
                            updateBatch.updateData(updates, forDocument: ref)
                        }
                        updateBatch.commit { error in
                            if let error = error {
                                print("❌ Error updating followers' following lists: \(error.localizedDescription)")
                                allSuccess = false
                            } else {
                                followersUpdated += batchUpdates.count
                            }
                            followersGroup.leave()
                        }
                    } else {
                        followersGroup.leave()
                    }
                }
            }
            
            followersGroup.notify(queue: .main) {
                if followersUpdated > 0 {
                    print("✅ Removed user from \(followersUpdated) followers' following lists")
                }
                group.leave()
            }
        }
        
        // Remove user from all following users' followers lists
        // (People the deleted user was following need to remove them from their followers list)
        if !following.isEmpty {
            group.enter()
            let followingBatches = following.chunked(into: 10) // Firestore batch limit
            var followingUpdated = 0
            let followingGroup = DispatchGroup()
            
            for batch in followingBatches {
                followingGroup.enter()
                // Fetch all users in this batch
                let batchRefs = batch.map { usersCollection.document($0) }
                var batchUpdates: [DocumentReference: [String: Any]] = [:]
                
                let fetchGroup = DispatchGroup()
                for ref in batchRefs {
                    fetchGroup.enter()
                    ref.getDocument { document, error in
                        if let document = document, document.exists,
                           let data = document.data(),
                           var followers = data["followers"] as? [String] {
                            followers.removeAll { $0 == userId }
                            batchUpdates[ref] = ["followers": followers]
                        }
                        fetchGroup.leave()
                    }
                }
                
                fetchGroup.notify(queue: .main) {
                    if !batchUpdates.isEmpty {
                        let updateBatch = db.batch()
                        batchUpdates.forEach { ref, updates in
                            updateBatch.updateData(updates, forDocument: ref)
                        }
                        updateBatch.commit { error in
                            if let error = error {
                                print("❌ Error updating following users' followers lists: \(error.localizedDescription)")
                                allSuccess = false
                            } else {
                                followingUpdated += batchUpdates.count
                            }
                            followingGroup.leave()
                        }
                    } else {
                        followingGroup.leave()
                    }
                }
            }
            
            followingGroup.notify(queue: .main) {
                if followingUpdated > 0 {
                    print("✅ Removed user from \(followingUpdated) following users' followers lists")
                }
                group.leave()
            }
        }
        
        // Also query all users who have the deleted user in their followers list
        // This handles edge cases where data might be inconsistent
        group.enter()
        print("🔍 Querying all users with deleted user in their followers list...")
        usersCollection.whereField("followers", arrayContains: userId).getDocuments { snapshot, error in
            if let error = error {
                print("⚠️ Error querying users with deleted user in followers: \(error.localizedDescription)")
                group.leave()
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("✅ No additional users found with deleted user in followers list")
                group.leave()
                return
            }
            
            print("📋 Found \(documents.count) additional users with deleted user in followers list")
            
            // Process in batches
            let documentBatches = documents.chunked(into: 10)
            var additionalUpdated = 0
            let additionalGroup = DispatchGroup()
            
            for batch in documentBatches {
                additionalGroup.enter()
                let updateBatch = db.batch()
                
                for doc in batch {
                    let data = doc.data()
                    if var followers = data["followers"] as? [String] {
                        let beforeCount = followers.count
                        followers.removeAll { $0 == userId }
                        if followers.count < beforeCount {
                            updateBatch.updateData(["followers": followers], forDocument: doc.reference)
                        }
                    }
                }
                
                updateBatch.commit { error in
                    if let error = error {
                        print("❌ Error updating additional users' followers lists: \(error.localizedDescription)")
                        allSuccess = false
                    } else {
                        additionalUpdated += batch.count
                    }
                    additionalGroup.leave()
                }
            }
            
            additionalGroup.notify(queue: .main) {
                if additionalUpdated > 0 {
                    print("✅ Removed deleted user from \(additionalUpdated) additional users' followers lists")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("✅ User data deletion completed")
            completion(allSuccess)
        }
    }
}

// Helper extension to chunk arrays for Firestore queries (max 10 items per "in" query)
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
