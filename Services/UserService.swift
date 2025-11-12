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
    func createUserProfile(user: User) {
        let userDoc = usersCollection.document(user.uid)
        
        let userData: [String: Any] = [
            "uid": user.uid,
            "displayName": user.displayName ?? "Anonymous",
            "email": user.email ?? "",
            "profilePic": user.photoURL?.absoluteString ?? "",
            "createdAt": Timestamp(),
            "preferredWeightUnit": "kg",
            "tagline": UserTagline.fitnessEnthusiast.rawValue
        ]
        
        userDoc.setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving user profile: \(error.localizedDescription)")
            } else {
                print("✅ User profile created successfully in Firestore")
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
            do {
                let userProfile = try document.data(as: UserProfile.self)
                print("✅ Found real user profile: \(userProfile.displayName)")
                completion(userProfile)
                return
            } catch {
                print("📝 Not a real user profile, trying mock user...")
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
        usersCollection.document(userId).updateData(updates) { error in
            if let error = error {
                print("❌ Error updating user profile: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ User profile updated successfully")
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

}
