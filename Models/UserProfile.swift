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
    var createdAt: Date
    var preferredWeightUnit: String
    var trackedExercise: String?
    var tagline: String?
    var followers: [String]
    var following: [String]
}
