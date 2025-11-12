//
//  TrackerService.swift
//  Thebes
//
//  Created by Ben on 23/04/2025.
//

import FirebaseFirestore
import Foundation

class TrackerService {
    static let shared = TrackerService()
    private let db = Firestore.firestore()
    
    // Fetch all distinct exercise names for a user
    func fetchDistinctExerciseNames(for userId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        db.collection("exercises")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching exercise names: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let names = snapshot?.documents.compactMap { $0.data()["name"] as? String } ?? []
                let distinctNames = Array(Set(names)).sorted()
                print("✅ Fetched distinct exercise names: \(distinctNames)")
                completion(.success(distinctNames))
            }
    }
    
    func fetchUserProfileInfo(for userId: String, completion: @escaping (Result<(displayName: String, favoritedExercise: String?, preferredWeightUnit: WeightUnit), Error>) -> Void) {
        db.collection("users")
            .document(userId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("❌ Error fetching user profile: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let data = snapshot?.data(),
                      let displayName = data["displayName"] as? String,
                      let preferredWeightUnitRaw = data["preferredWeightUnit"] as? String else {
                    print("⚠️ Missing required user profile fields")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing required user profile fields"])))
                    return
                }

                let favoritedExercise = data["favoritedExercise"] as? String
                let preferredWeightUnit = WeightUnit(fromPreferredUnit: preferredWeightUnitRaw)
                print("✅ Fetched profile info: \(displayName), \(favoritedExercise ?? "None"), \(preferredWeightUnit.symbol)")
                completion(.success((displayName, favoritedExercise, preferredWeightUnit)))
            }
    }

    func fetchExercises(for userId: String, exerciseName: String, completion: @escaping (Result<[Exercise], Error>) -> Void) {
        db.collection("exercises")
            .whereField("userId", isEqualTo: userId)
            .whereField("name", isEqualTo: exerciseName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching exercises: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                let exercises = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Exercise.self)
                } ?? []

                print("✅ Retrieved \(exercises.count) exercises named \(exerciseName)")
                completion(.success(exercises))
            }
    }
}
