//
//  Exercise.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation
import FirebaseFirestore

struct Exercise: Identifiable, Codable {
    @DocumentID var id: String? // ✅ Firestore auto-generates if nil
    var workoutId: String?// ✅ Links exercise to its workout
    var templateId: String?
    var userId : String
    var name: String
    var sets: [SetData] // ✅ Stores multiple sets for this exercise
    var date: Date?
    var order: Int?

    init(workoutId: String? = nil, templateId: String? = nil, userId: String, name: String, sets: [SetData], date: Date? = nil, order: Int? = nil) {
        self.workoutId = workoutId
        self.templateId = templateId
        self.userId = userId
        self.name = name
        self.sets = sets
        self.date = date
        self.order = order
    }
}
