//
//  MockUserProfile.swift
//  Thebes
//
//  Created by Ben on 28/05/2025.
//

import FirebaseFirestore

struct MockUserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var displayName: String
    var email: String
    var preferredWeightUnit: String
}
