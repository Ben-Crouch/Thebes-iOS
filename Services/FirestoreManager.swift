//
//  FirestoreManager.swift
//  Thebes
//
//  Created by Ben on 17/03/2025.
//

import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    // Firestore collection references
    let usersCollection = Firestore.firestore().collection("users")
    let workoutsCollection = Firestore.firestore().collection("workouts")
    let templatesCollection = Firestore.firestore().collection("templates")
    let exercisesCollection = Firestore.firestore().collection("exercises")
    let setDataCollection = Firestore.firestore().collection("setData")
}
