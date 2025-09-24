//
//  Workout.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation
import FirebaseFirestore

struct Workout: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // ✅ Firestore auto-generates if nil
    var title: String
    var date: Date
    var notes: String?
    var userId: String // ✅ Link workout to user

    init(title: String, date: Date, notes: String? = nil, userId: String) {
        self.title = title
        self.date = date
        self.notes = notes
        self.userId = userId
    }
}


