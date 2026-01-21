//  ExerciseService.swift
//  Thebes
//
//  Created by Ben on 17/03/2025.
//

import FirebaseFirestore
import Foundation

class ExerciseService {
    static let shared = ExerciseService()
    private let db = Firestore.firestore()

    // Save an exercise to Firestore
    func saveExercise(exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        guard exercise.workoutId != nil || exercise.templateId != nil else {
            print("❌ Error: workoutId or templateId must be present")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "workoutId or templateId missing"])))
            return
        }

        let exerciseRef = db.collection("exercises").document()

        var exerciseData: [String: Any] = [
            "userId": exercise.userId,
            "name": exercise.name,
            "sets": exercise.sets.map { set in
                var data: [String: Any] = ["reps": set.reps]
                if let weight = set.weight { data["weight"] = weight }
                if let restTime = set.restTime { data["restTime"] = restTime }
                return data
            }
        ]
        if let order = exercise.order {
            exerciseData["order"] = order
        }
        if let date = exercise.date {
            exerciseData["date"] = Timestamp(date: date)
        }

        if let workoutId = exercise.workoutId {
            exerciseData["workoutId"] = workoutId
        }
        if let templateId = exercise.templateId {
            exerciseData["templateId"] = templateId
        }

        exerciseRef.setData(exerciseData) { error in
            if let error = error {
                print("❌ Error saving exercise: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Exercise saved with ID: \(exerciseRef.documentID)")
                completion(.success(()))
            }
        }
    }

    // Update exercise data
    func updateExercise(exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let exerciseId = exercise.id else {
            print("❌ Error: exercise.id is missing")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "exerciseId missing"])))
            return
        }

        var updateData: [String: Any] = [
            "userId": exercise.userId,
            "name": exercise.name,
            "sets": exercise.sets.map { set in
                var data: [String: Any] = ["reps": set.reps]
                if let weight = set.weight { data["weight"] = weight }
                if let restTime = set.restTime { data["restTime"] = restTime }
                return data
            }
        ]
        if let order = exercise.order {
            updateData["order"] = order
        }

        if let workoutId = exercise.workoutId {
            updateData["workoutId"] = workoutId
        }
        if let templateId = exercise.templateId {
            updateData["templateId"] = templateId
        }

        db.collection("exercises").document(exerciseId).setData(updateData, merge: true) { error in
            if let error = error {
                print("❌ Error updating exercise: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Exercise updated successfully")
                completion(.success(()))
            }
        }
    }

    // Fetch exercises for a workout
    func fetchExercisesForWorkout(userId: String, workoutId: String, completion: @escaping (Result<[Exercise], Error>) -> Void) {
        db.collection("exercises")
            .whereField("userId", isEqualTo: userId)
            .whereField("workoutId", isEqualTo: workoutId)
            .order(by: "order")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let exercises = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Exercise.self)
                    } ?? []
                    let sortedExercises = exercises.sorted { (lhs, rhs) in
                        (lhs.order ?? Int.max) < (rhs.order ?? Int.max)
                    }
                    completion(.success(sortedExercises))
                }
            }
    }

    // Fetch exercises for a template
    func fetchExercisesForTemplate(userId: String, templateId: String, completion: @escaping (Result<[Exercise], Error>) -> Void) {
        db.collection("exercises")
            .whereField("userId", isEqualTo: userId)
            .whereField("templateId", isEqualTo: templateId)
            .order(by: "order")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let exercises = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Exercise.self)
                    } ?? []
                    let sortedExercises = exercises.sorted { (lhs, rhs) in
                        (lhs.order ?? Int.max) < (rhs.order ?? Int.max)
                    }
                    completion(.success(sortedExercises))
                }
            }
    }

    func fetchExercisesForUserSince(userId: String, startDate: Date, completion: @escaping (Result<[Exercise], Error>) -> Void) {
        let startTimestamp = Timestamp(date: startDate)
        db.collection("exercises")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startTimestamp)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let exercises = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Exercise.self)
                    } ?? []
                    completion(.success(exercises))
                }
            }
    }
    
    func deleteExercise(exerciseId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("exercises").document(exerciseId).delete { error in
            if let error = error {
                print("❌ Error deleting exercise: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Exercise deleted: \(exerciseId)")
                completion(.success(()))
            }
        }
    }

    func deleteExercisesForTemplate(templateId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("exercises")
            .whereField("templateId", isEqualTo: templateId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching exercises for template deletion: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let batch = self.db.batch()
                snapshot?.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("❌ Error deleting exercises in batch: \(batchError.localizedDescription)")
                        completion(.failure(batchError))
                    } else {
                        print("✅ All exercises for template deleted")
                        completion(.success(()))
                    }
                }
            }
    }
    
    func deleteExercisesForWorkout(workoutId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("exercises")
            .whereField("workoutId", isEqualTo: workoutId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching exercises for workout deletion: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let batch = self.db.batch()
                snapshot?.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("❌ Error deleting workout exercises in batch: \(batchError.localizedDescription)")
                        completion(.failure(batchError))
                    } else {
                        print("✅ All exercises for workout deleted")
                        completion(.success(()))
                    }
                }
            }
    }
}
