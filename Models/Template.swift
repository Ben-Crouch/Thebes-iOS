//
//  Template.swift
//  Thebes
//
//  Created by Ben on 11/03/2025.
//

import Foundation
import FirebaseFirestore

struct Template: Identifiable, Codable {
    @DocumentID var id: String?  // ✅ Firestore auto-generates ID
    var title: String
    var userId: String

    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
    }
}
