//
//  SetData.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation
import FirebaseFirestore

struct SetData: Codable {
    var reps: Int
    var weight: Double?  // 🔹 Always stored in KG
    var restTime: Int?

    init(reps: Int, weight: Double? = nil, restTime: Int? = nil) {
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
    }
}

