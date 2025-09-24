//
//  WorkoutService.swift
//  Thebes
//
//  Created by Ben on 17/03/2025.
//

import FirebaseFirestore
import Foundation

class WorkoutService {
    static let shared = WorkoutService()
    private let db = Firestore.firestore()
    
    /// ✅ Saves a workout to Firestore
    func saveWorkout(workout: Workout, completion: @escaping (Result<String, Error>) -> Void) {
        let workoutRef = db.collection("workouts").document() // ✅ Generates a new workout ID

        let workoutData: [String: Any] = [
            "userId": workout.userId,
            "title": workout.title,
            "date": Timestamp(date: workout.date),
            "notes": workout.notes ?? ""
        ]

        workoutRef.setData(workoutData) { error in
            if let error = error {
                print("❌ Error saving workout: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Workout saved successfully with ID: \(workoutRef.documentID)")
                completion(.success(workoutRef.documentID))
            }
        }
    }
    
    func fetchWorkouts(for userId: String, completion: @escaping (Result<[Workout], Error>) -> Void) {
        // TODO: REVERT FOR LAUNCH - Currently fetching 1 year for development
        // Change back to .limit(to: 5) and remove date filter for production
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        
        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThan: oneYearAgo)
            .order(by: "date", descending: true)
            .limit(to: 50) // Increased from 5 to 50 for development
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let workouts: [Workout] = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Workout.self)
                } ?? []
                completion(.success(workouts))
            }
    }
    
    func updateWorkout(workout: Workout, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let workoutId = workout.id else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Workout ID is missing."])))
            return
        }
        
        let workoutData: [String: Any] = [
            "userId": workout.userId,
            "title": workout.title,
            "date": Timestamp(date: workout.date),
            "notes": workout.notes ?? ""
        ]
        
        db.collection("workouts").document(workoutId).setData(workoutData, merge: true) { error in
            if let error = error {
                print("❌ Error updating workout: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Workout updated successfully with ID: \(workoutId)")
                completion(.success(()))
            }
        }
    }
    
    func deleteWorkout(workoutId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("workouts").document(workoutId).delete { error in
            if let error = error {
                print("❌ Error deleting workout: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Workout deleted successfully")
                completion(.success(()))
            }
        }
    }
        
    func fetchMoreWorkouts(for userId: String, startAfter lastDate: Date, limit: Int = 5, completion: @escaping (Result<[Workout], Error>) -> Void) {
        // TODO: REVERT FOR LAUNCH - Increased limit for development
        // Change back to limit = 5 for production
        let lastTimestamp = Timestamp(date: lastDate)
        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .start(after: [lastTimestamp])
            .limit(to: max(limit, 20)) // Increased minimum limit for development
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let workouts: [Workout] = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Workout.self)
                } ?? []
                completion(.success(workouts))
            }
    }
}
