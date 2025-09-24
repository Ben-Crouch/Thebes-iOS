//
//  FollowersService.swift
//  Thebes
//
//  Created by Ben on 28/05/2025.
//

import FirebaseFirestore
import Foundation

class FollowersService {
    static let shared = FollowersService()
    private let db = Firestore.firestore()
    
    func fetchFollowers(userId: String, completion: @escaping ([UserProfile]) -> Void) {
        print("📡 Fetching followers for userId: \(userId)")
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { documentSnapshot, error in
            guard let document = documentSnapshot,
                  let data = document.data(),
                  let followerIds = data["followers"] as? [String],
                  !followerIds.isEmpty else {
                print("⚠️ No following IDs found or document doesn't exist")
                completion([])
                return
            }

            print("✅ Found follower IDs: \(followerIds)")

            self.db.collection("users")
                .whereField(FieldPath.documentID(), in: followerIds)
                .getDocuments { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("⚠️ No snapshot returned from Firestore")
                        completion([])
                        return
                    }

                    print("✅ Retrieved snapshot with \(snapshot.documents.count) users")

                    // Parse both real users and mock users
                    let users: [UserProfile] = snapshot.documents.compactMap { doc in
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

                    print("✅ Found \(users.count) followers (real + mock)")
                    completion(users)
                }
        }
    }
    
}
