//
//  UserProfile.swift
//  Thebes
//
//  Created by Ben on 17/03/2025.
//

import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var displayName: String
    var email: String
    var profilePic: String?
    var selectedAvatar: String? // DefaultAvatar rawValue (e.g., "teal", "blue")
    var useGradientAvatar: Bool? // If true, use gradient avatar even if profilePic exists
    var createdAt: Date
    var preferredWeightUnit: String
    var trackedExercise: String?
    var tagline: String?
    var followers: [String]
    var following: [String]
}
