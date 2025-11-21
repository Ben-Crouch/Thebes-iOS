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
    
    /// Fetches a single workout by its ID
    func fetchWorkout(workoutId: String, completion: @escaping (Result<Workout, Error>) -> Void) {
        guard !workoutId.isEmpty else {
            print("❌ fetchWorkout called with empty workoutId")
            completion(.failure(NSError(domain: "WorkoutService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Workout ID cannot be empty"])))
            return
        }
        
        print("📡 Fetching workout with ID: \(workoutId)")
        db.collection("workouts").document(workoutId).getDocument { document, error in
            if let error = error {
                print("❌ Error fetching workout document: \(error.localizedDescription)")
                let nsError = error as NSError
                print("   Error domain: \(nsError.domain)")
                print("   Error code: \(nsError.code)")
                if !nsError.userInfo.isEmpty {
                    print("   Error userInfo: \(nsError.userInfo)")
                }
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                print("❌ Workout document does not exist for ID: \(workoutId)")
                completion(.failure(NSError(domain: "WorkoutService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Workout not found"])))
                return
            }
            
            print("✅ Workout document exists, decoding...")
            do {
                let workout = try document.data(as: Workout.self)
                print("✅ Successfully decoded workout: \(workout.title) (ID: \(workout.id ?? "nil"))")
                completion(.success(workout))
            } catch {
                print("❌ Error decoding workout: \(error.localizedDescription)")
                completion(.failure(error))
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
